import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';
import 'package:normatrack/features/deadlines/domain/deadline_validation.dart';

void main() {
  late AppDatabase db;
  late LocalCompanyRepository companies;
  late LocalDeadlineRepository repo;
  late DateTime now;
  late int nextId;

  void tick() => now = now.add(const Duration(minutes: 1));

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 1, 1);
    nextId = 0;
    DateTime clock() => now;
    String newId() => 'id-${++nextId}';
    companies = LocalCompanyRepository(db, clock: clock, newId: newId);
    repo = LocalDeadlineRepository(db, clock: clock, newId: newId);
  });

  tearDown(() => db.close());

  Future<String> company(
    String name, {
    Set<ModuleType> modules = const {ModuleType.environmental},
  }) async => (await companies.create(
    CompanyInput(legalName: name, enabledModules: modules),
  )).id;

  DeadlineInput input({
    String title = 'Licença de Operação',
    DeadlineCategory category = DeadlineCategory.license,
    ModuleType module = ModuleType.environmental,
    Authority? authority = Authority.semace,
    DateTime? dueDate,
    List<int>? reminderDays,
  }) => DeadlineInput(
    module: module,
    category: category,
    authority: authority,
    title: title,
    dueDate: dueDate ?? DateTime(2026, 10, 31),
    reminderDays: reminderDays,
  );

  Future<int> reminderRows(String deadlineId) async => (await (db.select(
    db.deadlineReminders,
  )..where((r) => r.deadlineId.equals(deadlineId))).get()).length;

  group('create e update', () {
    test('create grava com os lembretes padrão da categoria', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      expect(d.companyId, c);
      expect(d.status, DeadlineStatus.active);
      expect(d.reminderDays, [150, 30, 10, 3, 0]);
      expect(d.authority, Authority.semace);
      expect(d.createdAt, now);
      expect(await repo.findById(d.id), d);
    });

    test('valida o input', () async {
      final c = await company('Alfa');
      expect(
        () => repo.create(c, input(title: ' ')),
        throwsA(isA<DeadlineValidationException>()),
      );
    });

    test('empresa inexistente ou excluída', () async {
      expect(
        () => repo.create('nao-existe', input()),
        throwsA(isA<CompanyNotFoundException>()),
      );
      final c = await company('Alfa');
      await companies.delete(c);
      expect(
        () => repo.create(c, input()),
        throwsA(isA<CompanyNotFoundException>()),
      );
    });

    test('módulo não habilitado', () async {
      final c = await company('Alfa');
      expect(
        () => repo.create(c, input(module: ModuleType.controlledProducts)),
        throwsA(isA<ModuleNotEnabledException>()),
      );
      final d = await repo.create(c, input());
      expect(
        () => repo.update(d.id, input(module: ModuleType.qualityControl)),
        throwsA(isA<ModuleNotEnabledException>()),
      );
    });

    test('update troca campos e mantém createdAt', () async {
      final c = await company(
        'Alfa',
        modules: {ModuleType.environmental, ModuleType.controlledProducts},
      );
      final d = await repo.create(c, input());
      tick();
      final updated = await repo.update(
        d.id,
        input(
          title: 'Licença PF',
          module: ModuleType.controlledProducts,
          authority: Authority.federalPolice,
          dueDate: DateTime(2027, 3, 1),
        ),
      );
      expect(updated.title, 'Licença PF');
      expect(updated.module, ModuleType.controlledProducts);
      expect(updated.authority, Authority.federalPolice);
      expect(updated.dueDate, DateTime(2027, 3, 1));
      expect(updated.createdAt, d.createdAt);
      expect(updated.updatedAt, now);
    });

    test('update sem mudança não toca updatedAt', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      tick();
      final same = await repo.update(d.id, d.toInput());
      expect(same.updatedAt, d.updatedAt);
    });

    test(
      'mudar só os lembretes atualiza updatedAt e reaproveita linhas',
      () async {
        final c = await company('Alfa');
        final d = await repo.create(c, input(reminderDays: [30, 10, 0]));
        tick();
        final fewer = await repo.update(d.id, input(reminderDays: [30, 0]));
        expect(fewer.reminderDays, [30, 0]);
        expect(fewer.updatedAt, now);
        tick();
        final again = await repo.update(d.id, input(reminderDays: [30, 10, 0]));
        expect(again.reminderDays, [30, 10, 0]);
        expect(await reminderRows(d.id), 3);
      },
    );

    test('update de prazo inexistente', () async {
      expect(
        () => repo.update('nao-existe', input()),
        throwsA(isA<DeadlineNotFoundException>()),
      );
    });
  });

  group('renovar', () {
    test('fecha o atual e abre o próximo com os mesmos dados', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input(reminderDays: [90, 0]));
      tick();
      final next = await repo.renew(d.id, newDueDate: DateTime(2030, 10, 31));
      expect(next.id, isNot(d.id));
      expect(next.previousDeadlineId, d.id);
      expect(next.status, DeadlineStatus.active);
      expect(next.dueDate, DateTime(2030, 10, 31));
      expect(next.title, d.title);
      expect(next.authority, d.authority);
      expect(next.reminderDays, [90, 0]);
      expect((await repo.findById(d.id))!.status, DeadlineStatus.renewed);
    });

    test('nova data precisa ser posterior', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      for (final date in [DateTime(2026, 10, 31), DateTime(2026, 1, 1)]) {
        await expectLater(
          repo.renew(d.id, newDueDate: date),
          throwsA(
            isA<DeadlineValidationException>().having(
              (e) => e.errors,
              'errors',
              [
                const DeadlineFieldError(
                  DeadlineField.dueDate,
                  DeadlineFieldErrorType.notAfterPrevious,
                ),
              ],
            ),
          ),
        );
      }
      expect((await repo.findById(d.id))!.status, DeadlineStatus.active);
    });

    test('só prazo em aberto', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      await repo.renew(d.id, newDueDate: DateTime(2030, 1, 1));
      expect(
        () => repo.renew(d.id, newDueDate: DateTime(2031, 1, 1)),
        throwsA(isA<InvalidDeadlineTransitionException>()),
      );
    });
  });

  group('concluir, cancelar e reabrir', () {
    test('concluir manutenção grava a data', () async {
      final c = await company('Alfa');
      final d = await repo.create(
        c,
        input(title: 'Bomba dosadora', category: DeadlineCategory.maintenance),
      );
      await repo.complete(d.id, completedOn: DateTime(2026, 9, 30, 14));
      final done = (await repo.findById(d.id))!;
      expect(done.status, DeadlineStatus.completed);
      expect(done.completedOn, DateTime(2026, 9, 30));
    });

    test('licença não se conclui', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      expect(
        () => repo.complete(d.id, completedOn: DateTime(2026, 9, 30)),
        throwsA(isA<InvalidDeadlineTransitionException>()),
      );
    });

    test('cancelar e reabrir', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      await repo.cancel(d.id);
      expect((await repo.findById(d.id))!.status, DeadlineStatus.cancelled);
      expect(
        () => repo.cancel(d.id),
        throwsA(isA<InvalidDeadlineTransitionException>()),
      );
      await repo.reopen(d.id);
      expect((await repo.findById(d.id))!.status, DeadlineStatus.active);
    });

    test('reabrir concluído limpa a data de conclusão', () async {
      final c = await company('Alfa');
      final d = await repo.create(
        c,
        input(category: DeadlineCategory.labReport),
      );
      await repo.complete(d.id, completedOn: DateTime(2026, 9, 30));
      await repo.reopen(d.id);
      final reopened = (await repo.findById(d.id))!;
      expect(reopened.status, DeadlineStatus.active);
      expect(reopened.completedOn, isNull);
    });

    test('renovado e em aberto não reabrem', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      expect(
        () => repo.reopen(d.id),
        throwsA(isA<InvalidDeadlineTransitionException>()),
      );
      await repo.renew(d.id, newDueDate: DateTime(2030, 1, 1));
      expect(
        () => repo.reopen(d.id),
        throwsA(isA<InvalidDeadlineTransitionException>()),
      );
    });
  });

  group('excluir', () {
    test('some das leituras e exclui os lembretes', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      await repo.delete(d.id);
      expect(await repo.findById(d.id), isNull);
      expect(await repo.watchByCompany(c).first, isEmpty);
      final live = await (db.select(
        db.deadlineReminders,
      )..where((r) => r.deadlineId.equals(d.id) & r.deletedAt.isNull())).get();
      expect(live, isEmpty);
      expect(
        () => repo.delete(d.id),
        throwsA(isA<DeadlineNotFoundException>()),
      );
    });

    test('excluir o ciclo atual reabre o anterior', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      final next = await repo.renew(d.id, newDueDate: DateTime(2030, 1, 1));
      await repo.delete(next.id);
      expect((await repo.findById(d.id))!.status, DeadlineStatus.active);
      // Pode renovar de novo: o índice único ignora o ciclo excluído.
      await repo.renew(d.id, newDueDate: DateTime(2031, 1, 1));
    });

    test('excluir um ciclo antigo não mexe nos outros', () async {
      final c = await company('Alfa');
      final a = await repo.create(c, input());
      final b = await repo.renew(a.id, newDueDate: DateTime(2030, 1, 1));
      final cc = await repo.renew(b.id, newDueDate: DateTime(2034, 1, 1));
      await repo.delete(b.id);
      expect((await repo.findById(a.id))!.status, DeadlineStatus.renewed);
      expect((await repo.findById(cc.id))!.status, DeadlineStatus.active);
    });
  });

  group('histórico', () {
    test('cadeia completa a partir de qualquer ciclo', () async {
      final c = await company('Alfa');
      final a = await repo.create(c, input());
      final b = await repo.renew(a.id, newDueDate: DateTime(2030, 1, 1));
      final cc = await repo.renew(b.id, newDueDate: DateTime(2034, 1, 1));
      final ids = [cc.id, b.id, a.id];
      expect((await repo.watchHistory(a.id).first).map((d) => d.id), ids);
      expect((await repo.watchHistory(cc.id).first).map((d) => d.id), ids);
    });

    test('ciclo do meio excluído não interrompe a cadeia', () async {
      final c = await company('Alfa');
      final a = await repo.create(c, input());
      final b = await repo.renew(a.id, newDueDate: DateTime(2030, 1, 1));
      final cc = await repo.renew(b.id, newDueDate: DateTime(2034, 1, 1));
      await repo.delete(b.id);
      expect((await repo.watchHistory(a.id).first).map((d) => d.id), [
        cc.id,
        a.id,
      ]);
      expect((await repo.watchHistory(cc.id).first).map((d) => d.id), [
        cc.id,
        a.id,
      ]);
    });

    test('prazo excluído ou inexistente não tem histórico', () async {
      expect(await repo.watchHistory('nao-existe').first, isEmpty);
    });
  });

  group('listagens', () {
    test('watchByCompany filtra por módulo e estado e ordena', () async {
      final c = await company(
        'Alfa',
        modules: {ModuleType.environmental, ModuleType.controlledProducts},
      );
      final other = await company('Beta');
      final late = await repo.create(
        c,
        input(title: 'Zeta', dueDate: DateTime(2027, 1, 1)),
      );
      final early = await repo.create(
        c,
        input(title: 'Ética', dueDate: DateTime(2026, 5, 1)),
      );
      final sameDay = await repo.create(
        c,
        input(title: 'Água', dueDate: DateTime(2026, 5, 1)),
      );
      final pf = await repo.create(
        c,
        input(module: ModuleType.controlledProducts, title: 'Licença PF'),
      );
      await repo.create(other, input());
      final cancelled = await repo.create(c, input(title: 'Cancelado'));
      await repo.cancel(cancelled.id);

      expect((await repo.watchByCompany(c).first).map((d) => d.id), [
        sameDay.id,
        early.id,
        pf.id,
        late.id,
      ]);
      expect(
        (await repo
                .watchByCompany(c, module: ModuleType.controlledProducts)
                .first)
            .map((d) => d.id),
        [pf.id],
      );
      expect(
        (await repo
                .watchByCompany(c, statuses: {DeadlineStatus.cancelled})
                .first)
            .map((d) => d.id),
        [cancelled.id],
      );
    });

    test(
      'watchUpcoming só com prazos em aberto de empresas e módulos ativos',
      () async {
        final active = await company('Alfa');
        final archived = await company('Beta');
        final deleted = await company('Gama');
        final disabled = await company(
          'Delta',
          modules: {ModuleType.environmental, ModuleType.qualityControl},
        );

        final open = await repo.create(active, input(title: 'Aberto'));
        final completed = await repo.create(
          active,
          input(category: DeadlineCategory.labReport, title: 'Concluído'),
        );
        await repo.complete(completed.id, completedOn: DateTime(2026, 9, 1));
        final cancelled = await repo.create(active, input(title: 'Cancelado'));
        await repo.cancel(cancelled.id);
        final renewed = await repo.create(active, input(title: 'Renovado'));
        final next = await repo.renew(
          renewed.id,
          newDueDate: DateTime(2030, 1, 1),
        );

        await repo.create(archived, input());
        await companies.archive(archived);
        await repo.create(deleted, input());
        await companies.delete(deleted);
        final quality = await repo.create(
          disabled,
          input(module: ModuleType.qualityControl, title: 'Qualidade'),
        );
        final kept = await repo.create(disabled, input(title: 'Ambiental'));
        final base = (await companies.findById(disabled))!.toInput();
        await companies.update(
          disabled,
          CompanyInput(
            legalName: base.legalName,
            enabledModules: {ModuleType.environmental},
          ),
        );

        final upcoming = await repo.watchUpcoming().first;
        expect(
          upcoming.map((d) => d.id),
          unorderedEquals([open.id, next.id, kept.id]),
        );
        expect(upcoming.map((d) => d.id), isNot(contains(quality.id)));
      },
    );

    test('watchUpcoming emite de novo depois de renovar', () async {
      final c = await company('Alfa');
      final d = await repo.create(c, input());
      final stream = repo.watchUpcoming();
      final emitted = expectLater(
        stream.map((list) => list.map((x) => x.dueDate).toList()),
        emitsInOrder([
          [DateTime(2026, 10, 31)],
          [DateTime(2030, 1, 1)],
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      await repo.renew(d.id, newDueDate: DateTime(2030, 1, 1));
      await emitted;
    });
  });
}

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/measurements/data/local_measurement_repository.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';
import 'package:normatrack/features/measurements/domain/measurement_repository.dart';
import 'package:normatrack/features/measurements/domain/measurement_validation.dart';
import 'package:normatrack/features/measurements/domain/pending_launch.dart';

void main() {
  late AppDatabase db;
  late LocalCompanyRepository companies;
  late LocalMeasurementRepository repo;
  late DateTime now;
  late int nextId;

  // Quinta, semana 48 (23 a 29/11/2026).
  final today = DateTime(2026, 11, 26);
  const noise = MeasurementContext.noise;
  const weekly = MeasurementFrequency.weekly;
  MeasurementPeriod week(int y, int m, int d) =>
      MeasurementPeriod.containing(weekly, DateTime(y, m, d));
  final w47 = week(2026, 11, 16);
  final w48 = week(2026, 11, 23);

  void tick() => now = now.add(const Duration(minutes: 1));

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 26, 12);
    nextId = 0;
    DateTime clock() => now;
    String newId() => 'id-${++nextId}';
    companies = LocalCompanyRepository(db, clock: clock, newId: newId);
    repo = LocalMeasurementRepository(db, clock: clock, newId: newId);
  });

  tearDown(() => db.close());

  Future<String> company(
    String name, {
    Set<ModuleType> modules = const {ModuleType.environmental},
  }) async => (await companies.create(
    CompanyInput(legalName: name, enabledModules: modules),
  )).id;

  MeasurementParameterInput input(
    String name, {
    String? unit = 'dB(A)',
    MeasurementFrequency frequency = weekly,
    DateTime? start,
    double? min,
    double? max,
  }) => MeasurementParameterInput(
    name: name,
    unit: unit,
    frequency: frequency,
    startDate: start ?? DateTime(2026, 11, 18),
    limitMin: min,
    limitMax: max,
  );

  Future<MeasurementParameter> param(
    String companyId,
    String name, {
    MeasurementContext context = noise,
    MeasurementFrequency frequency = weekly,
    DateTime? start,
  }) => repo.createParameter(
    companyId,
    context,
    input(name, frequency: frequency, start: start),
  );

  Future<List<MeasurementParameter>> params(
    String companyId, {
    bool includeArchived = false,
  }) => repo
      .watchParameters(companyId, noise, includeArchived: includeArchived)
      .first;

  Future<List<Measurement>> measures(String companyId) =>
      repo.watchMeasurements(companyId, noise).first;

  Matcher validation(List<ParameterFieldError> errors) =>
      isA<MeasurementValidationException>().having(
        (e) => e.parameterErrors,
        'parameterErrors',
        errors,
      );

  group('createParameter', () {
    test('normaliza, grava e vai para o fim da lista', () async {
      final c = await company('Alfa');
      final p1 = await repo.createParameter(
        c,
        noise,
        input(
          '  Portão   principal ',
          unit: ' ',
          start: DateTime(2026, 11, 18, 9),
          max: 70,
        ),
      );
      final p2 = await param(c, 'Divisa norte');

      expect(p1.name, 'Portão principal');
      expect(p1.unit, isNull);
      expect(p1.startDate, DateTime(2026, 11, 18));
      expect(p1.limitMax, 70);
      expect(p1.companyId, c);
      expect(p1.createdAt, now);
      expect([p1.position, p2.position], [0, 1]);
      expect((await params(c)).map((p) => p.id), [p1.id, p2.id]);
    });

    test('nome repetido no mesmo contexto (sem acento/caixa)', () async {
      final c = await company('Alfa');
      await param(c, 'Galpão B');
      await expectLater(
        param(c, 'galpao b'),
        throwsA(
          validation([
            const ParameterFieldError(
              ParameterField.name,
              ParameterFieldErrorType.duplicate,
            ),
          ]),
        ),
      );
      // Outro contexto e outra empresa podem.
      await param(c, 'Galpão B', context: MeasurementContext.effluent);
      await param(await company('Beta'), 'Galpão B');
    });

    test('nome vazio e limites invertidos', () async {
      final c = await company('Alfa');
      await expectLater(
        repo.createParameter(c, noise, input(' ', min: 9, max: 6)),
        throwsA(
          validation([
            const ParameterFieldError(
              ParameterField.name,
              ParameterFieldErrorType.required,
            ),
            const ParameterFieldError(
              ParameterField.limitMax,
              ParameterFieldErrorType.limitsInverted,
            ),
          ]),
        ),
      );
    });

    test('empresa inexistente, excluída ou sem o módulo', () async {
      await expectLater(
        param('nada', 'Ponto'),
        throwsA(isA<CompanyNotFoundException>()),
      );
      final excluida = await company('Excluída');
      await companies.delete(excluida);
      await expectLater(
        param(excluida, 'Ponto'),
        throwsA(isA<CompanyNotFoundException>()),
      );
      final semModulo = await company('Sem módulo', modules: const {});
      await expectLater(
        param(semModulo, 'Ponto'),
        throwsA(isA<MeasurementModuleNotEnabledException>()),
      );
    });

    test('empresa arquivada pode', () async {
      final c = await company('Alfa');
      await companies.archive(c);
      expect((await param(c, 'Ponto 1')).name, 'Ponto 1');
    });
  });

  group('updateParameter', () {
    test('altera os dados e o updatedAt; sem mudança não grava', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      tick();
      final same = await repo.updateParameter(p.id, p.toInput());
      expect(same.updatedAt, p.updatedAt);

      final changed = await repo.updateParameter(
        p.id,
        input('Ponto 1 ', max: 65),
      );
      expect(changed.limitMax, 65);
      expect(changed.updatedAt, now);
      expect(changed.position, p.position);
    });

    test('nome do próprio parâmetro não é duplicado; o de outro é', () async {
      final c = await company('Alfa');
      final p1 = await param(c, 'Ponto 1');
      await param(c, 'Ponto 2');
      await repo.updateParameter(p1.id, input('PONTO 1'));
      await expectLater(
        repo.updateParameter(p1.id, input('Ponto 2')),
        throwsA(
          validation([
            const ParameterFieldError(
              ParameterField.name,
              ParameterFieldErrorType.duplicate,
            ),
          ]),
        ),
      );
    });

    test('frequência trava com medição viva e libera sem', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      final monthly = input('Ponto 1', frequency: MeasurementFrequency.monthly);
      await repo.savePeriod(w47, {
        p.id: const MeasurementEntry(value: 60),
      }, today: today);
      await expectLater(
        repo.updateParameter(p.id, monthly),
        throwsA(
          validation([
            const ParameterFieldError(
              ParameterField.frequency,
              ParameterFieldErrorType.locked,
            ),
          ]),
        ),
      );
      await repo.savePeriod(w47, {p.id: null}, today: today);
      final updated = await repo.updateParameter(p.id, monthly);
      expect(updated.frequency, MeasurementFrequency.monthly);
    });

    test('inexistente ou excluído', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      await repo.deleteParameter(p.id);
      for (final id in ['nada', p.id]) {
        await expectLater(
          repo.updateParameter(id, input('X')),
          throwsA(isA<MeasurementParameterNotFoundException>()),
        );
      }
    });
  });

  group('ordenar, arquivar e excluir', () {
    test('reorderParameters grava a nova ordem', () async {
      final c = await company('Alfa');
      final a = await param(c, 'A');
      final b = await param(c, 'B');
      final x = await param(c, 'X');
      await repo.archiveParameter(x.id);
      await repo.reorderParameters(c, noise, [x.id, b.id, a.id]);
      expect((await params(c, includeArchived: true)).map((p) => p.name), [
        'X',
        'B',
        'A',
      ]);
    });

    test('reorderParameters exige exatamente os ids do contexto', () async {
      final c = await company('Alfa');
      final a = await param(c, 'A');
      final b = await param(c, 'B');
      for (final ids in [
        [a.id],
        [a.id, b.id, 'nada'],
        [a.id, a.id],
      ]) {
        await expectLater(
          repo.reorderParameters(c, noise, ids),
          throwsArgumentError,
          reason: '$ids',
        );
      }
    });

    test('arquivar e desarquivar são idempotentes', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      tick();
      await repo.archiveParameter(p.id);
      final archivedAt = now;
      tick();
      await repo.archiveParameter(p.id);
      expect((await repo.findParameter(p.id))!.archivedAt, archivedAt);
      expect(await params(c), isEmpty);
      expect(await params(c, includeArchived: true), hasLength(1));

      await repo.unarchiveParameter(p.id);
      await repo.unarchiveParameter(p.id);
      expect((await repo.findParameter(p.id))!.isArchived, isFalse);
      expect(await params(c), hasLength(1));
    });

    test('excluir apaga logicamente o parâmetro e as medições', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      final other = await param(c, 'Ponto 2');
      await repo.savePeriod(w47, {
        p.id: const MeasurementEntry(value: 60),
        other.id: const MeasurementEntry(value: 55),
      }, today: today);
      tick();
      await repo.deleteParameter(p.id);

      expect(await repo.findParameter(p.id), isNull);
      expect((await measures(c)).map((m) => m.parameterId), [other.id]);
      final rows = await db.select(db.measurements).get();
      expect(rows.firstWhere((r) => r.parameterId == p.id).deletedAt, now);
      await expectLater(
        repo.deleteParameter(p.id),
        throwsA(isA<MeasurementParameterNotFoundException>()),
      );
    });
  });

  group('savePeriod', () {
    test('insere parcial, edita, apaga e justifica', () async {
      final c = await company('Alfa');
      final p1 = await param(c, 'Ponto 1');
      final p2 = await param(c, 'Ponto 2');

      await repo.savePeriod(w48, {
        p1.id: const MeasurementEntry(value: 61.8, note: '  chuva  '),
      }, today: today);
      var list = await measures(c);
      expect(list, hasLength(1));
      expect(list.single.value, 61.8);
      expect(list.single.note, 'chuva');
      expect(list.single.periodStart, DateTime(2026, 11, 23));
      final created = list.single;

      tick();
      // Mesma entrada não grava; p2 justificada.
      await repo.savePeriod(w48, {
        p1.id: const MeasurementEntry(value: 61.8, note: 'chuva'),
        p2.id: const MeasurementEntry(note: 'Fábrica parada'),
      }, today: today);
      list = await measures(c);
      expect(list.first, created);
      expect(list.last.isSkipped, isTrue);
      expect(list.last.note, 'Fábrica parada');

      tick();
      await repo.savePeriod(w48, {
        p1.id: const MeasurementEntry(value: 62),
        p2.id: null,
      }, today: today);
      list = await measures(c);
      expect(list.single.id, created.id);
      expect(list.single.value, 62);
      expect(list.single.note, isNull);
      expect(list.single.updatedAt, now);

      // Apagar e lançar de novo cria outra linha (índice parcial).
      await repo.savePeriod(w48, {p1.id: null}, today: today);
      await repo.savePeriod(w48, {
        p1.id: const MeasurementEntry(value: 63),
      }, today: today);
      expect((await measures(c)).single.id, isNot(created.id));
    });

    test('período passado, atual e arquivado aceitos; futuro não', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      await repo.archiveParameter(p.id);
      await repo.savePeriod(week(2025, 1, 6), {
        p.id: const MeasurementEntry(value: 50),
      }, today: today);
      // Domingo 29/11 ainda é a semana atual.
      await repo.savePeriod(w48, {
        p.id: const MeasurementEntry(value: 51),
      }, today: DateTime(2026, 11, 23));
      await expectLater(
        repo.savePeriod(week(2026, 11, 30), {
          p.id: const MeasurementEntry(value: 52),
        }, today: DateTime(2026, 11, 29)),
        throwsA(isA<FuturePeriodException>()),
      );
      expect(await measures(c), hasLength(2));
    });

    test('entrada inválida não grava nada', () async {
      final c = await company('Alfa');
      final p1 = await param(c, 'Ponto 1');
      final p2 = await param(c, 'Ponto 2');
      await expectLater(
        repo.savePeriod(w48, {
          p1.id: const MeasurementEntry(value: 60),
          p2.id: const MeasurementEntry(note: ' '),
        }, today: today),
        throwsA(
          isA<MeasurementValidationException>().having(
            (e) => e.entryErrors,
            'entryErrors',
            {
              p2.id: [
                const EntryFieldError(
                  EntryField.note,
                  EntryFieldErrorType.required,
                ),
              ],
            },
          ),
        ),
      );
      expect(await measures(c), isEmpty);
    });

    test('parâmetro excluído ou de outra frequência', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1');
      final monthly = await param(
        c,
        'Mensal',
        frequency: MeasurementFrequency.monthly,
      );
      await repo.deleteParameter(p.id);
      await expectLater(
        repo.savePeriod(w48, {
          p.id: const MeasurementEntry(value: 1),
        }, today: today),
        throwsA(isA<MeasurementParameterNotFoundException>()),
      );
      await expectLater(
        repo.savePeriod(w48, {
          monthly.id: const MeasurementEntry(value: 1),
        }, today: today),
        throwsArgumentError,
      );
    });
  });

  test('watchMeasurements filtra por período e ordena por ponto', () async {
    final c = await company('Alfa');
    final p1 = await param(c, 'Ponto 1', start: DateTime(2026, 11, 2));
    final p2 = await param(c, 'Ponto 2', start: DateTime(2026, 11, 2));
    await repo.reorderParameters(c, noise, [p2.id, p1.id]);
    for (final w in [week(2026, 11, 2), w47, w48]) {
      await repo.savePeriod(w, {
        p1.id: const MeasurementEntry(value: 1),
        p2.id: const MeasurementEntry(value: 2),
      }, today: today);
    }
    final list = await repo
        .watchMeasurements(
          c,
          noise,
          from: DateTime(2026, 11, 16),
          to: DateTime(2026, 11, 22),
        )
        .first;
    expect(list.map((m) => (m.periodStart, m.parameterId)), [
      (DateTime(2026, 11, 16), p2.id),
      (DateTime(2026, 11, 16), p1.id),
    ]);
    expect(
      await repo.watchMeasurements(c, MeasurementContext.effluent).first,
      isEmpty,
    );
  });

  group('watchPendingLaunches', () {
    test('calcula e acompanha os lançamentos', () async {
      final c = await company('Alfa');
      final p = await param(c, 'Ponto 1', start: DateTime(2026, 11, 18));
      final stream = repo.watchPendingLaunches(today: today);
      final emissions = <List<PendingLaunch>>[];
      final sub = stream.listen(emissions.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      expect(emissions.last.map((l) => (l.period, l.kind)), [
        (w47, PendingKind.overdue),
        (w48, PendingKind.toLaunch),
      ]);

      await repo.savePeriod(w47, {
        p.id: const MeasurementEntry(value: 60),
      }, today: today);
      await pumpEventQueue();
      expect(emissions.last.map((l) => l.period), [w48]);
    });

    test('empresa arquivada, excluída ou sem módulo não aparece', () async {
      final a = await company('Alfa');
      final b = await company('Beta');
      final d = await company('Delta');
      final e = await company('Épsilon');
      for (final c in [a, b, d, e]) {
        await param(c, 'Ponto 1', start: DateTime(2026, 11, 23));
      }
      await companies.archive(b);
      await companies.delete(d);
      await companies.update(
        e,
        const CompanyInput(legalName: 'Épsilon', enabledModules: {}),
      );

      final all = await repo.watchPendingLaunches(today: today).first;
      expect(all.map((l) => l.companyId), [a]);
      expect(
        await repo.watchPendingLaunches(today: today, companyId: b).first,
        isEmpty,
      );
      expect(
        (await repo.watchPendingLaunches(today: today, companyId: a).first)
            .single
            .expected,
        1,
      );
    });
  });
}

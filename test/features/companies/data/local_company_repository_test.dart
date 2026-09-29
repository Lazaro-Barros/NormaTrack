import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/domain/company_validation.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';

void main() {
  late AppDatabase db;
  late LocalCompanyRepository repo;
  late DateTime now;
  late int nextId;

  void tick() => now = now.add(const Duration(minutes: 1));

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 1, 1);
    nextId = 0;
    repo = LocalCompanyRepository(
      db,
      clock: () => now,
      newId: () => 'id-${++nextId}',
    );
  });

  tearDown(() => db.close());

  const cnpjA = '11222333000181';
  const cnpjB = '12ABC34501DE35';

  AuthorityRegistration reg(
    Authority authority, [
    RegistrationStatus status = RegistrationStatus.registered,
    String? number,
  ]) => AuthorityRegistration(
    authority: authority,
    status: status,
    registrationNumber: number,
  );

  group('create', () {
    test('grava e findById devolve o mesmo agregado', () async {
      final created = await repo.create(
        CompanyInput(
          legalName: ' Indústria Alfa Ltda ',
          tradeName: 'Alfa',
          cnpj: '11.222.333/0001-81',
          address: const Address(city: 'Fortaleza', postalCode: '60115-170'),
          legalRepresentative: const LegalRepresentative(
            name: 'Maria',
            cpf: '123.456.789-09',
          ),
          enabledModules: {ModuleType.environmental},
          registrations: {
            Authority.ibama: AuthorityRegistration(
              authority: Authority.ibama,
              status: RegistrationStatus.registered,
              registrationNumber: 'IB-1',
              validUntil: DateTime(2027, 6, 30),
            ),
          },
        ),
      );

      expect(created.id, 'id-1');
      expect(created.legalName, 'Indústria Alfa Ltda');
      expect(created.cnpj, cnpjA);
      expect(created.address.postalCode, '60115170');
      expect(created.legalRepresentative.cpf, '12345678909');
      expect(created.createdAt, now);
      expect(created.updatedAt, now);
      expect(created.hasModule(ModuleType.environmental), isTrue);
      expect(
        created.registrationFor(Authority.ibama)!.validUntil,
        DateTime(2027, 6, 30),
      );
      expect(await repo.findById(created.id), created);
    });

    test('input inválido lança CompanyValidationException', () async {
      await expectLater(
        repo.create(const CompanyInput(legalName: '', cnpj: '123')),
        throwsA(
          isA<CompanyValidationException>().having((e) => e.errors, 'errors', [
            const CompanyFieldError(
              CompanyField.legalName,
              CompanyFieldErrorType.required,
            ),
            const CompanyFieldError(
              CompanyField.cnpj,
              CompanyFieldErrorType.invalid,
            ),
          ]),
        ),
      );
      expect(await db.select(db.companies).get(), isEmpty);
    });
  });

  group('update', () {
    test('troca campos, módulos e registros e mantém createdAt', () async {
      final created = await repo.create(
        CompanyInput(
          legalName: 'Alfa',
          enabledModules: {ModuleType.environmental},
          registrations: {Authority.anvisa: reg(Authority.anvisa)},
        ),
      );
      tick();

      final updated = await repo.update(
        created.id,
        CompanyInput(
          legalName: 'Alfa Nova',
          cnpj: cnpjB,
          enabledModules: {ModuleType.qualityControl},
          registrations: {
            Authority.army: reg(Authority.army, RegistrationStatus.required),
          },
        ),
      );

      expect(updated.legalName, 'Alfa Nova');
      expect(updated.cnpj, cnpjB);
      expect(updated.enabledModules, {ModuleType.qualityControl});
      expect(updated.registrations.keys, [Authority.army]);
      expect(updated.createdAt, created.createdAt);
      expect(updated.updatedAt, now);
    });

    test('só as linhas que mudaram recebem updatedAt novo', () async {
      final created = await repo.create(
        CompanyInput(
          legalName: 'Alfa',
          registrations: {
            Authority.anvisa: reg(Authority.anvisa),
            Authority.ibama: reg(Authority.ibama),
          },
        ),
      );
      final createdAt = now;
      tick();

      final input = created.toInput();
      final updated = await repo.update(
        created.id,
        CompanyInput(
          legalName: input.legalName,
          registrations: {
            ...input.registrations,
            Authority.ibama: reg(Authority.ibama, RegistrationStatus.required),
          },
        ),
      );

      expect(updated.updatedAt, createdAt);
      final rows = {
        for (final r in await db.select(db.companyAuthorities).get())
          r.authority: r,
      };
      expect(rows['anvisa']!.updatedAt, createdAt);
      expect(rows['ibama']!.updatedAt, now);
    });

    test('remover registro e readicionar reaproveita a linha', () async {
      final created = await repo.create(
        CompanyInput(
          legalName: 'Alfa',
          registrations: {Authority.semace: reg(Authority.semace)},
        ),
      );
      final rowId = (await db.select(db.companyAuthorities).getSingle()).id;

      tick();
      final removed = await repo.update(
        created.id,
        const CompanyInput(legalName: 'Alfa'),
      );
      expect(removed.registrationFor(Authority.semace), isNull);
      final deleted = await db.select(db.companyAuthorities).getSingle();
      expect(deleted.deletedAt, now);

      tick();
      final readded = await repo.update(
        created.id,
        CompanyInput(
          legalName: 'Alfa',
          registrations: {
            Authority.semace: reg(
              Authority.semace,
              RegistrationStatus.registered,
              'S-9',
            ),
          },
        ),
      );
      expect(
        readded.registrationFor(Authority.semace)!.registrationNumber,
        'S-9',
      );
      final row = await db.select(db.companyAuthorities).getSingle();
      expect(row.id, rowId);
      expect(row.deletedAt, isNull);
    });

    test('desabilitar e reabilitar módulo usa a mesma linha', () async {
      final created = await repo.create(
        CompanyInput(
          legalName: 'Alfa',
          enabledModules: {ModuleType.controlledProducts},
        ),
      );
      final off = await repo.update(
        created.id,
        const CompanyInput(legalName: 'Alfa'),
      );
      expect(off.hasModule(ModuleType.controlledProducts), isFalse);
      final on = await repo.update(
        created.id,
        CompanyInput(
          legalName: 'Alfa',
          enabledModules: {ModuleType.controlledProducts},
        ),
      );
      expect(on.hasModule(ModuleType.controlledProducts), isTrue);
      final rows = await db.select(db.companyModules).get();
      expect(rows, hasLength(1));
      expect(rows.single.enabled, isTrue);
    });
  });

  group('CNPJ duplicado', () {
    Matcher duplicate = throwsA(isA<DuplicateCnpjException>());

    test('com empresa ativa', () async {
      await repo.create(const CompanyInput(legalName: 'A', cnpj: cnpjA));
      await expectLater(
        repo.create(
          const CompanyInput(legalName: 'B', cnpj: '11.222.333/0001-81'),
        ),
        duplicate,
      );
    });

    test('com empresa arquivada', () async {
      final a = await repo.create(
        const CompanyInput(legalName: 'A', cnpj: cnpjB),
      );
      await repo.archive(a.id);
      await expectLater(
        repo.create(
          const CompanyInput(legalName: 'B', cnpj: '12.abc.345/01de-35'),
        ),
        duplicate,
      );
    });

    test('fica livre depois de excluir', () async {
      final a = await repo.create(
        const CompanyInput(legalName: 'A', cnpj: cnpjA),
      );
      await repo.delete(a.id);
      final b = await repo.create(
        const CompanyInput(legalName: 'B', cnpj: cnpjA),
      );
      expect(b.cnpj, cnpjA);
    });

    test('a própria empresa não conta na edição; outra conta', () async {
      final a = await repo.create(
        const CompanyInput(legalName: 'A', cnpj: cnpjA),
      );
      final b = await repo.create(
        const CompanyInput(legalName: 'B', cnpj: cnpjB),
      );
      final edited = await repo.update(
        a.id,
        const CompanyInput(legalName: 'A2', cnpj: cnpjA),
      );
      expect(edited.legalName, 'A2');
      await expectLater(
        repo.update(b.id, const CompanyInput(legalName: 'B', cnpj: cnpjA)),
        duplicate,
      );
    });
  });

  group('CompanyNotFoundException', () {
    Matcher notFound = throwsA(isA<CompanyNotFoundException>());

    test('id inexistente', () async {
      const input = CompanyInput(legalName: 'X');
      await expectLater(repo.update('nada', input), notFound);
      await expectLater(repo.archive('nada'), notFound);
      await expectLater(repo.unarchive('nada'), notFound);
      await expectLater(repo.delete('nada'), notFound);
      expect(await repo.findById('nada'), isNull);
    });

    test('empresa excluída', () async {
      final a = await repo.create(const CompanyInput(legalName: 'A'));
      await repo.delete(a.id);
      await expectLater(repo.update(a.id, a.toInput()), notFound);
      await expectLater(repo.archive(a.id), notFound);
      await expectLater(repo.delete(a.id), notFound);
    });
  });

  test('arquivar e desarquivar são idempotentes e filtram a lista', () async {
    final a = await repo.create(const CompanyInput(legalName: 'A'));
    await repo.create(const CompanyInput(legalName: 'B'));
    tick();

    await repo.archive(a.id);
    final archived = (await repo.findById(a.id))!;
    expect(archived.isArchived, isTrue);
    expect(archived.archivedAt, now);

    tick();
    await repo.archive(a.id);
    expect((await repo.findById(a.id))!.updatedAt, archived.updatedAt);

    Future<List<String>> names(bool archived) async =>
        (await repo.watchAll(CompanyFilter(archived: archived)).first)
            .map((c) => c.legalName)
            .toList();
    expect(await names(false), ['B']);
    expect(await names(true), ['A']);

    await repo.unarchive(a.id);
    await repo.unarchive(a.id);
    expect((await repo.findById(a.id))!.isArchived, isFalse);
    expect(await names(false), ['A', 'B']);
    expect(await names(true), isEmpty);
  });

  group('filtros e ordenação', () {
    setUp(() async {
      await repo.create(
        CompanyInput(
          legalName: 'Zeta Química Ltda',
          tradeName: 'Água Pura',
          cnpj: cnpjA,
          enabledModules: {ModuleType.environmental},
          registrations: {
            Authority.ibama: reg(Authority.ibama),
            Authority.anvisa: reg(
              Authority.anvisa,
              RegistrationStatus.required,
            ),
          },
        ),
      );
      await repo.create(
        CompanyInput(
          legalName: 'Indústria São João',
          cnpj: cnpjB,
          enabledModules: {ModuleType.controlledProducts},
          registrations: {Authority.army: reg(Authority.army)},
        ),
      );
      await repo.create(const CompanyInput(legalName: 'beta comércio'));
    });

    Future<List<String>> names([
      CompanyFilter f = const CompanyFilter(),
    ]) async =>
        (await repo.watchAll(f).first).map((c) => c.displayName).toList();

    test('ordena por displayName sem acento e sem caixa', () async {
      expect(await names(), [
        'Água Pura',
        'beta comércio',
        'Indústria São João',
      ]);
    });

    test('query ignora acento e casa nome fantasia e razão social', () async {
      expect(await names(const CompanyFilter(query: 'sao joao')), [
        'Indústria São João',
      ]);
      expect(await names(const CompanyFilter(query: 'QUIMICA')), ['Água Pura']);
      expect(await names(const CompanyFilter(query: 'agua')), ['Água Pura']);
      expect(await names(const CompanyFilter(query: '   ')), hasLength(3));
    });

    test('query por CNPJ com máscara', () async {
      expect(await names(const CompanyFilter(query: '11.222.333/0001')), [
        'Água Pura',
      ]);
      expect(await names(const CompanyFilter(query: '12.abc')), [
        'Indústria São João',
      ]);
    });

    test('module', () async {
      expect(
        await names(const CompanyFilter(module: ModuleType.controlledProducts)),
        ['Indústria São João'],
      );
      expect(
        await names(const CompanyFilter(module: ModuleType.qualityControl)),
        isEmpty,
      );
    });

    test('authority e status', () async {
      expect(await names(const CompanyFilter(authority: Authority.anvisa)), [
        'Água Pura',
      ]);
      expect(
        await names(
          const CompanyFilter(
            authority: Authority.anvisa,
            status: RegistrationStatus.registered,
          ),
        ),
        isEmpty,
      );
      expect(
        await names(const CompanyFilter(status: RegistrationStatus.required)),
        ['Água Pura'],
      );
      expect(
        await names(const CompanyFilter(status: RegistrationStatus.registered)),
        ['Água Pura', 'Indústria São João'],
      );
    });
  });

  group('streams', () {
    test('watchAll emite de novo depois do update de um registro', () async {
      final a = await repo.create(
        CompanyInput(
          legalName: 'A',
          registrations: {Authority.ibama: reg(Authority.ibama)},
        ),
      );
      final emissions = <List<Company>>[];
      final sub = repo.watchAll().listen(emissions.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      expect(emissions, hasLength(1));

      await repo.update(
        a.id,
        CompanyInput(
          legalName: 'A',
          registrations: {
            Authority.ibama: reg(Authority.ibama, RegistrationStatus.required),
          },
        ),
      );
      await pumpEventQueue();

      expect(emissions, hasLength(2));
      expect(
        emissions.last.single.registrationFor(Authority.ibama)!.status,
        RegistrationStatus.required,
      );
    });

    test('watchById acompanha a empresa e vira null ao excluir', () async {
      final a = await repo.create(const CompanyInput(legalName: 'A'));
      final emissions = <Company?>[];
      final sub = repo.watchById(a.id).listen(emissions.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();

      await repo.update(a.id, const CompanyInput(legalName: 'A2'));
      await pumpEventQueue();
      await repo.delete(a.id);
      await pumpEventQueue();

      expect(emissions.map((c) => c?.legalName), ['A', 'A2', null]);
    });
  });

  test('delete some de watchAll e findById e exclui os filhos', () async {
    final a = await repo.create(
      CompanyInput(
        legalName: 'A',
        enabledModules: {ModuleType.environmental},
        registrations: {Authority.ibama: reg(Authority.ibama)},
      ),
    );
    tick();
    await repo.delete(a.id);

    expect(await repo.findById(a.id), isNull);
    expect(await repo.watchAll().first, isEmpty);
    final company = await db.select(db.companies).getSingle();
    final module = await db.select(db.companyModules).getSingle();
    final authority = await db.select(db.companyAuthorities).getSingle();
    expect(company.deletedAt, now);
    expect(module.deletedAt, now);
    expect(authority.deletedAt, now);
  });
}

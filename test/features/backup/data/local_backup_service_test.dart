import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/features/backup/data/local_backup_service.dart';
import 'package:normatrack/features/backup/domain/backup.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/measurements/data/local_measurement_repository.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/app/generated/schema.dart';

void main() {
  late Directory dir;
  late String dbPath;
  late AppDatabase current;
  late LocalBackupService service;
  late DateTime now;
  late int nextId;
  var failNextReopen = false;
  var reopens = 0;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  AppDatabase open() => AppDatabase(NativeDatabase(File(dbPath)));

  setUp(() {
    dir = Directory.systemTemp.createTempSync('normatrack_backup');
    dbPath = '${dir.path}/normatrack.sqlite';
    current = open();
    now = DateTime.utc(2026, 11, 26, 17, 5);
    nextId = 0;
    failNextReopen = false;
    reopens = 0;
    service = LocalBackupService(
      database: () => current,
      reopen: () async {
        reopens++;
        if (failNextReopen) {
          failNextReopen = false;
          throw StateError('falha simulada ao reabrir');
        }
        current = open();
      },
      databasePath: () async => dbPath,
      workDirectory: () async => '${dir.path}/work',
      exportDirectory: () async => '${dir.path}/export',
      clock: () => now,
    );
  });

  tearDown(() async {
    await current.close();
    dir.deleteSync(recursive: true);
  });

  LocalCompanyRepository companies() => LocalCompanyRepository(
    current,
    clock: () => now,
    newId: () => 'id-${++nextId}',
  );
  LocalDeadlineRepository deadlines() => LocalDeadlineRepository(
    current,
    clock: () => now,
    newId: () => 'id-${++nextId}',
  );

  Future<String> company(String name) async => (await companies().create(
    CompanyInput(legalName: name, enabledModules: {ModuleType.environmental}),
  )).id;

  Future<List<String>> names() async => [
    for (final row
        in await current
            .customSelect(
              'SELECT legal_name FROM companies WHERE deleted_at IS NULL '
              'ORDER BY legal_name',
            )
            .get())
      row.read<String>('legal_name'),
  ];

  /// Gera um backup com só a empresa [name] (num banco à parte) e devolve o
  /// caminho do arquivo copiado para a área de trabalho.
  Future<String> otherBackup(String name) async {
    final otherPath = '${dir.path}/outro.sqlite';
    final other = AppDatabase(NativeDatabase(File(otherPath)));
    await LocalCompanyRepository(
      other,
      clock: () => now,
      newId: () => 'outro-${++nextId}',
    ).create(CompanyInput(legalName: name));
    final staging = await service.stagingPath();
    await other.customStatement('VACUUM INTO ?', [staging]);
    await other.close();
    return staging;
  }

  Future<BackupFailure?> failureOf(Future<void> Function() body) async {
    try {
      await body();
      return null;
    } on BackupException catch (e) {
      return e.failure;
    }
  }

  group('create', () {
    test(
      'gera arquivo datado que o inspect aceita, com as contagens',
      () async {
        final alfa = await company('Alfa');
        final beta = await company('Beta');
        final gama = await company('Gama');
        await companies().archive(beta); // arquivada conta
        await companies().delete(gama); // excluída não conta
        final licenca = await deadlines().create(
          alfa,
          DeadlineInput(
            module: ModuleType.environmental,
            category: DeadlineCategory.license,
            title: 'Licença de operação',
            dueDate: DateTime.utc(2026, 12, 1),
          ),
        );
        now = DateTime.utc(2026, 11, 26, 18);
        await deadlines().renew(
          licenca.id,
          newDueDate: DateTime.utc(2027, 12, 1),
        );

        final file = await service.create();

        expect(file.name, backupFileName(now.toLocal()));
        expect(File(file.path).existsSync(), isTrue);
        final summary = await service.inspect(file.path);
        expect(
          summary,
          BackupSummary(
            schemaVersion: AppDatabase.currentSchemaVersion,
            companyCount: 2,
            deadlineCount: 1, // o renovado fica só no histórico
            lastChangeAt: DateTime.utc(2026, 11, 26, 18),
          ),
        );
      },
    );

    test('banco vazio: zero e sem data', () async {
      final file = await service.create();
      expect(
        await service.inspect(file.path),
        BackupSummary(
          schemaVersion: AppDatabase.currentSchemaVersion,
          companyCount: 0,
          deadlineCount: 0,
        ),
      );
    });

    test('esvazia a pasta de exportação a cada backup', () async {
      final first = await service.create();
      now = now.add(const Duration(minutes: 1));
      final second = await service.create();
      expect(File(first.path).existsSync(), isFalse);
      expect(File(second.path).existsSync(), isTrue);
    });
  });

  group('inspect recusa', () {
    test('bytes aleatórios', () async {
      final path = await service.stagingPath();
      final random = Random(42);
      File(
        path,
      ).writeAsBytesSync([for (var i = 0; i < 4096; i++) random.nextInt(256)]);
      expect(
        await failureOf(() => service.inspect(path)),
        BackupFailure.notABackup,
      );
    });

    test('SQLite de outro app', () async {
      final path = await service.stagingPath();
      sqlite3.open(path)
        ..execute('CREATE TABLE foo (id INTEGER)')
        ..execute('PRAGMA user_version = 1')
        ..close();
      expect(
        await failureOf(() => service.inspect(path)),
        BackupFailure.notABackup,
      );
    });

    test('SQLite sem user_version', () async {
      final path = await service.stagingPath();
      sqlite3.open(path)
        ..execute('CREATE TABLE companies (id TEXT)')
        ..close();
      expect(
        await failureOf(() => service.inspect(path)),
        BackupFailure.notABackup,
      );
    });

    test('v3 sem as tabelas de medições', () async {
      final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(2);
      final path = await service.stagingPath();
      schema.rawDatabase
        ..execute('PRAGMA user_version = 3')
        ..execute('VACUUM INTO ?', [path])
        ..close();
      expect(
        await failureOf(() => service.inspect(path)),
        BackupFailure.notABackup,
      );
    });

    test('versão mais nova que a do app', () async {
      final path = await otherBackup('Futuro');
      sqlite3.open(path)
        ..execute(
          'PRAGMA user_version = ${AppDatabase.currentSchemaVersion + 1}',
        )
        ..close();
      expect(
        await failureOf(() => service.inspect(path)),
        BackupFailure.newerVersion,
      );
    });

    test('arquivo inexistente', () async {
      expect(
        await failureOf(() => service.inspect('${dir.path}/nada.ntbackup')),
        BackupFailure.failed,
      );
    });
  });

  group('restore', () {
    test('troca os dados e guarda cópia; desfazer volta e refaz', () async {
      await company('Alfa');
      final staging = await otherBackup('Beta');

      await service.restore(staging);

      expect(await names(), ['Beta']);
      expect(File(staging).existsSync(), isFalse);
      expect(
        File('${dir.path}/work/${LocalBackupService.safetyName}').existsSync(),
        isTrue,
      );

      await service.undoRestore();
      expect(await names(), ['Alfa']);

      await service.undoRestore();
      expect(await names(), ['Beta']);
    });

    test('backup v1 é migrado para a versão atual', () async {
      await company('Alfa');
      final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(1);
      schema.rawDatabase
        ..execute(
          "INSERT INTO companies (id, created_at, updated_at, legal_name) "
          "VALUES ('v1', '2026-01-01T00:00:00.000Z', "
          "'2026-01-01T00:00:00.000Z', 'Antiga Ltda')",
        )
        ..execute('PRAGMA user_version = 1');
      final staging = await service.stagingPath();
      schema.rawDatabase.execute('VACUUM INTO ?', [staging]);
      schema.rawDatabase.close();

      expect(
        await service.inspect(staging),
        BackupSummary(
          schemaVersion: 1,
          companyCount: 1,
          deadlineCount: 0,
          lastChangeAt: DateTime.utc(2026),
        ),
      );
      await service.restore(staging);

      expect(await names(), ['Antiga Ltda']);
      final version = await current
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(
        version.read<int>('user_version'),
        AppDatabase.currentSchemaVersion,
      );
      await current.validateDatabaseSchema();
    });

    test('backup v2 com prazo é migrado para v3', () async {
      await company('Alfa');
      const at = '2026-11-20T10:00:00.000Z';
      final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(2);
      schema.rawDatabase
        ..execute(
          "INSERT INTO companies (id, created_at, updated_at, legal_name) "
          "VALUES ('v2', '$at', '$at', 'Alfa To To To To')",
        )
        ..execute(
          "INSERT INTO company_modules (id, created_at, updated_at, "
          "company_id, module_type, enabled) "
          "VALUES ('m2', '$at', '$at', 'v2', 'environmental', 1)",
        )
        ..execute(
          "INSERT INTO deadlines (id, created_at, updated_at, company_id, "
          "module, category, title, due_date, status) VALUES ('d2', '$at', "
          "'$at', 'v2', 'environmental', 'license', 'Licença de operação', "
          "'2027-03-31', 'active')",
        )
        ..execute(
          "INSERT INTO deadline_reminders (id, created_at, updated_at, "
          "deadline_id, days_before) VALUES ('r2', '$at', '$at', 'd2', 150)",
        )
        ..execute('PRAGMA user_version = 2');
      final staging = await service.stagingPath();
      schema.rawDatabase.execute('VACUUM INTO ?', [staging]);
      schema.rawDatabase.close();

      expect(
        await service.inspect(staging),
        BackupSummary(
          schemaVersion: 2,
          companyCount: 1,
          deadlineCount: 1,
          lastChangeAt: DateTime.utc(2026, 11, 20, 10),
        ),
      );
      await service.restore(staging);

      expect(await names(), ['Alfa To To To To']);
      final version = await current
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 3);
      await current.validateDatabaseSchema();
      final restored = await deadlines().findById('d2');
      expect(restored!.title, 'Licença de operação');
      expect(restored.dueDate, DateTime(2027, 3, 31));
      expect(restored.reminderDays, [150]);
      expect(
        await current.select(current.measurementParameters).get(),
        isEmpty,
      );
    });

    test('backup v3 com medições faz ida e volta', () async {
      final alfa = await company('Alfa');
      final repo = LocalMeasurementRepository(
        current,
        clock: () => now,
        newId: () => 'id-${++nextId}',
      );
      final ponto = await repo.createParameter(
        alfa,
        MeasurementContext.noise,
        MeasurementParameterInput(
          name: 'Portão principal',
          frequency: MeasurementFrequency.weekly,
          startDate: DateTime(2026, 11, 2),
          limitMax: 70,
        ),
      );
      now = DateTime.utc(2026, 11, 26, 18);
      await repo.savePeriod(
        MeasurementPeriod.containing(
          MeasurementFrequency.weekly,
          DateTime(2026, 11, 23),
        ),
        {ponto.id: const MeasurementEntry(value: 61.8, note: 'chuva')},
        today: DateTime(2026, 11, 26),
      );
      final file = await service.create();
      // A medição é a alteração mais recente.
      expect(
        (await service.inspect(file.path)).lastChangeAt,
        DateTime.utc(2026, 11, 26, 18),
      );

      final saved = File(file.path).copySync('${dir.path}/alfa.ntbackup');
      await service.restore(await otherBackup('Beta'));
      expect(await names(), ['Beta']);
      final staging = await service.stagingPath();
      saved.copySync(staging);
      await service.restore(staging);

      expect(await names(), ['Alfa']);
      final restored = await LocalMeasurementRepository(
        current,
        clock: () => now,
        newId: () => 'id-${++nextId}',
      ).watchMeasurements(alfa, MeasurementContext.noise).first;
      expect(restored.single.value, 61.8);
      expect(restored.single.note, 'chuva');
      expect(restored.single.periodStart, DateTime(2026, 11, 23));
    });

    test('falha ao reabrir volta aos dados atuais', () async {
      await company('Alfa');
      final staging = await otherBackup('Beta');
      failNextReopen = true;

      expect(
        await failureOf(() => service.restore(staging)),
        BackupFailure.failed,
      );

      expect(await names(), ['Alfa']);
      expect(File(staging).existsSync(), isFalse);
    });

    test('arquivo inválido não fecha o banco nem cria cópia', () async {
      await company('Alfa');
      final staging = await service.stagingPath();
      File(staging).writeAsStringSync('não é um banco');

      expect(
        await failureOf(() => service.restore(staging)),
        BackupFailure.notABackup,
      );

      expect(reopens, 0);
      expect(await names(), ['Alfa']);
      expect(
        File('${dir.path}/work/${LocalBackupService.safetyName}').existsSync(),
        isFalse,
      );
      expect(File(staging).existsSync(), isFalse);
    });

    test('desfazer sem restauração anterior falha', () async {
      expect(await failureOf(service.undoRestore), BackupFailure.failed);
    });
  });
}

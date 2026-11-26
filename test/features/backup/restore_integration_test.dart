import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/notification_sync.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/core/notifications/notification_providers.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/features/backup/data/local_backup_service.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../../helpers/fake_notification_scheduler.dart';
import '../../helpers/fake_notification_settings.dart';
import '../../helpers/pump_app.dart';

// Restauração de ponta a ponta com o banco em arquivo e os providers reais:
// depois de trocar o banco, a sincronização refaz os agendamentos com os
// prazos do backup.
void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('restaurar refaz as notificações com os prazos do backup', () async {
    final dir = Directory.systemTemp.createTempSync('normatrack_restore');
    addTearDown(() => dir.deleteSync(recursive: true));
    final dbPath = '${dir.path}/normatrack.sqlite';
    final scheduler = FakeNotificationScheduler();
    var nextId = 0;
    final container = ProviderContainer(
      overrides: [
        databasePathProvider.overrideWithValue(() async => dbPath),
        databaseOpenerProvider.overrideWithValue(
          () => AppDatabase(NativeDatabase(File(dbPath))),
        ),
        clockProvider.overrideWithValue(() => testNow),
        idGeneratorProvider.overrideWithValue(() => 'id-${++nextId}'),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        notificationSettingsProvider.overrideWithValue(
          FakeNotificationSettings(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final service = LocalBackupService(
      database: () => container.read(appDatabaseProvider),
      reopen: () async =>
          container.read(databaseEpochProvider.notifier).reopen(),
      databasePath: () async => dbPath,
      workDirectory: () async => '${dir.path}/work',
      exportDirectory: () async => '${dir.path}/export',
      clock: () => testNow,
    );

    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    Future<String> deadline(String company, String title) async {
      final c = await container
          .read(companyRepositoryProvider)
          .create(
            CompanyInput(
              legalName: company,
              enabledModules: {ModuleType.environmental},
            ),
          );
      final d = await container
          .read(deadlineRepositoryProvider)
          .create(
            c.id,
            DeadlineInput(
              module: ModuleType.environmental,
              category: DeadlineCategory.license,
              title: title,
              dueDate: DateTime.utc(2026, 11, 13),
            ),
          );
      return d.id;
    }

    Set<String> planned() => {
      for (final p in scheduler.lastPlan ?? const []) p.deadlineId,
    };

    container.listen(notificationSyncProvider, (_, _) {});

    // Backup só com o prazo "B".
    final b = await deadline('Beta', 'Licença B');
    final backup = await service.create();
    await container.read(deadlineRepositoryProvider).delete(b);
    final a = await deadline('Alfa', 'Licença A');
    await settle();
    expect(planned(), {a});

    final staging = await service.stagingPath();
    File(backup.path).copySync(staging);
    await service.restore(staging);
    await settle();

    expect(planned(), {b});
    expect(
      scheduler.lastPlan!.map((p) => p.body),
      everyElement(startsWith('Beta · ')),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/core/notifications/notification_providers.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/core/utils/clock.dart';
import 'package:normatrack/features/backup/data/local_backup_service.dart';
import 'package:normatrack/features/backup/data/platform_backup_files.dart';
import 'package:normatrack/features/backup/data/shared_prefs_backup_settings.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/measurements/data/local_measurement_repository.dart';
import 'package:normatrack/main.dart';

import 'fake_backup.dart';
import 'fake_company_repository.dart';
import 'fake_deadline_repository.dart';
import 'fake_measurement_repository.dart';
import 'fake_notification_scheduler.dart';
import 'fake_notification_settings.dart';

/// "Hoje" nos testes: 29/09/2026 em qualquer fuso do Brasil.
final testNow = DateTime.utc(2026, 9, 29, 12);

/// Monta o app inteiro numa tela de 390 × 844, com relógio fixo e os
/// repositórios em memória. [clock] troca o relógio fixo em [testNow] (ex.: um
/// relógio mutável para testar a virada do dia). Devolve o repositório de
/// empresas usado.
Future<FakeCompanyRepository> pumpApp(
  WidgetTester tester, {
  FakeCompanyRepository? repository,
  FakeDeadlineRepository? deadlineRepository,
  FakeMeasurementRepository? measurementRepository,
  FakeNotificationScheduler? notificationScheduler,
  FakeNotificationSettings? notificationSettings,
  FakeBackupService? backupService,
  FakeBackupFiles? backupFiles,
  FakeBackupSettings? backupSettings,
  String initialLocation = AppRoutes.dashboard,
  Clock? clock,
}) async {
  final repo = repository ?? FakeCompanyRepository(now: testNow);
  final deadlines =
      deadlineRepository ??
      FakeDeadlineRepository(now: testNow, companies: repo);
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        companyRepositoryProvider.overrideWithValue(repo),
        deadlineRepositoryProvider.overrideWithValue(deadlines),
        measurementRepositoryProvider.overrideWithValue(
          measurementRepository ??
              FakeMeasurementRepository(now: testNow, companies: repo),
        ),
        clockProvider.overrideWithValue(clock ?? () => testNow),
        notificationSchedulerProvider.overrideWithValue(
          notificationScheduler ?? FakeNotificationScheduler(),
        ),
        notificationSettingsProvider.overrideWithValue(
          notificationSettings ?? FakeNotificationSettings(),
        ),
        backupServiceProvider.overrideWithValue(
          backupService ?? FakeBackupService(),
        ),
        backupFilesProvider.overrideWithValue(backupFiles ?? FakeBackupFiles()),
        backupSettingsProvider.overrideWithValue(
          backupSettings ?? FakeBackupSettings(),
        ),
        routerProvider.overrideWith((ref) {
          final router = createAppRouter(initialLocation: initialLocation);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const NormaTrackApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

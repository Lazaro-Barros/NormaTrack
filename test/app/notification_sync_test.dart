import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/notification_sync.dart';
import 'package:normatrack/core/notifications/notification_providers.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../helpers/fake_company_repository.dart';
import '../helpers/fake_deadline_repository.dart';
import '../helpers/fake_notification_scheduler.dart';
import '../helpers/fake_notification_settings.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeDeadlineRepository deadlines;
  late FakeNotificationScheduler scheduler;
  late FakeNotificationSettings settings;
  late ProviderContainer container;
  late String alfa;

  DeadlineInput input(String title, DateTime due) => DeadlineInput(
    module: ModuleType.environmental,
    category: DeadlineCategory.license,
    title: title,
    dueDate: due,
  );

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Set<String> plannedDeadlines() => {
    for (final p in scheduler.lastPlan ?? const []) p.deadlineId,
  };

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    deadlines = FakeDeadlineRepository(now: testNow, companies: companies);
    scheduler = FakeNotificationScheduler();
    settings = FakeNotificationSettings();
    alfa = (await companies.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
    container = ProviderContainer(
      overrides: [
        companyRepositoryProvider.overrideWithValue(companies),
        deadlineRepositoryProvider.overrideWithValue(deadlines),
        clockProvider.overrideWithValue(() => testNow),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        notificationSettingsProvider.overrideWithValue(settings),
      ],
    );
    addTearDown(container.dispose);
  });

  void activate() => container.listen(notificationSyncProvider, (_, _) {});

  test('ao ativar, agenda o plano dos prazos em aberto', () async {
    final d = await deadlines.seed(
      alfa,
      input('Licença de Operação', DateTime(2026, 11, 13)),
    );
    activate();
    await settle();

    expect(scheduler.replaceCalls, greaterThanOrEqualTo(1));
    expect(plannedDeadlines(), {d.id});
    final bodies = scheduler.lastPlan!.map((p) => p.body);
    expect(
      bodies,
      contains('Indústria Alfa Ltda · Vence em 30 dias (13/11/2026)'),
    );
  });

  test('criar prazo reagenda incluindo o novo', () async {
    activate();
    await settle();
    expect(plannedDeadlines(), isEmpty);

    final d = await deadlines.seed(alfa, input('Nova', DateTime(2026, 12, 1)));
    await settle();
    expect(plannedDeadlines(), {d.id});
  });

  test('arquivar a empresa tira os prazos dela', () async {
    await deadlines.seed(alfa, input('Licença', DateTime(2026, 12, 1)));
    activate();
    await settle();
    expect(plannedDeadlines(), isNotEmpty);

    await companies.archive(alfa);
    await settle();
    expect(plannedDeadlines(), isEmpty);
  });

  test('desligar cancela; religar agenda de novo', () async {
    final d = await deadlines.seed(
      alfa,
      input('Licença', DateTime(2026, 12, 1)),
    );
    activate();
    await settle();

    await container.read(notificationsEnabledProvider.notifier).set(false);
    await settle();
    expect(scheduler.cancelCalls, greaterThanOrEqualTo(1));
    expect(plannedDeadlines(), isEmpty);
    expect(settings.enabled, isFalse);

    final before = scheduler.replaceCalls;
    await container.read(notificationsEnabledProvider.notifier).set(true);
    await settle();
    expect(scheduler.replaceCalls, greaterThan(before));
    expect(plannedDeadlines(), {d.id});
  });

  test('desligado desde o início não agenda', () async {
    settings.enabled = false;
    await deadlines.seed(alfa, input('Licença', DateTime(2026, 12, 1)));
    activate();
    await settle();
    expect(scheduler.replaceCalls, 0);
    expect(scheduler.cancelCalls, greaterThanOrEqualTo(1));
  });
}

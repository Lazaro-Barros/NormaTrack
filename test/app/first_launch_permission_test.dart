import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_notification_scheduler.dart';
import '../helpers/fake_notification_settings.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('primeira abertura pede a permissão uma vez e marca', (
    tester,
  ) async {
    final scheduler = FakeNotificationScheduler(enabled: false);
    final settings = FakeNotificationSettings(asked: false);
    await pumpApp(
      tester,
      notificationScheduler: scheduler,
      notificationSettings: settings,
    );

    expect(scheduler.permissionRequests, 1);
    expect(settings.asked, isTrue);
  });

  testWidgets('se já pediu, não pede de novo', (tester) async {
    final scheduler = FakeNotificationScheduler(enabled: false);
    await pumpApp(
      tester,
      notificationScheduler: scheduler,
      notificationSettings: FakeNotificationSettings(asked: true),
    );

    expect(scheduler.permissionRequests, 0);
  });

  testWidgets('com notificações desligadas, não pede', (tester) async {
    final scheduler = FakeNotificationScheduler(enabled: false);
    final settings = FakeNotificationSettings(enabled: false, asked: false);
    await pumpApp(
      tester,
      notificationScheduler: scheduler,
      notificationSettings: settings,
    );

    expect(scheduler.permissionRequests, 0);
    expect(settings.asked, isFalse);
  });
}

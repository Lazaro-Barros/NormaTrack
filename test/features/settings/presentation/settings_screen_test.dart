import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';

import '../../../helpers/fake_notification_scheduler.dart';
import '../../../helpers/fake_notification_settings.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeNotificationScheduler scheduler;
  late FakeNotificationSettings settings;

  setUp(() {
    scheduler = FakeNotificationScheduler();
    settings = FakeNotificationSettings();
  });

  Future<void> pumpSettings(WidgetTester tester) => pumpApp(
    tester,
    notificationScheduler: scheduler,
    notificationSettings: settings,
    initialLocation: AppRoutes.settings,
  );

  Switch theSwitch(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch));

  testWidgets('seção Alertas com o interruptor ligado por padrão', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('Alertas'), findsOneWidget);
    expect(find.text('Notificações de vencimento'), findsOneWidget);
    expect(
      find.text('Às 8h, nos dias de lembrete e toda semana depois de vencido'),
      findsOneWidget,
    );
    expect(theSwitch(tester).value, isTrue);
    expect(find.text('Bloqueadas no Android'), findsNothing);
  });

  testWidgets('desligar grava e cancela os agendamentos', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Notificações de vencimento'));
    await tester.pumpAndSettle();
    expect(theSwitch(tester).value, isFalse);
    expect(settings.enabled, isFalse);
    expect(scheduler.cancelCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('ligar com a permissão negada pede a permissão', (tester) async {
    settings.enabled = false;
    scheduler.enabled = false;
    await pumpSettings(tester);
    expect(theSwitch(tester).value, isFalse);

    await tester.tap(find.text('Notificações de vencimento'));
    await tester.pumpAndSettle();
    expect(settings.enabled, isTrue);
    expect(scheduler.permissionRequests, 1);
    expect(find.text('Bloqueadas no Android'), findsNothing); // concedida
  });

  testWidgets('permissão negada mostra o bloqueio, que abre as configurações', (
    tester,
  ) async {
    scheduler.enabled = false;
    scheduler.grantOnRequest = false;
    await pumpSettings(tester);

    expect(find.text('Bloqueadas no Android'), findsOneWidget);
    await tester.tap(find.text('Bloqueadas no Android'));
    await tester.pumpAndSettle();
    expect(scheduler.settingsOpened, 1);
  });

  testWidgets('desligado não mostra o bloqueio', (tester) async {
    settings.enabled = false;
    scheduler.enabled = false;
    await pumpSettings(tester);
    expect(find.text('Bloqueadas no Android'), findsNothing);
  });
}

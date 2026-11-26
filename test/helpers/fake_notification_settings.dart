import 'package:normatrack/core/notifications/notification_settings.dart';

/// Preferências em memória. Por padrão, ligado e com a permissão já pedida,
/// para que os testes de tela não vejam o pedido da primeira abertura.
class FakeNotificationSettings implements NotificationSettings {
  FakeNotificationSettings({this.enabled = true, this.asked = true});

  bool enabled;
  bool asked;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  Future<bool> wasPermissionAsked() async => asked;

  @override
  Future<void> markPermissionAsked() async => asked = true;
}

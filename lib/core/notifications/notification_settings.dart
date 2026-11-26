import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de notificação do aparelho (não são dados do domínio e não
/// entram no backup do banco).
abstract interface class NotificationSettings {
  /// Padrão: ligado.
  Future<bool> isEnabled();
  Future<void> setEnabled(bool value);

  /// Se o pedido de permissão da primeira abertura já foi feito.
  Future<bool> wasPermissionAsked();
  Future<void> markPermissionAsked();
}

class SharedPrefsNotificationSettings implements NotificationSettings {
  SharedPrefsNotificationSettings([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const enabledKey = 'notifications.enabled';
  static const permissionAskedKey = 'notifications.permission_asked';

  final SharedPreferencesAsync _prefs;

  @override
  Future<bool> isEnabled() async => await _prefs.getBool(enabledKey) ?? true;

  @override
  Future<void> setEnabled(bool value) => _prefs.setBool(enabledKey, value);

  @override
  Future<bool> wasPermissionAsked() async =>
      await _prefs.getBool(permissionAskedKey) ?? false;

  @override
  Future<void> markPermissionAsked() =>
      _prefs.setBool(permissionAskedKey, true);
}

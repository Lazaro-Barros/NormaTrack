import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/notifications/notification_settings.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('padrões: ligado e permissão ainda não pedida', () async {
    final settings = SharedPrefsNotificationSettings();
    expect(await settings.isEnabled(), isTrue);
    expect(await settings.wasPermissionAsked(), isFalse);
  });

  test('grava e lê', () async {
    final settings = SharedPrefsNotificationSettings();
    await settings.setEnabled(false);
    await settings.markPermissionAsked();
    final again = SharedPrefsNotificationSettings();
    expect(await again.isEnabled(), isFalse);
    expect(await again.wasPermissionAsked(), isTrue);
  });
}

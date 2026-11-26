import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/backup/data/shared_prefs_backup_settings.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('sem backup: null', () async {
    expect(await SharedPrefsBackupSettings().lastBackupAt(), isNull);
  });

  test('grava e lê a data em UTC', () async {
    await SharedPrefsBackupSettings().setLastBackupAt(
      DateTime.utc(2026, 11, 26, 17, 30),
    );
    final read = await SharedPrefsBackupSettings().lastBackupAt();
    expect(read, DateTime.utc(2026, 11, 26, 17, 30));
    expect(read!.isUtc, isTrue);
  });
}

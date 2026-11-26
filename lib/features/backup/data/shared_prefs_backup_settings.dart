import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/backup.dart';

/// Preferências de backup do aparelho. Sobrescrito nos testes.
final backupSettingsProvider = Provider<BackupSettings>(
  (ref) => SharedPrefsBackupSettings(),
);

class SharedPrefsBackupSettings implements BackupSettings {
  SharedPrefsBackupSettings([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const lastAtKey = 'backup.last_at';

  final SharedPreferencesAsync _prefs;

  @override
  Future<DateTime?> lastBackupAt() async {
    final value = await _prefs.getString(lastAtKey);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  @override
  Future<void> setLastBackupAt(DateTime at) =>
      _prefs.setString(lastAtKey, at.toUtc().toIso8601String());
}

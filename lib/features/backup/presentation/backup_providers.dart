import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shared_prefs_backup_settings.dart';

/// Data do último backup compartilhado neste aparelho; `null` se nunca.
final lastBackupAtProvider =
    AsyncNotifierProvider<LastBackupAtNotifier, DateTime?>(
      LastBackupAtNotifier.new,
    );

class LastBackupAtNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() => ref.watch(backupSettingsProvider).lastBackupAt();

  /// Grava e atualiza o estado.
  Future<void> record(DateTime at) async {
    state = AsyncData(at);
    await ref.read(backupSettingsProvider).setLastBackupAt(at);
  }
}

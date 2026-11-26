import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_scheduler.dart';
import 'notification_settings.dart';

/// Agendador de notificações. Sobrescrito em `main.dart` com a instância criada
/// antes do `runApp`, e nos testes com um falso.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) =>
      throw UnimplementedError('notificationSchedulerProvider não configurado'),
);

/// Preferências de notificação do aparelho.
final notificationSettingsProvider = Provider<NotificationSettings>(
  (ref) => SharedPrefsNotificationSettings(),
);

/// Notificações ligadas ou desligadas (Ajustes).
final notificationsEnabledProvider =
    AsyncNotifierProvider<NotificationsEnabledNotifier, bool>(
      NotificationsEnabledNotifier.new,
    );

class NotificationsEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(notificationSettingsProvider).isEnabled();

  /// Grava e atualiza o estado.
  Future<void> set(bool value) async {
    state = AsyncData(value);
    await ref.read(notificationSettingsProvider).setEnabled(value);
  }
}

/// Permissão de notificação do sistema. Invalidar ao voltar para o app.
final notificationPermissionProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationSchedulerProvider).areEnabled(),
);

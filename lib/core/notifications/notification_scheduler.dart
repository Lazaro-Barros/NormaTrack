import 'deadline_notification_planner.dart';

/// Agenda as notificações de prazo no aparelho. A implementação real usa
/// `flutter_local_notifications`; os testes usam um falso.
abstract interface class NotificationScheduler {
  /// Toques em notificações com o app aberto ou em segundo plano. O valor é o
  /// id do prazo.
  Stream<String> get taps;

  /// Id do prazo da notificação que abriu o app fechado; `null` se o app não
  /// foi aberto por uma.
  Future<String?> launchPayload();

  /// Permissão de notificação concedida (Android 13+). `true` onde não há
  /// permissão a pedir.
  Future<bool> areEnabled();

  /// Mostra o pedido do sistema e devolve se a permissão ficou concedida.
  Future<bool> requestPermission();

  /// Abre as configurações de notificação do app no aparelho.
  Future<void> openSystemSettings();

  /// Cancela os agendamentos pendentes e agenda [plan]. Não remove as
  /// notificações já exibidas.
  Future<void> replaceAll(List<PlannedNotification> plan);

  /// Cancela os agendamentos pendentes.
  Future<void> cancelAll();
}

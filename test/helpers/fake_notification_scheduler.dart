import 'dart:async';

import 'package:normatrack/core/notifications/deadline_notification_planner.dart';
import 'package:normatrack/core/notifications/notification_scheduler.dart';

/// Agendador em memória: guarda o último plano e conta as chamadas.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({
    this.enabled = true,
    this.grantOnRequest = true,
    this.launch,
  });

  /// Permissão do sistema.
  bool enabled;

  /// O que o "usuário" responde ao pedido de permissão.
  bool grantOnRequest;

  /// Id do prazo da notificação que "abriu" o app.
  String? launch;

  List<PlannedNotification>? lastPlan;
  var replaceCalls = 0;
  var cancelCalls = 0;
  var permissionRequests = 0;
  var settingsOpened = 0;
  final _taps = StreamController<String>.broadcast();

  /// Simula o toque numa notificação do prazo [deadlineId].
  void tap(String deadlineId) => _taps.add(deadlineId);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchPayload() async => launch;

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grantOnRequest) enabled = true;
    return enabled;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;

  @override
  Future<void> replaceAll(List<PlannedNotification> plan) async {
    replaceCalls++;
    lastPlan = List.unmodifiable(plan);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    lastPlan = const [];
  }
}

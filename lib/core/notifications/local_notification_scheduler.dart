import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'deadline_notification_planner.dart';
import 'latest_only_runner.dart';
import 'notification_scheduler.dart';

/// [NotificationScheduler] com `flutter_local_notifications`: agendamento
/// inexato (sem permissão de alarme exato) no fuso do aparelho.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler._(this._plugin) {
    _runner = LatestOnlyRunner(_apply);
  }

  final FlutterLocalNotificationsPlugin _plugin;
  late final LatestOnlyRunner<List<PlannedNotification>> _runner;
  final _taps = StreamController<String>.broadcast();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'prazos',
      'Vencimento de prazos',
      channelDescription: 'Avisos nos dias de lembrete de cada prazo',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Carrega os fusos, fixa o fuso local e inicializa o plugin.
  static Future<LocalNotificationScheduler> create() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Fuso do aparelho indisponível ($e); usando São Paulo.');
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    }
    final scheduler = LocalNotificationScheduler._(
      FlutterLocalNotificationsPlugin(),
    );
    await scheduler._plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) scheduler._taps.add(payload);
      },
    );
    return scheduler;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  @override
  Future<bool> areEnabled() async =>
      await _android?.areNotificationsEnabled() ?? true;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<void> openSystemSettings() async {
    await _plugin.openAppNotificationSettings();
  }

  /// Substituições seguidas rodam uma por vez; só o plano mais recente é
  /// aplicado depois da que está em andamento.
  @override
  Future<void> replaceAll(List<PlannedNotification> plan) => _runner.run(plan);

  @override
  Future<void> cancelAll() => _runner.run(const []);

  Future<void> _apply(List<PlannedNotification> plan) async {
    await _plugin.cancelAllPendingNotifications();
    for (final n in plan) {
      final at = n.fireAt;
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime(
          tz.local,
          at.year,
          at.month,
          at.day,
          at.hour,
        ),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.deadlineId,
        matchDateTimeComponents: n.weekly
            ? DateTimeComponents.dayOfWeekAndTime
            : null,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final plugin = FlutterLocalNotificationsPlugin();
String log = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  final info = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(info.identifier));
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (r) => debugPrint('SPIKE tap ${r.payload}'),
  );
  final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!;
  final granted = await android.requestNotificationsPermission();
  final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 20));
  await plugin.zonedSchedule(
    id: 1,
    scheduledDate: when,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails('prazos', 'Vencimentos de prazos'),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: 'Licença de Operação',
    body: 'Indústria Alfa Ltda · vence em 10 dias',
    payload: '/empresas/x',
  );
  final weekly = tz.TZDateTime(tz.local, when.year, when.month, when.day + 7, 8);
  await plugin.zonedSchedule(
    id: 2,
    scheduledDate: weekly,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails('prazos', 'Vencimentos de prazos'),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: 'semanal',
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  );
  final pending = await plugin.pendingNotificationRequests();
  final prefs = await SharedPreferencesAsync().getBool('x');
  log = 'tz=${info.identifier} granted=$granted pending=${pending.length} prefs=$prefs enabled=${await android.areNotificationsEnabled()}';
  debugPrint('SPIKE $log');
  runApp(MaterialApp(home: Scaffold(body: Center(child: Text(log)))));
}

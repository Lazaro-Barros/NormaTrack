import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/notification_sync.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/notifications/local_notification_scheduler.dart';
import 'core/notifications/notification_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final scheduler = await LocalNotificationScheduler.create();
  runApp(
    ProviderScope(
      overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
      child: const NormaTrackApp(),
    ),
  );
}

class NormaTrackApp extends ConsumerWidget {
  const NormaTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationSyncProvider);
    return MaterialApp.router(
      title: 'NormaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}

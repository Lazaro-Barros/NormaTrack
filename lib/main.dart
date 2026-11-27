import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/notification_navigation.dart';
import 'app/notification_sync.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/notifications/local_notification_scheduler.dart';
import 'core/notifications/notification_providers.dart';
import 'core/today.dart';
import 'features/deadlines/data/local_deadline_repository.dart';

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

class NormaTrackApp extends ConsumerStatefulWidget {
  const NormaTrackApp({super.key});

  @override
  ConsumerState<NormaTrackApp> createState() => _NormaTrackAppState();
}

class _NormaTrackAppState extends ConsumerState<NormaTrackApp> {
  StreamSubscription<String>? _taps;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A data de hoje vira ao voltar o app para a frente (o timer da
    // meia-noite pode atrasar com o app em segundo plano).
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(todayProvider.notifier).refresh(),
    );
    final scheduler = ref.read(notificationSchedulerProvider);
    _taps = scheduler.taps.listen(_open);
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterFirstFrame());
  }

  @override
  void dispose() {
    _taps?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _afterFirstFrame() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    final launch = await scheduler.launchPayload();
    if (launch != null) await _open(launch);
    await _askPermissionOnce();
  }

  // TODO(RF-PRZ-03): permissão pedida uma vez na primeira abertura (suposição,
  // C4); depois, só pela tela de Ajustes.
  Future<void> _askPermissionOnce() async {
    final settings = ref.read(notificationSettingsProvider);
    if (await settings.wasPermissionAsked()) return;
    if (!await settings.isEnabled()) return;
    await settings.markPermissionAsked();
    await ref.read(notificationSchedulerProvider).requestPermission();
  }

  Future<void> _open(String deadlineId) => openDeadlineFromNotification(
    ref.read(routerProvider),
    ref.read(deadlineRepositoryProvider),
    deadlineId,
  );

  @override
  Widget build(BuildContext context) {
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

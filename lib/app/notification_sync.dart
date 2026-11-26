import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/deadline_notification_planner.dart';
import '../core/notifications/notification_providers.dart';
import '../core/providers.dart';
import '../features/deadlines/presentation/deadline_providers.dart';

/// Mantém os agendamentos iguais ao plano dos prazos em aberto (RF-PRZ-03).
/// Refaz tudo a cada mudança em prazos, empresas ou no ajuste, e na abertura do
/// app. Ativado por `ref.watch` no `NormaTrackApp`.
final notificationSyncProvider = Provider.autoDispose<void>((ref) {
  final enabled = ref.watch(notificationsEnabledProvider);
  final deadlines = ref.watch(upcomingDeadlinesProvider);
  final names = ref.watch(companyNamesProvider);
  final scheduler = ref.read(notificationSchedulerProvider);

  final isEnabled = enabled.value;
  if (isEnabled == null || enabled.hasError) return;
  if (!isEnabled) {
    unawaited(scheduler.cancelAll().catchError(_log));
    return;
  }
  final list = deadlines.value;
  final map = names.value;
  if (list == null || map == null || deadlines.hasError || names.hasError) {
    return;
  }
  final now = ref.read(clockProvider)().toLocal();
  unawaited(
    scheduler
        .replaceAll(planDeadlineNotifications(list, map, now))
        .catchError(_log),
  );
});

void _log(Object e) => debugPrint('Falha ao agendar notificações: $e');

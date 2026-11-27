import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Data local de hoje, sem hora. Vira sozinha à meia-noite (timer) e quando o
/// app volta para a frente (`refresh`, chamado pelo `NormaTrackApp`).
final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final now = ref.watch(clockProvider)();
    _schedule(now);
    return _dateOf(now);
  }

  /// Relê o relógio e reagenda a virada; só notifica se a data mudou.
  void refresh() {
    final now = ref.read(clockProvider)();
    _schedule(now);
    final today = _dateOf(now);
    if (today != state) state = today;
  }

  void _schedule(DateTime now) {
    _timer?.cancel();
    final local = now.toLocal();
    final midnight = DateTime(local.year, local.month, local.day + 1);
    // Um segundo depois da meia-noite; se disparar cedo, `refresh` só
    // reagenda.
    _timer = Timer(
      midnight.difference(local) + const Duration(seconds: 1),
      refresh,
    );
  }

  static DateTime _dateOf(DateTime now) {
    final local = now.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

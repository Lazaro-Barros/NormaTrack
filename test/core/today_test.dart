import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/core/today.dart';

void main() {
  // `testWidgets` roda em tempo simulado: o timer da meia-noite dispara com
  // `tester.pump(duração)`.
  late DateTime now;
  late ProviderContainer container;

  // O contêiner é descartado dentro do teste: a checagem de timers pendentes
  // roda antes do `tearDown`. Descartar cancela o timer.
  void start() {
    now = DateTime(2026, 9, 29, 23, 59, 30);
    container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
  }

  testWidgets('data local sem hora', (tester) async {
    start();
    expect(container.read(todayProvider), DateTime(2026, 9, 29));
    container.dispose();
  });

  testWidgets('vira o dia sozinha à meia-noite', (tester) async {
    start();
    final seen = <DateTime>[];
    container.listen(todayProvider, (_, next) => seen.add(next));
    expect(container.read(todayProvider), DateTime(2026, 9, 29));

    await tester.pump(const Duration(seconds: 20));
    expect(seen, isEmpty);

    now = DateTime(2026, 9, 30, 0, 0, 1);
    await tester.pump(const Duration(seconds: 20));
    expect(seen, [DateTime(2026, 9, 30)]);

    // E reagenda para a meia-noite seguinte.
    now = DateTime(2026, 10, 1, 0, 0, 1);
    await tester.pump(const Duration(days: 1));
    expect(seen, [DateTime(2026, 9, 30), DateTime(2026, 10, 1)]);
    container.dispose();
  });

  testWidgets('refresh só notifica quando a data muda', (tester) async {
    start();
    final seen = <DateTime>[];
    container.listen(todayProvider, (_, next) => seen.add(next));
    container.read(todayProvider);

    now = DateTime(2026, 9, 29, 23, 59, 50);
    container.read(todayProvider.notifier).refresh();
    expect(seen, isEmpty);

    now = DateTime(2026, 10, 2, 8);
    container.read(todayProvider.notifier).refresh();
    expect(seen, [DateTime(2026, 10, 2)]);
    container.dispose();
  });
}

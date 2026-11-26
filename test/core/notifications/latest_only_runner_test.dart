import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/notifications/latest_only_runner.dart';

void main() {
  test('uma por vez e só o mais recente depois da que está rodando', () async {
    final applied = <int>[];
    final gates = <int, Completer<void>>{};
    var running = 0;
    var maxRunning = 0;
    final runner = LatestOnlyRunner<int>((v) async {
      running++;
      maxRunning = running > maxRunning ? running : maxRunning;
      applied.add(v);
      await (gates[v] = Completer<void>()).future;
      running--;
    });

    final first = runner.run(1);
    await Future<void>.delayed(Duration.zero);
    runner.run(2);
    final last = runner.run(3);
    expect(identical(first, last), isTrue);

    gates[1]!.complete();
    await Future<void>.delayed(Duration.zero);
    gates[3]!.complete();
    await last;

    expect(applied, [1, 3]);
    expect(maxRunning, 1);
  });

  test('erro libera para a próxima execução', () async {
    final applied = <int>[];
    final runner = LatestOnlyRunner<int>((v) async {
      applied.add(v);
      if (v == 1) throw StateError('falhou');
    });
    await expectLater(runner.run(1), throwsStateError);
    await runner.run(2);
    expect(applied, [1, 2]);
  });
}

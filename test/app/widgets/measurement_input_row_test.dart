import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/measurement_input_row.dart';
import 'package:normatrack/app/widgets/status_text.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/text_scalers.dart';

void main() {
  late TextEditingController controller;
  late int skips;
  late int undos;

  setUp(() {
    controller = TextEditingController();
    skips = 0;
    undos = 0;
  });

  Widget row({
    String? previous = 'Anterior: 61,8',
    String? limit,
    String? error,
    String? skipped,
  }) => MeasurementInputRow(
    number: 2,
    name: 'Divisa norte',
    previousLabel: previous,
    controller: controller,
    unit: 'dB(A)',
    fieldLabel: 'Valor no ponto 2',
    limitLabel: limit,
    errorText: error,
    skippedReason: skipped,
    menuLabel: 'Sem medição neste ponto',
    onSkip: () => skips++,
    onUndoSkip: () => undos++,
  );

  testWidgets('número, nome, anterior, unidade e campo', (tester) async {
    await pumpComponent(tester, row());
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Divisa norte'), findsOneWidget);
    expect(find.text('Anterior: 61,8'), findsOneWidget);
    expect(find.text('dB(A)'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Valor no ponto 2')), findsOneWidget);

    await tester.enterText(find.byType(TextField), '72.5');
    expect(controller.text, '72,5');
  });

  testWidgets('aviso de limite com ícone e erro abaixo', (tester) async {
    await pumpComponent(
      tester,
      row(limit: 'Acima do limite (70,0)', error: 'Valor inválido'),
    );
    expect(find.byType(StatusText), findsOneWidget);
    expect(
      find.bySemanticsLabel('Situação: Acima do limite (70,0)'),
      findsOneWidget,
    );
    expect(find.text('Valor inválido'), findsOneWidget);
  });

  testWidgets('menu marca sem medição', (tester) async {
    await pumpComponent(tester, row());
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sem medição neste ponto'));
    await tester.pumpAndSettle();
    expect(skips, 1);
  });

  testWidgets('sem medição: motivo, sem campo, Desfazer', (tester) async {
    await pumpComponent(
      tester,
      row(skipped: 'Ponto inacessível', limit: 'Acima do limite (70,0)'),
    );
    expect(find.text('Sem medição: Ponto inacessível'), findsOneWidget);
    expect(find.text('Anterior: 61,8'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(StatusText), findsNothing);
    await tester.tap(find.text('Desfazer'));
    expect(undos, 1);
  });

  for (final (name, scaler) in [
    ('2×', const TextScaler.linear(2)),
    ('não linear', const NonLinearScaler()),
  ]) {
    testWidgets('fonte $name sem estouro (390 de largura)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpComponent(
        tester,
        withTextScaler(
          scaler,
          ListView(
            children: [
              row(limit: 'Acima do limite (70,0)'),
              row(skipped: 'Fábrica parada por manutenção geral'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

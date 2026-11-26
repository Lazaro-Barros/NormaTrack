import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('abre no Painel e navega pela barra inferior', (tester) async {
    await pumpApp(tester);

    expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
    final bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final label in ['Painel', 'Empresas', 'Ajustes']) {
      expect(
        find.descendant(of: bar, matching: find.text(label)),
        findsOneWidget,
      );
    }

    await tester.tap(find.descendant(of: bar, matching: find.text('Empresas')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma empresa cadastrada'), findsOneWidget);

    await tester.tap(find.descendant(of: bar, matching: find.text('Ajustes')));
    await tester.pumpAndSettle();
    expect(find.text('Alertas'), findsOneWidget);
  });

  testWidgets('ação do Painel abre Empresas', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ver empresas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum prazo em aberto'), findsNothing);
    expect(find.text('Nenhuma empresa cadastrada'), findsOneWidget);
  });
}

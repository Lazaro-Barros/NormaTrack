import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('abre no Painel e navega pela barra inferior', (tester) async {
    await pumpApp(tester);

    expect(find.text('Painel em construção'), findsOneWidget);
    final bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final label in ['Painel', 'Empresas', 'Ajustes']) {
      expect(
        find.descendant(of: bar, matching: find.text(label)),
        findsOneWidget,
      );
    }

    await tester.tap(find.descendant(of: bar, matching: find.text('Ajustes')));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes em construção'), findsOneWidget);
  });

  testWidgets('ação do Painel abre Empresas', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ver empresas'));
    await tester.pumpAndSettle();
    expect(find.text('Painel em construção'), findsNothing);
    expect(find.text('Empresas'), findsWidgets);
  });
}

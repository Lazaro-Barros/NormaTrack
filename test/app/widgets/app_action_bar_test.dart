import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/app_action_bar.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra os filhos', (tester) async {
    await pumpComponent(
      tester,
      AppActionBar(
        children: [
          OutlinedButton(onPressed: () {}, child: const Text('Cancelar')),
          Expanded(
            child: FilledButton(onPressed: () {}, child: const Text('Salvar')),
          ),
        ],
      ),
    );

    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets('sobe junto com o teclado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: AppActionBar(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Salvar')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getRect(find.text('Salvar')).bottom,
      lessThanOrEqualTo(tester.getSize(find.byType(Scaffold)).height - 300),
    );
  });
}

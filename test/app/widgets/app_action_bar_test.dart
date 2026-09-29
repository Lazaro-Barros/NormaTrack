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
}

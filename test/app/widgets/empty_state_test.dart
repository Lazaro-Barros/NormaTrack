import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/empty_state.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('sem ação não mostra botão', (tester) async {
    await pumpComponent(
      tester,
      const EmptyState(
        icon: Icons.inbox,
        title: 'Vazio',
        message: 'Nada aqui.',
      ),
    );

    expect(find.text('Vazio'), findsOneWidget);
    expect(find.text('Nada aqui.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('com ação, tocar chama o callback', (tester) async {
    var taps = 0;
    await pumpComponent(
      tester,
      EmptyState(
        icon: Icons.inbox,
        title: 'Vazio',
        message: 'Nada aqui.',
        actionLabel: 'Criar',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.text('Criar'));
    expect(taps, 1);
  });
}

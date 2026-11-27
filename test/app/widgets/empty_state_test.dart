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

  testWidgets('conteúdo fica dentro de um card', (tester) async {
    await pumpComponent(
      tester,
      const EmptyState(icon: Icons.inbox, title: 'Vazio', message: 'Nada.'),
    );

    expect(
      find.ancestor(of: find.text('Vazio'), matching: find.byType(Card)),
      findsOneWidget,
    );
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

  testWidgets('inline: só o card, dentro de uma lista', (tester) async {
    await pumpComponent(
      tester,
      ListView(
        children: const [
          Text('Outra seção'),
          EmptyState(
            icon: Icons.inbox,
            title: 'Vazio',
            message: 'Nada.',
            inline: true,
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Vazio'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Vazio'),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
  });
}

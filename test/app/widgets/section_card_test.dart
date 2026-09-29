import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/section_card.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('título, legenda, descrição e uma divisória a menos', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const SectionCard(
        title: 'Órgãos',
        caption: '3 de 9 se aplicam',
        description: 'Toque em um órgão.',
        children: [Text('a'), Text('b'), Text('c')],
      ),
    );

    expect(find.text('Órgãos'), findsOneWidget);
    expect(find.text('3 de 9 se aplicam'), findsOneWidget);
    expect(find.text('Toque em um órgão.'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.byType(Card), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/deadline_card.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('bloco de data, textos e cor da situação', (tester) async {
    await pumpComponent(
      tester,
      DeadlineCard(
        date: DateTime(2026, 9, 21),
        title: 'Licença de Operação',
        subtitle: 'Licença · SEMACE',
        tone: StatusTone.overdue,
        statusLead: 'Venceu',
        statusText: 'há 3 dias',
      ),
    );

    expect(find.text('21'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
    expect(find.text('Licença de Operação'), findsOneWidget);
    expect(find.text('Licença · SEMACE'), findsOneWidget);
    for (final t in ['Venceu', 'há 3 dias']) {
      expect(tester.widget<Text>(find.text(t)).style?.color, AppColors.overdue);
    }
    final block = tester.widget<Container>(
      find
          .ancestor(of: find.text('21'), matching: find.byType(Container))
          .first,
    );
    expect((block.decoration! as BoxDecoration).color, AppColors.overdue);
    expect(
      tester.widget<Text>(find.text('21')).style?.color,
      AppColors.onPrimary,
    );
  });

  testWidgets('showYear põe o ano ao lado do mês e dia com dois dígitos', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      DeadlineCard(
        date: DateTime(2028, 3, 5),
        showYear: true,
        title: 'Laudo',
        tone: StatusTone.ok,
        statusText: 'Em 1 ano',
      ),
    );

    expect(find.text('05'), findsOneWidget);
    expect(find.text('MAR 28'), findsOneWidget);
    expect(find.text('Em 1 ano'), findsOneWidget);
  });

  testWidgets('toque e rótulo semântico', (tester) async {
    var taps = 0;
    await pumpComponent(
      tester,
      DeadlineCard(
        date: DateTime(2026, 10, 31),
        title: 'Licença de Operação',
        tone: StatusTone.dueSoon,
        statusLead: 'Vence',
        statusText: 'em 32 dias',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(DeadlineCard));
    expect(taps, 1);
    expect(
      find.bySemanticsLabel(
        'Licença de Operação, vence em 31/10/2026, Vence em 32 dias',
      ),
      findsOneWidget,
    );
  });
}

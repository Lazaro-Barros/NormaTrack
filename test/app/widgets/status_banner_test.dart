import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/status_banner.dart';

import '../../helpers/pump_widget.dart';

Color? _bg(WidgetTester tester) {
  final c = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(StatusBanner),
          matching: find.byType(Container),
        )
        .first,
  );
  return (c.decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('título e mensagem aparecem', (tester) async {
    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.overdue,
        date: DateTime(2026, 9, 26),
        title: 'Venceu há 3 dias',
        message: 'Alertas desde 29/04/2026',
      ),
    );
    expect(find.text('Venceu há 3 dias'), findsOneWidget);
    expect(find.text('Alertas desde 29/04/2026'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
  });

  testWidgets('sem mensagem não ocupa linha; semântica junta os textos', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.ok,
        date: DateTime(2026, 9, 26),
        title: 'Em 120 dias',
      ),
    );
    expect(find.byType(Text), findsNWidgets(3)); // dia, mês, título
    expect(find.bySemanticsLabel('Em 120 dias'), findsOneWidget);

    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.ok,
        date: DateTime(2026, 9, 26),
        title: 'Em 120 dias',
        message: 'Alertas desde 01/01/2026',
      ),
    );
    expect(
      find.bySemanticsLabel('Em 120 dias. Alertas desde 01/01/2026'),
      findsOneWidget,
    );
  });

  testWidgets('cada tom usa o fundo suave', (tester) async {
    for (final tone in StatusTone.values) {
      await pumpComponent(
        tester,
        StatusBanner(tone: tone, date: DateTime(2026, 9, 26), title: 'x'),
      );
      final expected = StatusColors.light.resolve(tone).background;
      expect(_bg(tester), expected);
    }
  });
}

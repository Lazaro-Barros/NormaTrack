import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/stat_tile.dart';

import '../../helpers/pump_widget.dart';

void main() {
  Finder tileBox() => find
      .descendant(of: find.byType(StatTile), matching: find.byType(Container))
      .first;

  testWidgets('mostra o número, o rótulo e o ícone do tom', (tester) async {
    await pumpComponent(
      tester,
      const StatTile(tone: StatusTone.overdue, count: 3, label: 'Vencidos'),
    );
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Vencidos'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('altura fixa', (tester) async {
    await pumpComponent(
      tester,
      const StatTile(tone: StatusTone.ok, count: 1, label: 'Vigentes'),
    );
    expect(tester.getSize(find.byType(StatTile)).height, StatTile.height);
  });

  testWidgets('cores do tom: fundo suave e texto forte', (tester) async {
    await pumpComponent(
      tester,
      const StatTile(tone: StatusTone.overdue, count: 3, label: 'Vencidos'),
    );
    const style = StatusColors.light;
    final box = tester.widget<Container>(tileBox());
    expect((box.decoration! as BoxDecoration).color, style.overdue.background);
    expect(
      tester.widget<Text>(find.text('3')).style?.color,
      style.overdue.foreground,
    );
    expect(
      tester.widget<Text>(find.text('Vencidos')).style?.color,
      style.overdue.foreground,
    );
  });

  testWidgets('anel só quando selecionado', (tester) async {
    await pumpComponent(
      tester,
      const StatTile(tone: StatusTone.dueSoon, count: 2, label: 'A vencer'),
    );
    expect(tester.widget<Container>(tileBox()).foregroundDecoration, isNull);

    await pumpComponent(
      tester,
      const StatTile(
        tone: StatusTone.dueSoon,
        count: 2,
        label: 'A vencer',
        selected: true,
      ),
    );
    final ring =
        tester.widget<Container>(tileBox()).foregroundDecoration!
            as BoxDecoration;
    expect(ring.border, isNotNull);
    expect(
      (ring.border! as Border).top.color,
      StatusColors.light.dueSoon.foreground,
    );
    expect(tester.getSize(find.byType(StatTile)).height, StatTile.height);
  });

  testWidgets('tocar dispara onTap, inclusive com contagem 0', (tester) async {
    var taps = 0;
    await pumpComponent(
      tester,
      StatTile(
        tone: StatusTone.overdue,
        count: 0,
        label: 'Vencidos',
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(StatTile));
    expect(taps, 1);
  });

  testWidgets('semântica: botão com contagem e rótulo', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpComponent(
      tester,
      StatTile(
        tone: StatusTone.overdue,
        count: 3,
        label: 'Vencidos',
        selected: true,
        onTap: () {},
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('3 Vencidos')),
      matchesSemantics(
        label: '3 Vencidos',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
    handle.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/pending_row.dart';
import 'package:normatrack/app/widgets/status_chip.dart';
import 'package:normatrack/app/widgets/status_text.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/text_scalers.dart';

void main() {
  var launches = 0;

  Widget row({
    String? subtitle = 'Semana 46 · 09 a 15/11/2026',
    StatusTone tone = StatusTone.overdue,
    String status = '2 semanas atrasadas',
  }) => PendingRow(
    icon: Icons.graphic_eq,
    title: 'Ruídos · Indústria Alfa Ltda',
    subtitle: subtitle,
    statusLabel: status,
    tone: tone,
    onLaunch: () => launches++,
  );

  setUp(() => launches = 0);

  testWidgets('título, período, situação com ícone e "Lançar"', (tester) async {
    await pumpComponent(tester, row());

    expect(find.text('Ruídos · Indústria Alfa Ltda'), findsOneWidget);
    expect(find.text('Semana 46 · 09 a 15/11/2026'), findsOneWidget);
    final status = tester.widget<StatusText>(find.byType(StatusText));
    expect(
      (status.label, status.tone),
      ('2 semanas atrasadas', StatusTone.overdue),
    );
    expect(find.byIcon(StatusChip.iconFor(StatusTone.overdue)), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.graphic_eq));
    final context = tester.element(find.byType(PendingRow));
    expect(
      icon.color,
      StatusColors.of(context).resolve(StatusTone.overdue).foreground,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Lançar'));
    expect(launches, 1);
  });

  testWidgets('a lançar, sem subtítulo', (tester) async {
    await pumpComponent(
      tester,
      row(subtitle: null, tone: StatusTone.dueSoon, status: 'A lançar'),
    );

    expect(find.text('Semana 46 · 09 a 15/11/2026'), findsNothing);
    expect(find.byIcon(StatusChip.iconFor(StatusTone.dueSoon)), findsOneWidget);
    expect(find.text('A lançar'), findsOneWidget);
  });

  testWidgets('botão ao lado dos textos na fonte normal', (tester) async {
    await pumpComponent(tester, row());

    final button = tester.getRect(find.widgetWithText(FilledButton, 'Lançar'));
    final title = tester.getRect(find.text('Ruídos · Indústria Alfa Ltda'));
    expect(button.left, greaterThan(title.right - 1));
  });

  for (final (name, scaler) in [
    ('1,3×', const TextScaler.linear(1.3)),
    ('2×', const TextScaler.linear(2)),
    ('não linear', const NonLinearScaler()),
  ]) {
    testWidgets('fonte $name sem estouro (390 de largura)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpComponent(
        tester,
        withTextScaler(
          scaler,
          ListView(
            children: [
              row(),
              row(tone: StatusTone.dueSoon, status: 'A lançar'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fonte 2×: botão abaixo dos textos', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpComponent(
      tester,
      withTextScaler(const TextScaler.linear(2), ListView(children: [row()])),
    );

    final button = tester.getRect(find.widgetWithText(FilledButton, 'Lançar'));
    final status = tester.getRect(find.byType(StatusText));
    expect(button.top, greaterThanOrEqualTo(status.bottom));
    await tester.tap(find.widgetWithText(FilledButton, 'Lançar'));
    expect(launches, 1);
  });
}

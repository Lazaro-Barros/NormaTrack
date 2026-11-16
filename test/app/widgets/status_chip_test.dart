import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/status_chip.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('ícone do tom por padrão', (tester) async {
    await pumpComponent(
      tester,
      const StatusChip(tone: StatusTone.overdue, label: 'Vencido'),
    );
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(find.text('Vencido'), findsOneWidget);
  });

  testWidgets('icon sobrepõe o do tom', (tester) async {
    await pumpComponent(
      tester,
      const StatusChip(
        tone: StatusTone.closed,
        label: 'Concluído',
        icon: Icons.task_alt,
      ),
    );
    expect(find.byIcon(Icons.task_alt), findsOneWidget);
    expect(find.byIcon(Icons.autorenew), findsNothing);
  });

  testWidgets('semântica "Situação: …"', (tester) async {
    await pumpComponent(
      tester,
      const StatusChip(tone: StatusTone.ok, label: 'Vigente'),
    );
    expect(find.bySemanticsLabel('Situação: Vigente'), findsOneWidget);
  });
}

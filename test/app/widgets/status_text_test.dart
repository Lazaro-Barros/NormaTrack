import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/status_chip.dart';
import 'package:normatrack/app/widgets/status_text.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('com tom: ícone da situação e cor forte', (tester) async {
    await pumpComponent(
      tester,
      const StatusText(label: 'Venceu 02/08/2026', tone: StatusTone.overdue),
    );

    final icon = tester.widget<Icon>(
      find.byIcon(StatusChip.iconFor(StatusTone.overdue)),
    );
    expect(icon.color, AppColors.overdue);
    final text = tester.widget<Text>(find.text('Venceu 02/08/2026'));
    expect(text.style?.color, AppColors.overdue);
  });

  testWidgets('sem tom: só texto neutro, sem ícone', (tester) async {
    await pumpComponent(tester, const StatusText(label: 'Não se aplica'));

    expect(find.byType(Icon), findsNothing);
    final text = tester.widget<Text>(find.text('Não se aplica'));
    expect(text.style?.color, AppTheme.colorScheme.onSurfaceVariant);
  });
}

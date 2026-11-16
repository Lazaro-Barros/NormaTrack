import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/date_block.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('dia com dois dígitos e mês em maiúsculas', (tester) async {
    await pumpComponent(
      tester,
      DateBlock(date: DateTime(2026, 9, 5), tone: StatusTone.ok),
    );
    expect(find.text('05'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
  });

  testWidgets('showYear mostra o ano de dois dígitos', (tester) async {
    await pumpComponent(
      tester,
      DateBlock(
        date: DateTime(2028, 9, 21),
        showYear: true,
        tone: StatusTone.ok,
      ),
    );
    expect(find.text('SET 28'), findsOneWidget);
  });

  testWidgets('fundo na cor forte do tom', (tester) async {
    await pumpComponent(
      tester,
      DateBlock(date: DateTime(2026, 9, 21), tone: StatusTone.overdue),
    );
    final block = tester.widget<Container>(
      find
          .ancestor(of: find.text('21'), matching: find.byType(Container))
          .first,
    );
    expect((block.decoration! as BoxDecoration).color, AppColors.overdue);
  });
}

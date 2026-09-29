import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/destructive_button.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('contorno e texto na cor de erro', (tester) async {
    var taps = 0;
    await pumpComponent(
      tester,
      DestructiveButton(
        label: 'Arquivar',
        icon: Icons.archive_outlined,
        onPressed: () => taps++,
      ),
    );

    final button = tester.widget<ButtonStyleButton>(
      find.byWidgetPredicate((w) => w is OutlinedButton),
    );
    expect(button.style?.foregroundColor?.resolve({}), AppColors.overdue);
    expect(button.style?.side?.resolve({})?.color, AppColors.overdue);
    await tester.tap(find.text('Arquivar'));
    expect(taps, 1);
  });
}

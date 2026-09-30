import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/field_error_text.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra ícone e texto na cor de erro', (tester) async {
    await pumpComponent(tester, const FieldErrorText('Adicione um lembrete'));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final text = tester.widget<Text>(find.text('Adicione um lembrete'));
    expect(text.style?.color, AppColors.overdue);
  });
}

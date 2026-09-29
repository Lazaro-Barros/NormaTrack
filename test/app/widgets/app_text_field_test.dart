import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/app_text_field.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('rótulo acima com * quando obrigatório, sem labelText', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const AppTextField(label: 'Razão social', required: true, hint: 'Ex.'),
    );

    expect(find.text('Razão social *', findRichText: true), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.labelText, isNull);
    expect(field.decoration?.hintText, 'Ex.');
  });

  testWidgets('errorText mostra ícone e texto na cor de erro', (tester) async {
    await pumpComponent(
      tester,
      const AppTextField(label: 'CNPJ', errorText: 'CNPJ inválido'),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final text = tester.widget<Text>(find.text('CNPJ inválido'));
    expect(text.style?.color, AppColors.overdue);
  });

  testWidgets('sem erro não mostra ícone', (tester) async {
    await pumpComponent(tester, const AppTextField(label: 'CNPJ'));

    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.text('CNPJ', findRichText: true), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/band_title.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra título e subtítulo com a cor muted da faixa', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const BandTitle(title: 'Indústria Alfa', subtitle: 'CNPJ 11.222'),
    );

    final title = tester.widget<Text>(find.text('Indústria Alfa'));
    expect(title.style?.color, AppTheme.colorScheme.onPrimary);
    final subtitle = tester.widget<Text>(find.text('CNPJ 11.222'));
    expect(subtitle.style?.color, BandColors.light.muted);
  });

  testWidgets('large usa headlineMedium', (tester) async {
    await pumpComponent(
      tester,
      const BandTitle(title: 'Empresas', large: true),
    );

    final title = tester.widget<Text>(find.text('Empresas'));
    expect(
      title.style?.fontSize,
      AppTypography.textTheme.headlineMedium?.fontSize,
    );
  });
}

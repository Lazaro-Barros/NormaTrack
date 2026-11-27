import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/period_navigator.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/text_scalers.dart';

void main() {
  Future<double> pump(
    WidgetTester tester, {
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    TextScaler scaler = TextScaler.noScaling,
  }) async {
    late double computed;
    await pumpComponent(
      tester,
      withTextScaler(
        scaler,
        Builder(
          builder: (context) {
            computed = PeriodNavigator.heightOf(context);
            return ColoredBox(
              color: Theme.of(context).colorScheme.primary,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 358,
                  child: PeriodNavigator(
                    title: 'Semana 48',
                    subtitle: '23 a 29/11/2026',
                    onPrevious: onPrevious,
                    onNext: onNext,
                    previousTooltip: 'Semana anterior',
                    nextTooltip: 'Próxima semana',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    return computed;
  }

  testWidgets('mostra o período e chama os botões', (tester) async {
    var previous = 0;
    var next = 0;
    await pump(tester, onPrevious: () => previous++, onNext: () => next++);
    expect(find.text('Semana 48'), findsOneWidget);
    expect(find.text('23 a 29/11/2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.tap(find.byTooltip('Próxima semana'));
    expect((previous, next), (1, 1));
  });

  testWidgets('próximo desabilitado sem callback', (tester) async {
    await pump(tester, onPrevious: () {});
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('título e subtítulo lidos juntos', (tester) async {
    await pump(tester, onPrevious: () {});
    expect(
      find.bySemanticsLabel(RegExp('Semana 48\n23 a 29/11/2026')),
      findsOneWidget,
    );
  });

  double height(WidgetTester tester) =>
      tester.getSize(find.byType(PeriodNavigator)).height;

  testWidgets('altura 56 na escala 1', (tester) async {
    final computed = await pump(tester);
    expect(height(tester), 56);
    expect(computed, 56);
  });

  for (final (name, scaler) in [
    ('1,3×', const TextScaler.linear(1.3)),
    ('2× (limitada a 1,5×)', const TextScaler.linear(2)),
    ('não linear', const NonLinearScaler()),
  ]) {
    testWidgets('fonte $name: cresce sem estouro', (tester) async {
      final computed = await pump(tester, scaler: scaler);
      expect(tester.takeException(), isNull);
      expect(height(tester), computed);
      expect(computed, greaterThan(56));
    });
  }

  test('cores vêm do tema da faixa', () {
    expect(BandColors.light.segment, isNotNull);
  });
}

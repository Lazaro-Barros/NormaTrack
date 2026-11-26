import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/status_banner.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/text_scalers.dart';

Color? _bg(WidgetTester tester) {
  final c = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(StatusBanner),
          matching: find.byType(Container),
        )
        .first,
  );
  return (c.decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('título e mensagem aparecem', (tester) async {
    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.overdue,
        date: DateTime(2026, 9, 26),
        title: 'Venceu há 3 dias',
        message: 'Alertas desde 29/04/2026',
      ),
    );
    expect(find.text('Venceu há 3 dias'), findsOneWidget);
    expect(find.text('Alertas desde 29/04/2026'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
  });

  testWidgets('sem mensagem não ocupa linha; semântica junta os textos', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.ok,
        date: DateTime(2026, 9, 26),
        title: 'Em 120 dias',
      ),
    );
    expect(find.byType(Text), findsNWidgets(3)); // dia, mês, título
    expect(find.bySemanticsLabel('Em 120 dias'), findsOneWidget);

    await pumpComponent(
      tester,
      StatusBanner(
        tone: StatusTone.ok,
        date: DateTime(2026, 9, 26),
        title: 'Em 120 dias',
        message: 'Alertas desde 01/01/2026',
      ),
    );
    expect(
      find.bySemanticsLabel('Em 120 dias. Alertas desde 01/01/2026'),
      findsOneWidget,
    );
  });

  testWidgets('cada tom usa o fundo suave', (tester) async {
    for (final tone in StatusTone.values) {
      await pumpComponent(
        tester,
        StatusBanner(tone: tone, date: DateTime(2026, 9, 26), title: 'x'),
      );
      final expected = StatusColors.light.resolve(tone).background;
      expect(_bg(tester), expected);
    }
  });

  Future<double> pumpScaled(WidgetTester tester, TextScaler scaler) async {
    late double computed;
    await pumpComponent(
      tester,
      withTextScaler(
        scaler,
        Builder(
          builder: (context) {
            computed = StatusBanner.heightOf(context);
            return Align(
              alignment: Alignment.topCenter,
              // Largura do banner num celular de 411 de largura.
              child: SizedBox(
                width: 379,
                child: StatusBanner(
                  tone: StatusTone.overdue,
                  date: DateTime(2028, 9, 26),
                  showYear: true,
                  title: 'Venceu há 3 dias',
                  message: 'Alertas desde 29/04/2026',
                ),
              ),
            );
          },
        ),
      ),
    );
    return computed;
  }

  double bannerHeight(WidgetTester tester) =>
      tester.getSize(find.byType(StatusBanner)).height;

  testWidgets('altura 76 na escala 1', (tester) async {
    final computed = await pumpScaled(tester, TextScaler.noScaling);
    expect(bannerHeight(tester), StatusBanner.height);
    expect(computed, StatusBanner.height);
  });

  testWidgets('fonte 1,3×: altura cresce, sem estouro', (tester) async {
    final computed = await pumpScaled(tester, const TextScaler.linear(1.3));
    expect(tester.takeException(), isNull);
    // 24 + bloco de data (8 + 37 + 21); título + mensagem: 37 + 24 = 61.
    expect(bannerHeight(tester), 24 + 66);
    expect(computed, bannerHeight(tester));
  });

  testWidgets('fonte 2×: limitada a 1,5×, sem estouro', (tester) async {
    final computed = await pumpScaled(tester, const TextScaler.linear(2));
    expect(tester.takeException(), isNull);
    expect(bannerHeight(tester), 24 + 74);
    expect(computed, bannerHeight(tester));
  });

  testWidgets('escala não linear (Android 14+) não estoura', (tester) async {
    final computed = await pumpScaled(tester, const NonLinearScaler());
    expect(tester.takeException(), isNull);
    expect(bannerHeight(tester), 24 + 64);
    expect(computed, bannerHeight(tester));
  });
}

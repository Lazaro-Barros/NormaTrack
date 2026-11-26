import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/date_block.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/text_scalers.dart';

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

  Future<void> pumpScaled(WidgetTester tester, TextScaler scaler) =>
      pumpComponent(
        tester,
        withTextScaler(
          scaler,
          Center(
            child: DateBlock(
              date: DateTime(2028, 9, 5),
              showYear: true,
              tone: StatusTone.overdue,
            ),
          ),
        ),
      );

  Size blockSize(WidgetTester tester) => tester.getSize(find.byType(DateBlock));

  testWidgets('48 × 52 na escala 1', (tester) async {
    await pumpScaled(tester, TextScaler.noScaling);
    expect(blockSize(tester), const Size(DateBlock.width, DateBlock.height));
    expect(DateBlock.width, 48);
  });

  testWidgets('fonte 1,3×: cresce, sem estouro e sem quebrar o dia', (
    tester,
  ) async {
    await pumpScaled(tester, const TextScaler.linear(1.3));
    expect(tester.takeException(), isNull);
    // dia: 28,6 × 28/22 = 36,4 → 37; mês: 15,6 × 16/12 = 20,8 → 21.
    expect(blockSize(tester), const Size(63, 8 + 37 + 21));
    // Uma linha só (28,6 × 28/22 = 36,4), não duas.
    expect(tester.getSize(find.text('05')).height, closeTo(36.4, 1));
  });

  testWidgets('fonte 2×: limitada a 1,5×, sem estouro', (tester) async {
    await pumpScaled(tester, const TextScaler.linear(2));
    expect(tester.takeException(), isNull);
    expect(blockSize(tester), const Size(72, 8 + 42 + 24));
    expect(tester.getSize(find.text('05')).height, closeTo(42, 1));
  });

  testWidgets('escala não linear (Android 14+) não estoura', (tester) async {
    await pumpScaled(tester, const NonLinearScaler());
    expect(tester.takeException(), isNull);
    // dia: 26 × 28/22 = 33,1 → 34; mês: 16 × 16/12 = 21,3 → 22;
    // largura: 48 × 16/12 = 64.
    expect(blockSize(tester), const Size(64, 8 + 34 + 22));
  });

  testWidgets('sizeOf é o tamanho renderizado', (tester) async {
    late Size computed;
    await pumpComponent(
      tester,
      withTextScaler(
        const TextScaler.linear(1.3),
        Center(
          child: Builder(
            builder: (context) {
              computed = DateBlock.sizeOf(context);
              return DateBlock(date: DateTime(2026, 9, 5), tone: StatusTone.ok);
            },
          ),
        ),
      ),
    );
    expect(blockSize(tester), computed);
  });
}

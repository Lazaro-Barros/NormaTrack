import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/notice_banner.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra mensagem, ênfase e ícone nas cores do tom', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpComponent(
      tester,
      const NoticeBanner(
        tone: StatusTone.dueSoon,
        icon: Icons.warning_amber_rounded,
        message: 'Os dados ficam só neste aparelho.',
        emphasis: 'Nenhum backup feito ainda.',
      ),
    );

    final context = tester.element(find.byType(NoticeBanner));
    final style = StatusColors.of(context).resolve(StatusTone.dueSoon);
    expect(
      find.text(
        'Os dados ficam só neste aparelho. Nenhum backup feito ainda.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded)).color,
      style.foreground,
    );
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(NoticeBanner),
        matching: find.byType(Container),
      ),
    );
    expect((box.decoration! as BoxDecoration).color, style.background);
    expect(
      find.bySemanticsLabel(
        'Os dados ficam só neste aparelho. Nenhum backup feito ainda.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('sem ênfase, só a mensagem', (tester) async {
    await pumpComponent(
      tester,
      const NoticeBanner(
        tone: StatusTone.ok,
        icon: Icons.check_circle_outline,
        message: 'Tudo certo.',
      ),
    );
    expect(find.text('Tudo certo.', findRichText: true), findsOneWidget);
  });
}

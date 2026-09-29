import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/nav_row.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('sem onTap não tem chevron', (tester) async {
    await pumpComponent(
      tester,
      const NavRow(title: 'Ambiental', subtitle: 'Licenças'),
    );

    expect(find.text('Ambiental'), findsOneWidget);
    expect(find.text('Licenças'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('com onTap tem chevron e tocar chama', (tester) async {
    var taps = 0;
    await pumpComponent(
      tester,
      NavRow(
        leadingIcon: Icons.eco_outlined,
        title: 'Ambiental',
        trailing: const Text('Em dia'),
        onTap: () => taps++,
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
    expect(find.text('Em dia'), findsOneWidget);
    await tester.tap(find.text('Ambiental'));
    expect(taps, 1);
  });
}

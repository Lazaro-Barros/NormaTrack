import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/switch_row.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('tocar na linha inteira alterna', (tester) async {
    var value = false;
    await pumpComponent(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SwitchRow(
          title: 'Ambiental',
          subtitle: 'Licenças, ruídos',
          value: value,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    );

    await tester.tap(find.text('Licenças, ruídos'));
    await tester.pump();
    expect(value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value, isFalse);
  });
}

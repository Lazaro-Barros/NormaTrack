import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/band_segmented_button.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra os rótulos, marca o selecionado e troca', (tester) async {
    var selected = 1;
    await pumpComponent(
      tester,
      StatefulBuilder(
        builder: (context, setState) => BandSegmentedButton<int>(
          segments: const [(1, 'Licença'), (2, 'Laudo'), (3, 'Manutenção')],
          selected: selected,
          onChanged: (v) => setState(() => selected = v),
        ),
      ),
    );

    for (final label in ['Licença', 'Laudo', 'Manutenção']) {
      expect(find.text(label), findsOneWidget);
    }
    SegmentedButton<int> button() =>
        tester.widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>));
    expect(button().selected, {1});

    await tester.tap(find.text('Laudo'));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(button().selected, {2});
  });
}

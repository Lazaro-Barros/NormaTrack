import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/info_row.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('mostra rótulo e linhas', (tester) async {
    await pumpComponent(
      tester,
      const InfoRow(
        label: 'Endereço',
        lines: ['Av. Industrial, 1200', 'CEP 61939-000'],
      ),
    );

    expect(find.text('Endereço'), findsOneWidget);
    expect(find.text('Av. Industrial, 1200'), findsOneWidget);
    expect(find.text('CEP 61939-000'), findsOneWidget);
  });
}

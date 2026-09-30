import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/app_dropdown_field.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('escolher item chama onChanged; Nenhuma devolve null', (
    tester,
  ) async {
    String? value;
    final changes = <String?>[];
    await pumpComponent(
      tester,
      StatefulBuilder(
        builder: (context, setState) => AppDropdownField<String>(
          label: 'UF',
          value: value,
          items: const ['CE', 'SP'],
          itemLabel: (s) => 'Estado $s',
          selectedLabel: (s) => s,
          onChanged: (v) => setState(() {
            changes.add(v);
            value = v;
          }),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estado SP').last);
    await tester.pumpAndSettle();
    expect(changes, ['SP']);
    expect(find.text('SP'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nenhuma').last);
    await tester.pumpAndSettle();
    expect(changes, ['SP', null]);
  });

  testWidgets('noneLabel troca o rótulo do item vazio', (tester) async {
    await pumpComponent(
      tester,
      AppDropdownField<String>(
        label: 'Órgão',
        value: null,
        items: const ['SEMACE'],
        itemLabel: (s) => s,
        noneLabel: 'Nenhum',
        onChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum'), findsWidgets);
    expect(find.text('Nenhuma'), findsNothing);
  });
}

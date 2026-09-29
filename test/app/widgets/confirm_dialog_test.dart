import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/confirm_dialog.dart';

import '../../helpers/pump_widget.dart';

void main() {
  testWidgets('Cancelar devolve false', (tester) async {
    bool? result;
    await pumpComponent(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showConfirmDialog(
            context,
            title: 'Arquivar empresa?',
            message: 'Ela sai da lista.',
            confirmLabel: 'Arquivar',
          ),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('confirmar devolve true', (tester) async {
    bool? result;
    await pumpComponent(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showConfirmDialog(
            context,
            title: 'Arquivar empresa?',
            message: 'Ela sai da lista.',
            confirmLabel: 'Arquivar',
            destructive: true,
          ),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Ela sai da lista.'), findsOneWidget);
    await tester.tap(find.text('Arquivar'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.text('Arquivar empresa?'), findsNothing);
  });
}

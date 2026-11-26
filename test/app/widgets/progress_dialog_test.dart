import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/progress_dialog.dart';

import '../../helpers/pump_widget.dart';

void main() {
  Future<void> pumpOpener(
    WidgetTester tester,
    Future<void> Function(BuildContext) onTap,
  ) => pumpComponent(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () => onTap(context),
        child: const Text('abrir'),
      ),
    ),
  );

  testWidgets('mostra o rótulo, fecha ao terminar e devolve o valor', (
    tester,
  ) async {
    final work = Completer<int>();
    int? result;
    await pumpOpener(tester, (context) async {
      result = await showProgressDialog(context, 'Restaurando…', work.future);
    });

    await tester.tap(find.text('abrir'));
    await tester.pump();
    expect(find.text('Restaurando…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Voltar não fecha.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Restaurando…'), findsOneWidget);

    work.complete(7);
    await tester.pumpAndSettle();
    expect(find.text('Restaurando…'), findsNothing);
    expect(result, 7);
  });

  testWidgets('com erro, fecha e propaga', (tester) async {
    final work = Completer<void>();
    Object? error;
    await pumpOpener(tester, (context) async {
      try {
        await showProgressDialog(context, 'Gerando backup…', work.future);
      } on StateError catch (e) {
        error = e;
      }
    });

    await tester.tap(find.text('abrir'));
    await tester.pump();
    work.completeError(StateError('falhou'));
    await tester.pumpAndSettle();

    expect(find.text('Gerando backup…'), findsNothing);
    expect(error, isA<StateError>());
  });

  testWidgets('future já concluída: abre e fecha sem sobrar diálogo', (
    tester,
  ) async {
    await pumpOpener(tester, (context) async {
      await showProgressDialog(context, 'Rápido', Future.value());
    });
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mostra um diálogo bloqueante com indicador e [label] enquanto [future]
/// corre. Fecha quando ela termina e devolve o resultado (ou propaga o erro).
/// Voltar e tocar fora não fecham.
Future<T> showProgressDialog<T>(
  BuildContext context,
  String label,
  Future<T> future,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  var open = true;
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    ),
  ).whenComplete(() => open = false);
  try {
    return await future;
  } finally {
    if (open) navigator.pop();
  }
}

import 'package:flutter/services.dart';

/// Número decimal pt-BR num campo de texto: dígitos e uma vírgula (o ponto
/// digitado vira vírgula), no máximo [decimals] casas e [maxIntegerDigits]
/// dígitos antes da vírgula, sem sinal. Edição que viola a regra é recusada.
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimals = 1, this.maxIntegerDigits = 4})
    : _pattern = RegExp(
        '^\\d{0,$maxIntegerDigits}'
        '${decimals > 0 ? '(,\\d{0,$decimals})?' : ''}\$',
      );

  final int decimals;
  final int maxIntegerDigits;
  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('.', ',');
    if (!_pattern.hasMatch(text)) return oldValue;
    return newValue.copyWith(text: text);
  }
}

/// "61,8" → 61.8; "61," → 61.0; vazio ou só "," → `null`.
double? parseDecimal(String text) {
  final t = text.trim().replaceAll('.', ',');
  if (t.isEmpty || t == ',') return null;
  return double.tryParse(t.replaceAll(',', '.'));
}

/// 61.8 → "61,8"; 64 → "64,0" (com [decimals] = 1). Arredonda como
/// `toStringAsFixed`.
String formatDecimal(double value, {int decimals = 1}) =>
    value.toStringAsFixed(decimals).replaceAll('.', ',');

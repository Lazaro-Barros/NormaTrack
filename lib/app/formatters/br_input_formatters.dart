import 'package:flutter/services.dart';

/// Máscaras de documentos brasileiros para campos de texto. O valor do campo
/// continua com máscara; o repositório normaliza ao gravar.
///
/// O cursor sempre vai para o fim (editar no meio joga o cursor para o fim).
class CnpjInputFormatter extends _MaskFormatter {
  CnpjInputFormatter()
    : super(
        allowed: RegExp('[0-9A-Z]'),
        maxLength: 14,
        mask: (_) => '##.###.###/####-##',
      );
}

class CpfInputFormatter extends _MaskFormatter {
  CpfInputFormatter()
    : super(
        allowed: RegExp('[0-9]'),
        maxLength: 11,
        mask: (_) => '###.###.###-##',
      );
}

class PostalCodeInputFormatter extends _MaskFormatter {
  PostalCodeInputFormatter()
    : super(allowed: RegExp('[0-9]'), maxLength: 8, mask: (_) => '#####-###');
}

class PhoneInputFormatter extends _MaskFormatter {
  PhoneInputFormatter()
    : super(
        allowed: RegExp('[0-9]'),
        maxLength: 11,
        mask: (length) => length == 11 ? '(##) #####-####' : '(##) ####-####',
      );
}

class _MaskFormatter extends TextInputFormatter {
  _MaskFormatter({
    required this.allowed,
    required this.maxLength,
    required this.mask,
  });

  final RegExp allowed;
  final int maxLength;

  /// Máscara para a quantidade de caracteres brutos. `#` = caractere bruto.
  final String Function(int length) mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text
        .toUpperCase()
        .split('')
        .where(allowed.hasMatch)
        .take(maxLength)
        .toList();
    final buffer = StringBuffer();
    var next = 0;
    for (final char in mask(raw.length).split('')) {
      if (next >= raw.length) break;
      if (char == '#') {
        buffer.write(raw[next++]);
      } else {
        buffer.write(char);
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

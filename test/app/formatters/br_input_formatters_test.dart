import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/formatters/br_input_formatters.dart';

TextEditingValue _apply(TextInputFormatter f, String input) =>
    f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input));

void main() {
  void expectFormats(TextInputFormatter f, String input, String output) {
    final value = _apply(f, input);
    expect(value.text, output, reason: input);
    expect(value.selection, TextSelection.collapsed(offset: output.length));
  }

  test('CNPJ numérico e alfanumérico', () {
    final f = CnpjInputFormatter();
    expectFormats(f, '11222333000181', '11.222.333/0001-81');
    expectFormats(f, '12abc34501de35', '12.ABC.345/01DE-35');
    expectFormats(f, '1234', '12.34');
    expectFormats(f, '112223330001819', '11.222.333/0001-81');
    expectFormats(f, '12-3', '12.3');
  });

  test('CPF', () {
    expectFormats(CpfInputFormatter(), '12345678909', '123.456.789-09');
  });

  test('CEP', () {
    expectFormats(PostalCodeInputFormatter(), '61939000', '61939-000');
  });

  test('telefone com 10 e 11 dígitos e parcial', () {
    final f = PhoneInputFormatter();
    expectFormats(f, '8533334444', '(85) 3333-4444');
    expectFormats(f, '85999998888', '(85) 99999-8888');
    expectFormats(f, '853', '(85) 3');
    expectFormats(f, '8', '(8');
  });
}

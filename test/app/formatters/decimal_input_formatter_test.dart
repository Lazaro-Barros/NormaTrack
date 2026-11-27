import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/formatters/decimal_input_formatter.dart';

void main() {
  String type(DecimalInputFormatter f, String old, String typed) => f
      .formatEditUpdate(
        TextEditingValue(text: old),
        TextEditingValue(
          text: typed,
          selection: TextSelection.collapsed(offset: typed.length),
        ),
      )
      .text;

  group('DecimalInputFormatter', () {
    final f = DecimalInputFormatter();

    test('aceita dígitos e uma vírgula com uma casa', () {
      expect(type(f, '61', '61,'), '61,');
      expect(type(f, '61,', '61,8'), '61,8');
      expect(type(f, '', ','), ',');
      expect(type(f, '1234', '1234,5'), '1234,5');
    });

    test('ponto vira vírgula', () {
      expect(type(f, '61', '61.8'), '61,8');
    });

    test('recusa casas a mais, duas vírgulas, sinal e letras', () {
      expect(type(f, '61,8', '61,85'), '61,8');
      expect(type(f, '1,2', '1,2,'), '1,2');
      expect(type(f, '', '-1'), '');
      expect(type(f, '6', '6a'), '6');
      expect(type(f, '1234', '12345'), '1234');
    });

    test('decimais configuráveis', () {
      final two = DecimalInputFormatter(decimals: 2);
      expect(type(two, '7,1', '7,12'), '7,12');
      final none = DecimalInputFormatter(decimals: 0);
      expect(type(none, '7', '7,'), '7');
    });
  });

  test('parseDecimal', () {
    expect(parseDecimal('61,8'), 61.8);
    expect(parseDecimal('61,'), 61.0);
    expect(parseDecimal('0'), 0);
    expect(parseDecimal(' 7.5 '), 7.5);
    expect(parseDecimal(''), isNull);
    expect(parseDecimal(','), isNull);
  });

  test('formatDecimal', () {
    expect(formatDecimal(61.8), '61,8');
    expect(formatDecimal(64), '64,0');
    expect(formatDecimal(61.86), '61,9');
    expect(formatDecimal(7.123, decimals: 2), '7,12');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/utils/date_format.dart';

void main() {
  test('formatDate usa dd/MM/yyyy com zeros à esquerda', () {
    expect(formatDate(DateTime(2026, 8, 2)), '02/08/2026');
    expect(formatDate(DateTime(2027, 12, 31)), '31/12/2027');
  });

  test('formatMonthAbbr', () {
    expect(
      [for (var m = 1; m <= 12; m++) formatMonthAbbr(DateTime(2026, m, 1))],
      [
        'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', //
        'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
      ],
    );
  });

  test('isoDate e parseIsoDate', () {
    expect(isoDate(DateTime(2026, 9, 21, 15)), '2026-09-21');
    expect(parseIsoDate('2026-09-21'), DateTime(2026, 9, 21));
    expect(parseIsoDate('2026-02-30'), isNull);
    expect(parseIsoDate('21/09/2026'), isNull);
    expect(parseIsoDate(''), isNull);
  });
}

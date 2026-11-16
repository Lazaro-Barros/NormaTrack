import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/deadlines/domain/renewal.dart';

void main() {
  DateTime d(int y, int m, int day) => DateTime(y, m, day);

  test('repete o intervalo do ciclo anterior', () {
    expect(
      suggestedRenewalDate(d(2026, 9, 21), previousDueDate: d(2022, 9, 21)),
      d(2030, 9, 21),
    );
  });

  test('sem anterior: um ano', () {
    expect(suggestedRenewalDate(d(2026, 1, 31)), d(2027, 1, 31));
  });

  test('ano a ano', () {
    expect(
      suggestedRenewalDate(d(2026, 2, 28), previousDueDate: d(2025, 2, 28)),
      d(2027, 2, 28),
    );
  });

  test('um mês, dia limitado ao fim do mês', () {
    expect(
      suggestedRenewalDate(d(2026, 3, 31), previousDueDate: d(2026, 2, 28)),
      d(2026, 4, 30),
    );
  });

  test('29 de fevereiro em ano não bissexto', () {
    expect(
      suggestedRenewalDate(d(2028, 2, 29), previousDueDate: d(2027, 2, 28)),
      d(2029, 2, 28),
    );
  });

  test('intervalo zero ou negativo: um ano', () {
    expect(
      suggestedRenewalDate(d(2026, 9, 21), previousDueDate: d(2026, 9, 21)),
      d(2027, 9, 21),
    );
    expect(
      suggestedRenewalDate(d(2026, 9, 21), previousDueDate: d(2027, 1, 1)),
      d(2027, 9, 21),
    );
  });
}

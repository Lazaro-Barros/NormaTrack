import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';

void main() {
  MeasurementPeriod at(MeasurementFrequency f, int y, int m, int d) =>
      MeasurementPeriod.containing(f, DateTime(y, m, d));

  void expectRange(MeasurementPeriod p, DateTime start, DateTime end) {
    expect(p.start, start, reason: '$p');
    expect(p.end, end, reason: '$p');
  }

  group('diária', () {
    const f = MeasurementFrequency.daily;
    test('o próprio dia, sem hora', () {
      final p = MeasurementPeriod.containing(f, DateTime(2026, 11, 26, 23, 59));
      expectRange(p, DateTime(2026, 11, 26), DateTime(2026, 11, 26));
    });
    test('next na virada do ano', () {
      expectRange(at(f, 2026, 12, 31).next, DateTime(2027), DateTime(2027));
    });
  });

  group('semanal (ISO, segunda a domingo)', () {
    const f = MeasurementFrequency.weekly;
    test('quarta 23/09/2026 → 21 a 27/09, semana 39', () {
      final p = at(f, 2026, 9, 23);
      expectRange(p, DateTime(2026, 9, 21), DateTime(2026, 9, 27));
      expect(p.isoWeek, 39);
      expect(p.isoWeekYear, 2026);
    });
    test('domingo pertence à semana que começou na segunda', () {
      expect(at(f, 2026, 9, 27).start, DateTime(2026, 9, 21));
    });
    test('28/12/2026 e 03/01/2027 → semana 53 de 2026', () {
      for (final p in [at(f, 2026, 12, 28), at(f, 2027, 1, 3)]) {
        expectRange(p, DateTime(2026, 12, 28), DateTime(2027, 1, 3));
        expect(p.isoWeek, 53);
        expect(p.isoWeekYear, 2026);
      }
    });
    test('04/01/2027 → semana 1 de 2027', () {
      final p = at(f, 2027, 1, 4);
      expect(p.isoWeek, 1);
      expect(p.isoWeekYear, 2027);
    });
    test('30/12/2024 → semana 1 de 2025', () {
      final p = at(f, 2024, 12, 30);
      expect(p.isoWeek, 1);
      expect(p.isoWeekYear, 2025);
    });
    test('next e previous na virada do ano', () {
      expect(at(f, 2026, 12, 28).next.start, DateTime(2027, 1, 4));
      expect(at(f, 2027, 1, 4).previous.start, DateTime(2026, 12, 28));
    });
    test('contains ignora a hora', () {
      final p = at(f, 2026, 9, 23);
      expect(p.contains(DateTime(2026, 9, 27, 23, 59)), isTrue);
      expect(p.contains(DateTime(2026, 9, 21)), isTrue);
      expect(p.contains(DateTime(2026, 9, 28)), isFalse);
      expect(p.contains(DateTime(2026, 9, 20, 12)), isFalse);
    });
  });

  group('quinzenal (1–15 e 16–fim)', () {
    const f = MeasurementFrequency.biweekly;
    test('15/11 → 01 a 15/11; 16/11 → 16 a 30/11', () {
      expectRange(
        at(f, 2026, 11, 15),
        DateTime(2026, 11),
        DateTime(2026, 11, 15),
      );
      expectRange(
        at(f, 2026, 11, 16),
        DateTime(2026, 11, 16),
        DateTime(2026, 11, 30),
      );
    });
    test('fevereiro bissexto → 16 a 29/02/2028', () {
      expectRange(
        at(f, 2028, 2, 20),
        DateTime(2028, 2, 16),
        DateTime(2028, 2, 29),
      );
    });
    test(
      'next de 16/12/2026 → 01/01/2027; previous de 01/03/2026 → 16 a 28/02',
      () {
        expect(at(f, 2026, 12, 16).next.start, DateTime(2027));
        expectRange(
          at(f, 2026, 3, 1).previous,
          DateTime(2026, 2, 16),
          DateTime(2026, 2, 28),
        );
      },
    );
  });

  group('mensal', () {
    const f = MeasurementFrequency.monthly;
    test('fevereiro de 2028 e de 2026', () {
      expectRange(at(f, 2028, 2, 10), DateTime(2028, 2), DateTime(2028, 2, 29));
      expectRange(at(f, 2026, 2, 10), DateTime(2026, 2), DateTime(2026, 2, 28));
    });
    test('next e previous na virada do ano', () {
      expect(at(f, 2026, 12, 5).next.start, DateTime(2027));
      expect(at(f, 2027, 1, 5).previous.start, DateTime(2026, 12));
    });
    test('semana ISO não existe', () {
      expect(() => at(f, 2026, 9, 1).isoWeek, throwsStateError);
    });
  });

  test('igualdade e comparação', () {
    const f = MeasurementFrequency.weekly;
    expect(at(f, 2026, 9, 21), at(f, 2026, 9, 27));
    expect(at(f, 2026, 9, 21).compareTo(at(f, 2026, 9, 28)), lessThan(0));
    expect(
      () => at(
        f,
        2026,
        9,
        21,
      ).compareTo(at(MeasurementFrequency.monthly, 2026, 9, 1)),
      throwsArgumentError,
    );
    expect(
      at(f, 2026, 9, 21) == at(MeasurementFrequency.daily, 2026, 9, 21),
      isFalse,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';

void main() {
  MeasurementParameter param({double? min, double? max}) =>
      MeasurementParameter(
        id: 'p1',
        companyId: 'c1',
        context: MeasurementContext.noise,
        name: 'Portão principal',
        unit: 'dB(A)',
        frequency: MeasurementFrequency.weekly,
        position: 0,
        startDate: DateTime(2026, 11, 4),
        limitMin: min,
        limitMax: max,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

  test('sem limites', () {
    expect(param().check(120), LimitStatus.noLimits);
  });

  test('só máximo 70 (ruído): 70 dentro, 70,1 acima', () {
    final p = param(max: 70);
    expect(p.check(70), LimitStatus.withinLimits);
    expect(p.check(70.1), LimitStatus.aboveMax);
    expect(p.check(-5), LimitStatus.withinLimits);
  });

  test('faixa 6–8 (pH da ETE)', () {
    final p = param(min: 6, max: 8);
    expect(p.check(5.9), LimitStatus.belowMin);
    expect(p.check(6), LimitStatus.withinLimits);
    expect(p.check(8), LimitStatus.withinLimits);
    expect(p.check(8.01), LimitStatus.aboveMax);
  });

  test('primeiro período e arquivamento', () {
    final p = param();
    expect(p.firstPeriod.start, DateTime(2026, 11, 2));
    expect(p.isArchived, isFalse);
    expect(p.toInput().startDate, DateTime(2026, 11, 4));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';

void main() {
  void checkCodes<T extends Enum>(
    List<T> values,
    String Function(T) code,
    T Function(String) fromCode,
  ) {
    for (final v in values) {
      expect(fromCode(code(v)), v);
    }
    expect(values.map(code).toSet(), hasLength(values.length));
    expect(() => fromCode('desconhecido'), throwsArgumentError);
  }

  test('MeasurementContext', () {
    checkCodes(
      MeasurementContext.values,
      (v) => v.code,
      MeasurementContext.fromCode,
    );
    expect(MeasurementContext.values.map((v) => v.code), [
      'noise',
      'effluent',
      'water',
    ]);
    expect(MeasurementContext.noise.defaultUnit, 'dB(A)');
    expect(MeasurementContext.values.map((v) => v.module).toSet(), {
      ModuleType.environmental,
    });
  });

  test('MeasurementFrequency', () {
    checkCodes(
      MeasurementFrequency.values,
      (v) => v.code,
      MeasurementFrequency.fromCode,
    );
    expect(MeasurementFrequency.values.map((v) => v.code), [
      'daily',
      'weekly',
      'biweekly',
      'monthly',
    ]);
    expect(MeasurementFrequency.biweekly.label, 'Quinzenal');
  });
}

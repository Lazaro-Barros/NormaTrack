import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_validation.dart';

void main() {
  MeasurementParameterInput input({
    String name = 'Ponto 1',
    String? unit = 'dB(A)',
    double? min,
    double? max,
    DateTime? start,
  }) => MeasurementParameterInput(
    name: name,
    unit: unit,
    frequency: MeasurementFrequency.weekly,
    startDate: start ?? DateTime(2026, 11, 4),
    limitMin: min,
    limitMax: max,
  );

  List<ParameterFieldError> errors(MeasurementParameterInput i) =>
      validateParameter(normalizeParameterInput(i));

  group('parâmetro', () {
    test('normaliza espaços, unidade vazia e hora', () {
      final n = normalizeParameterInput(
        input(
          name: '  Divisa   norte ',
          unit: '  ',
          start: DateTime(2026, 11, 4, 15, 30),
        ),
      );
      expect(n.name, 'Divisa norte');
      expect(n.unit, isNull);
      expect(n.startDate, DateTime(2026, 11, 4));
      expect(normalizeParameterInput(input(unit: ' mg/L ')).unit, 'mg/L');
    });

    test('válido', () {
      expect(errors(input()), isEmpty);
      expect(errors(input(min: 6, max: 6)), isEmpty);
    });

    test('nome vazio ou só espaços', () {
      expect(errors(input(name: '   ')), [
        const ParameterFieldError(
          ParameterField.name,
          ParameterFieldErrorType.required,
        ),
      ]);
    });

    test('limites invertidos', () {
      expect(errors(input(min: 9, max: 6)), [
        const ParameterFieldError(
          ParameterField.limitMax,
          ParameterFieldErrorType.limitsInverted,
        ),
      ]);
    });

    test('limites não finitos', () {
      expect(errors(input(min: double.nan, max: double.infinity)), [
        const ParameterFieldError(
          ParameterField.limitMin,
          ParameterFieldErrorType.invalid,
        ),
        const ParameterFieldError(
          ParameterField.limitMax,
          ParameterFieldErrorType.invalid,
        ),
      ]);
    });
  });

  group('entrada', () {
    List<EntryFieldError> entryErrors(MeasurementEntry e) =>
        validateEntry(normalizeEntry(e));

    test('valor 0 é válido, com ou sem nota', () {
      expect(entryErrors(const MeasurementEntry(value: 0)), isEmpty);
      expect(
        entryErrors(const MeasurementEntry(value: 61.8, note: 'chuva')),
        isEmpty,
      );
    });

    test('sem valor exige justificativa', () {
      const required = [
        EntryFieldError(EntryField.note, EntryFieldErrorType.required),
      ];
      expect(entryErrors(const MeasurementEntry()), required);
      expect(entryErrors(const MeasurementEntry(note: '   ')), required);
      expect(
        entryErrors(const MeasurementEntry(note: 'Fábrica parada')),
        isEmpty,
      );
    });

    test('valor não finito', () {
      expect(entryErrors(const MeasurementEntry(value: double.nan)), [
        const EntryFieldError(EntryField.value, EntryFieldErrorType.invalid),
      ]);
    });

    test('normaliza a nota', () {
      expect(
        normalizeEntry(const MeasurementEntry(note: '  Fábrica   parada ')),
        const MeasurementEntry(note: 'Fábrica parada'),
      );
      expect(
        normalizeEntry(const MeasurementEntry(value: 1, note: ' ')).note,
        isNull,
      );
    });
  });
}

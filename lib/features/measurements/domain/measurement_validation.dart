import 'package:meta/meta.dart';

import 'measurement.dart';
import 'measurement_parameter.dart';

enum ParameterField { name, frequency, limitMin, limitMax }

enum ParameterFieldErrorType {
  required,
  invalid,
  duplicate,
  limitsInverted,
  locked,
}

@immutable
class ParameterFieldError {
  const ParameterFieldError(this.field, this.type);

  final ParameterField field;
  final ParameterFieldErrorType type;

  @override
  bool operator ==(Object other) =>
      other is ParameterFieldError &&
      other.field == field &&
      other.type == type;

  @override
  int get hashCode => Object.hash(field, type);

  @override
  String toString() => 'ParameterFieldError(${field.name}, ${type.name})';
}

enum EntryField { value, note }

enum EntryFieldErrorType { required, invalid }

@immutable
class EntryFieldError {
  const EntryFieldError(this.field, this.type);

  final EntryField field;
  final EntryFieldErrorType type;

  @override
  bool operator ==(Object other) =>
      other is EntryFieldError && other.field == field && other.type == type;

  @override
  int get hashCode => Object.hash(field, type);

  @override
  String toString() => 'EntryFieldError(${field.name}, ${type.name})';
}

final _spaces = RegExp(r'\s+');

String? _clean(String? text) {
  final cleaned = text?.trim().replaceAll(_spaces, ' ');
  return cleaned == null || cleaned.isEmpty ? null : cleaned;
}

/// Nome e unidade sem espaços sobrando (unidade vazia vira `null`) e data de
/// início sem hora.
MeasurementParameterInput normalizeParameterInput(
  MeasurementParameterInput input,
) {
  final start = input.startDate;
  return MeasurementParameterInput(
    name: _clean(input.name) ?? '',
    unit: _clean(input.unit),
    frequency: input.frequency,
    startDate: DateTime(start.year, start.month, start.day),
    limitMin: input.limitMin,
    limitMax: input.limitMax,
  );
}

/// Valida um input já normalizado. Duplicado e frequência travada são
/// verificados no repositório. Lista vazia = válido.
List<ParameterFieldError> validateParameter(MeasurementParameterInput input) {
  final min = input.limitMin;
  final max = input.limitMax;
  return [
    if (input.name.isEmpty)
      const ParameterFieldError(
        ParameterField.name,
        ParameterFieldErrorType.required,
      ),
    if (min != null && !min.isFinite)
      const ParameterFieldError(
        ParameterField.limitMin,
        ParameterFieldErrorType.invalid,
      ),
    if (max != null && !max.isFinite)
      const ParameterFieldError(
        ParameterField.limitMax,
        ParameterFieldErrorType.invalid,
      )
    else if (min != null && max != null && min.isFinite && min > max)
      const ParameterFieldError(
        ParameterField.limitMax,
        ParameterFieldErrorType.limitsInverted,
      ),
  ];
}

/// Nota sem espaços sobrando; vazia vira `null`.
MeasurementEntry normalizeEntry(MeasurementEntry entry) =>
    MeasurementEntry(value: entry.value, note: _clean(entry.note));

/// Valida uma entrada já normalizada: sem valor, a justificativa é
/// obrigatória (C26). Lista vazia = válido.
List<EntryFieldError> validateEntry(MeasurementEntry entry) {
  final value = entry.value;
  return [
    if (value == null && entry.note == null)
      const EntryFieldError(EntryField.note, EntryFieldErrorType.required),
    if (value != null && !value.isFinite)
      const EntryFieldError(EntryField.value, EntryFieldErrorType.invalid),
  ];
}

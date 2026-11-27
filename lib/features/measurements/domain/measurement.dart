import 'package:meta/meta.dart';

/// O que se digita para um parâmetro num período: o valor, ou a justificativa
/// de "sem medição" (C26).
@immutable
class MeasurementEntry {
  const MeasurementEntry({this.value, this.note});

  final double? value;

  /// Com valor: observação. Sem valor: justificativa (obrigatória).
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is MeasurementEntry && other.value == value && other.note == note;

  @override
  int get hashCode => Object.hash(value, note);

  @override
  String toString() => 'MeasurementEntry($value, $note)';
}

/// Medição de um parâmetro num período.
@immutable
class Measurement {
  const Measurement({
    required this.id,
    required this.parameterId,
    required this.periodStart,
    this.value,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String parameterId;

  /// Início do período (`MeasurementPeriod.start`). Só a data, local.
  final DateTime periodStart;
  final double? value;
  final String? note;

  /// UTC.
  final DateTime createdAt;

  /// UTC.
  final DateTime updatedAt;

  /// "Sem medição no período", com justificativa em [note].
  bool get isSkipped => value == null;

  MeasurementEntry toEntry() => MeasurementEntry(value: value, note: note);

  @override
  bool operator ==(Object other) =>
      other is Measurement &&
      other.id == id &&
      other.parameterId == parameterId &&
      other.periodStart == periodStart &&
      other.value == value &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    parameterId,
    periodStart,
    value,
    note,
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'Measurement($id, $parameterId, $periodStart, $value)';
}

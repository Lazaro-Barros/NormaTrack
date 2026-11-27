import 'package:meta/meta.dart';

import 'measurement_context.dart';
import 'measurement_frequency.dart';
import 'measurement_period.dart';

/// Resultado de comparar um valor com os limites do parâmetro.
enum LimitStatus { noLimits, withinLimits, belowMin, aboveMax }

/// Dados editáveis do parâmetro. Usado para criar e para editar.
@immutable
class MeasurementParameterInput {
  const MeasurementParameterInput({
    required this.name,
    this.unit,
    required this.frequency,
    required this.startDate,
    this.limitMin,
    this.limitMax,
  });

  final String name;
  final String? unit;
  final MeasurementFrequency frequency;

  /// A partir de quando cobra lançamento. Só a data, local.
  final DateTime startDate;
  final double? limitMin;
  final double? limitMax;

  @override
  bool operator ==(Object other) =>
      other is MeasurementParameterInput &&
      other.name == name &&
      other.unit == unit &&
      other.frequency == frequency &&
      other.startDate == startDate &&
      other.limitMin == limitMin &&
      other.limitMax == limitMax;

  @override
  int get hashCode =>
      Object.hash(name, unit, frequency, startDate, limitMin, limitMax);

  @override
  String toString() =>
      'MeasurementParameterInput($name, $unit, ${frequency.code}, $startDate, '
      '$limitMin..$limitMax)';
}

/// Ponto de ruído ou parâmetro de estação (pH, vazão, insumo…) de uma empresa.
@immutable
class MeasurementParameter {
  const MeasurementParameter({
    required this.id,
    required this.companyId,
    required this.context,
    required this.name,
    this.unit,
    required this.frequency,
    required this.position,
    required this.startDate,
    this.limitMin,
    this.limitMax,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final MeasurementContext context;
  final String name;
  final String? unit;
  final MeasurementFrequency frequency;

  /// Ordem na lista do contexto.
  final int position;

  /// Só a data, local.
  final DateTime startDate;
  final double? limitMin;
  final double? limitMax;

  /// UTC. `null` = ativo.
  final DateTime? archivedAt;

  /// UTC.
  final DateTime createdAt;

  /// UTC.
  final DateTime updatedAt;

  bool get isArchived => archivedAt != null;

  /// Primeiro período que cobra lançamento.
  MeasurementPeriod get firstPeriod =>
      MeasurementPeriod.containing(frequency, startDate);

  /// Limites estritos: igual ao limite está dentro.
  LimitStatus check(double value) {
    if (limitMin == null && limitMax == null) return LimitStatus.noLimits;
    if (limitMin case final min? when value < min) return LimitStatus.belowMin;
    if (limitMax case final max? when value > max) return LimitStatus.aboveMax;
    return LimitStatus.withinLimits;
  }

  /// Para editar: `toInput()` → alterar → `updateParameter()`.
  MeasurementParameterInput toInput() => MeasurementParameterInput(
    name: name,
    unit: unit,
    frequency: frequency,
    startDate: startDate,
    limitMin: limitMin,
    limitMax: limitMax,
  );

  @override
  bool operator ==(Object other) =>
      other is MeasurementParameter &&
      other.id == id &&
      other.companyId == companyId &&
      other.context == context &&
      other.position == position &&
      other.archivedAt == archivedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.toInput() == toInput();

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    context,
    position,
    archivedAt,
    createdAt,
    updatedAt,
    toInput(),
  );

  @override
  String toString() =>
      'MeasurementParameter($id, ${context.code}, $name, ${frequency.code})';
}

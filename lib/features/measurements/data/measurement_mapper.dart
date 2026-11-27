import '../../../core/database/app_database.dart';
import '../domain/measurement.dart';
import '../domain/measurement_context.dart';
import '../domain/measurement_frequency.dart';
import '../domain/measurement_parameter.dart';

// Enums vão para o banco pelo `code` (D007). Código desconhecido vindo do
// banco lança `ArgumentError`: é corrupção, não entrada do usuário.

MeasurementParameter parameterFromRow(MeasurementParameterRow row) =>
    MeasurementParameter(
      id: row.id,
      companyId: row.companyId,
      context: MeasurementContext.fromCode(row.context),
      name: row.name,
      unit: row.unit,
      frequency: MeasurementFrequency.fromCode(row.frequency),
      position: row.position,
      startDate: row.startDate,
      limitMin: row.limitMin,
      limitMax: row.limitMax,
      archivedAt: row.archivedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

Measurement measurementFromRow(MeasurementRow row) => Measurement(
  id: row.id,
  parameterId: row.parameterId,
  periodStart: row.periodStart,
  value: row.value,
  note: row.note,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);

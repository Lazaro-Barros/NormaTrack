import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../companies/data/company_tables.dart';

@TableIndex.sql(
  'CREATE INDEX measurement_parameters_company_context ON '
  'measurement_parameters (company_id, context, position) '
  'WHERE deleted_at IS NULL',
)
@DataClassName('MeasurementParameterRow')
class MeasurementParameters extends Table with EntityColumns {
  TextColumn get companyId => text().references(Companies, #id)();

  /// `MeasurementContext.code`.
  TextColumn get context => text()();
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();

  /// `MeasurementFrequency.code`.
  TextColumn get frequency => text()();
  IntColumn get position => integer()();
  TextColumn get startDate => text().map(const DateOnlyConverter())();
  RealColumn get limitMin => real().nullable()();
  RealColumn get limitMax => real().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

// Uma medição viva por parâmetro e período.
@TableIndex.sql(
  'CREATE UNIQUE INDEX measurements_parameter_period_live ON measurements '
  '(parameter_id, period_start) WHERE deleted_at IS NULL',
)
@DataClassName('MeasurementRow')
class Measurements extends Table with EntityColumns {
  TextColumn get parameterId => text().references(MeasurementParameters, #id)();

  /// Início do período (`MeasurementPeriod.start`).
  TextColumn get periodStart => text().map(const DateOnlyConverter())();

  /// `null` = sem medição no período, com justificativa em [note].
  RealColumn get value => real().nullable()();
  TextColumn get note => text().nullable()();
}

import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../companies/data/company_tables.dart';

@TableIndex.sql(
  'CREATE INDEX deadlines_company_due ON deadlines (company_id, due_date) '
  'WHERE deleted_at IS NULL',
)
@TableIndex.sql(
  'CREATE INDEX deadlines_status_due ON deadlines (status, due_date) '
  'WHERE deleted_at IS NULL',
)
// Uma renovação viva por ciclo.
@TableIndex.sql(
  'CREATE UNIQUE INDEX deadlines_previous_live ON deadlines '
  '(previous_deadline_id) '
  'WHERE previous_deadline_id IS NOT NULL AND deleted_at IS NULL',
)
@DataClassName('DeadlineRow')
class Deadlines extends Table with EntityColumns {
  TextColumn get companyId => text().references(Companies, #id)();

  /// `ModuleType.code`.
  TextColumn get module => text()();

  /// `DeadlineCategory.code`.
  TextColumn get category => text()();

  /// `Authority.code`.
  TextColumn get authority => text().nullable()();
  TextColumn get title => text()();
  TextColumn get dueDate => text().map(const DateOnlyConverter())();

  /// `DeadlineStatus.code`.
  TextColumn get status => text()();
  TextColumn get completedOn =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get previousDeadlineId =>
      text().nullable().references(Deadlines, #id)();
}

@DataClassName('DeadlineReminderRow')
class DeadlineReminders extends Table with EntityColumns {
  TextColumn get deadlineId => text().references(Deadlines, #id)();

  /// Dias antes do vencimento.
  IntColumn get daysBefore => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {deadlineId, daysBefore},
  ];
}

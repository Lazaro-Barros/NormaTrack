import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../companies/domain/authority.dart';
import '../../companies/domain/module_type.dart';
import '../domain/deadline.dart';
import '../domain/deadline_category.dart';
import '../domain/deadline_status.dart';

// Enums vão para o banco pelo `code`, nunca pelo `name` (D007). Código
// desconhecido vindo do banco lança `ArgumentError`: é corrupção, não entrada
// do usuário.

/// Monta o prazo. `reminders` deve conter só linhas vivas.
Deadline deadlineFromRows(
  DeadlineRow row,
  Iterable<DeadlineReminderRow> reminders,
) {
  final input = deadlineInputFromRow(row, reminders);
  return Deadline(
    id: row.id,
    companyId: row.companyId,
    module: input.module,
    category: input.category,
    authority: input.authority,
    title: input.title,
    dueDate: input.dueDate,
    reminderDays: input.reminderDays!,
    status: DeadlineStatus.fromCode(row.status),
    completedOn: row.completedOn,
    previousDeadlineId: row.previousDeadlineId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

/// Lembretes em ordem decrescente, como o domínio espera.
DeadlineInput deadlineInputFromRow(
  DeadlineRow row,
  Iterable<DeadlineReminderRow> reminders,
) => DeadlineInput(
  module: ModuleType.fromCode(row.module),
  category: DeadlineCategory.fromCode(row.category),
  authority: switch (row.authority) {
    final code? => Authority.fromCode(code),
    null => null,
  },
  title: row.title,
  dueDate: row.dueDate,
  reminderDays: [for (final r in reminders) r.daysBefore]
    ..sort((a, b) => b - a),
);

/// Colunas de dados do prazo (sem id, empresa, estado, cadeia e timestamps).
DeadlinesCompanion deadlineDataCompanion(DeadlineInput input) =>
    DeadlinesCompanion(
      module: Value(input.module.code),
      category: Value(input.category.code),
      authority: Value(input.authority?.code),
      title: Value(input.title),
      dueDate: Value(input.dueDate),
    );

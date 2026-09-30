import 'package:meta/meta.dart';

import 'deadline.dart';

enum DeadlineField { title, dueDate, reminderDays }

enum DeadlineFieldErrorType { required, invalid, notAfterPrevious }

@immutable
class DeadlineFieldError {
  const DeadlineFieldError(this.field, this.type);

  final DeadlineField field;
  final DeadlineFieldErrorType type;

  @override
  bool operator ==(Object other) =>
      other is DeadlineFieldError && other.field == field && other.type == type;

  @override
  int get hashCode => Object.hash(field, type);

  @override
  String toString() => 'DeadlineFieldError(${field.name}, ${type.name})';
}

final _spaces = RegExp(r'\s+');

/// Normaliza o input antes de validar e gravar: título sem espaços sobrando,
/// data sem hora e lembretes sem repetição em ordem decrescente (`null` vira o
/// padrão da categoria).
DeadlineInput normalizeDeadlineInput(DeadlineInput input) {
  final due = input.dueDate;
  final days = input.reminderDays ?? input.category.defaultReminderDays;
  return DeadlineInput(
    module: input.module,
    category: input.category,
    authority: input.authority,
    title: input.title.trim().replaceAll(_spaces, ' '),
    dueDate: DateTime(due.year, due.month, due.day),
    reminderDays: List.unmodifiable(
      days.toSet().toList()..sort((a, b) => b - a),
    ),
  );
}

/// Valida um input já normalizado. Lista vazia = válido.
List<DeadlineFieldError> validateDeadline(DeadlineInput input) {
  final days = input.reminderDays ?? const [];
  return [
    if (input.title.isEmpty)
      const DeadlineFieldError(
        DeadlineField.title,
        DeadlineFieldErrorType.required,
      ),
    if (days.isEmpty)
      const DeadlineFieldError(
        DeadlineField.reminderDays,
        DeadlineFieldErrorType.required,
      )
    else if (days.any((d) => d < 0))
      const DeadlineFieldError(
        DeadlineField.reminderDays,
        DeadlineFieldErrorType.invalid,
      ),
  ];
}

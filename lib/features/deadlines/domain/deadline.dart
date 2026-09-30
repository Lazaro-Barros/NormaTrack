import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../companies/domain/authority.dart';
import '../../companies/domain/module_type.dart';
import 'deadline_category.dart';
import 'deadline_status.dart';

const _listEquality = ListEquality<int>();

/// Data do lembrete [daysBefore] dias antes de [dueDate], em calendário.
DateTime reminderDate(DateTime dueDate, int daysBefore) =>
    DateTime(dueDate.year, dueDate.month, dueDate.day - daysBefore);

/// Dados editáveis do prazo. Usado para criar e para editar.
@immutable
class DeadlineInput {
  const DeadlineInput({
    required this.module,
    required this.category,
    this.authority,
    required this.title,
    required this.dueDate,
    this.reminderDays,
  });

  final ModuleType module;

  // TODO(RF-PRZ-01): categorias permitidas por módulo (C20).
  final DeadlineCategory category;
  final Authority? authority;
  final String title;

  /// Só a data: `DateTime(y, m, d)`, sem hora, local.
  final DateTime dueDate;

  /// Dias antes do vencimento. `null` = `category.defaultReminderDays`.
  final List<int>? reminderDays;

  @override
  bool operator ==(Object other) =>
      other is DeadlineInput &&
      other.module == module &&
      other.category == category &&
      other.authority == authority &&
      other.title == title &&
      other.dueDate == dueDate &&
      _nullableListEquals(other.reminderDays, reminderDays);

  @override
  int get hashCode => Object.hash(
    module,
    category,
    authority,
    title,
    dueDate,
    reminderDays == null ? null : _listEquality.hash(reminderDays),
  );

  @override
  String toString() =>
      'DeadlineInput(${module.code}, ${category.code}, $title, $dueDate, '
      '$reminderDays)';
}

bool _nullableListEquals(List<int>? a, List<int>? b) =>
    a == null || b == null ? a == b : _listEquality.equals(a, b);

/// Um ciclo de prazo. Renovar cria o próximo ciclo apontando para este
/// (RF-PRZ-04).
@immutable
class Deadline {
  Deadline({
    required this.id,
    required this.companyId,
    required this.module,
    required this.category,
    this.authority,
    required this.title,
    required this.dueDate,
    required List<int> reminderDays,
    this.status = DeadlineStatus.active,
    this.completedOn,
    this.previousDeadlineId,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(reminderDays.isNotEmpty, 'reminderDays vazio'),
       reminderDays = List.unmodifiable(reminderDays);

  final String id;
  final String companyId;
  final ModuleType module;
  final DeadlineCategory category;
  final Authority? authority;
  final String title;

  /// Só a data: `DateTime(y, m, d)`, sem hora, local.
  final DateTime dueDate;

  /// Dias antes do vencimento, em ordem decrescente e sem repetição.
  final List<int> reminderDays;
  final DeadlineStatus status;

  /// Só a data. Presente só com [DeadlineStatus.completed].
  final DateTime? completedOn;
  final String? previousDeadlineId;

  /// UTC.
  final DateTime createdAt;

  /// UTC.
  final DateTime updatedAt;

  /// Maior lembrete: abre a janela "a vencer" (RF-PRZ-02).
  int get alertDaysBefore => reminderDays.first;

  /// Primeiro dia da janela "a vencer".
  DateTime get alertStartDate => reminderDate(dueDate, alertDaysBefore);

  /// Uma data por lembrete, na ordem de [reminderDays] (mais cedo primeiro).
  List<DateTime> get reminderDates => List.unmodifiable([
    for (final d in reminderDays) reminderDate(dueDate, d),
  ]);

  bool get isOpen => status == DeadlineStatus.active;

  /// Dias de calendário de [today] até [dueDate]: 0 no dia, negativo depois.
  /// A hora de [today] é ignorada.
  int daysUntilDue(DateTime today) => DateTime.utc(
    dueDate.year,
    dueDate.month,
    dueDate.day,
  ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

  /// Em aberto: vencido depois do dia do vencimento; a vencer da data do
  /// primeiro alerta até o dia do vencimento, inclusive; vigente antes.
  DeadlineSituation situationOn(DateTime today) {
    switch (status) {
      case DeadlineStatus.renewed:
        return DeadlineSituation.renewed;
      case DeadlineStatus.completed:
        return DeadlineSituation.completed;
      case DeadlineStatus.cancelled:
        return DeadlineSituation.cancelled;
      case DeadlineStatus.active:
        final days = daysUntilDue(today);
        if (days < 0) return DeadlineSituation.overdue;
        if (days <= alertDaysBefore) return DeadlineSituation.dueSoon;
        return DeadlineSituation.current;
    }
  }

  /// Para editar: `toInput()` → alterar → `update()`.
  DeadlineInput toInput() => DeadlineInput(
    module: module,
    category: category,
    authority: authority,
    title: title,
    dueDate: dueDate,
    reminderDays: reminderDays,
  );

  @override
  bool operator ==(Object other) =>
      other is Deadline &&
      other.id == id &&
      other.companyId == companyId &&
      other.status == status &&
      other.completedOn == completedOn &&
      other.previousDeadlineId == previousDeadlineId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.toInput() == toInput();

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    status,
    completedOn,
    previousDeadlineId,
    createdAt,
    updatedAt,
    toInput(),
  );

  @override
  String toString() => 'Deadline($id, $title, $dueDate, ${status.code})';
}

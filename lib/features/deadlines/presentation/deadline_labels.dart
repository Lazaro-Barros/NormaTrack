import '../../../app/theme/app_theme.dart';
import '../domain/deadline.dart';
import '../domain/deadline_category.dart';
import '../domain/deadline_status.dart';
import '../domain/deadline_validation.dart';

StatusTone deadlineTone(DeadlineSituation s) => switch (s) {
  DeadlineSituation.overdue => StatusTone.overdue,
  DeadlineSituation.dueSoon => StatusTone.dueSoon,
  DeadlineSituation.current => StatusTone.ok,
  DeadlineSituation.renewed ||
  DeadlineSituation.completed ||
  DeadlineSituation.cancelled => StatusTone.closed,
};

/// Tom e texto relativo do `DeadlineCard` ("Venceu" / "há 3 dias").
({StatusTone tone, String? lead, String text}) deadlineDisplay(
  Deadline d,
  DateTime today,
) {
  final situation = d.situationOn(today);
  final tone = deadlineTone(situation);
  final n = d.daysUntilDue(today);
  return switch (situation) {
    DeadlineSituation.overdue => (
      tone: tone,
      lead: 'Venceu',
      text: n == -1 ? 'ontem' : 'há ${-n} dias',
    ),
    DeadlineSituation.dueSoon => (
      tone: tone,
      lead: 'Vence',
      text: switch (n) {
        0 => 'hoje',
        1 => 'amanhã',
        _ => 'em $n dias',
      },
    ),
    DeadlineSituation.current => (
      tone: tone,
      lead: null,
      text: n <= 365 ? 'Em ${_plural(n, 'dia', 'dias')}' : _years(n),
    ),
    DeadlineSituation.renewed ||
    DeadlineSituation.completed ||
    DeadlineSituation.cancelled => (
      tone: tone,
      lead: null,
      text: d.status.label,
    ),
  };
}

String _years(int days) => 'Em ${_plural(days ~/ 365, 'ano', 'anos')}';

String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// "No dia do vencimento", "1 dia antes", "30 dias antes".
String reminderLabel(int days) => days == 0
    ? 'No dia do vencimento'
    : '${_plural(days, 'dia', 'dias')} antes';

/// Título de seção na tela do módulo.
String categoryPluralLabel(DeadlineCategory c) => switch (c) {
  DeadlineCategory.license => 'Licenças',
  DeadlineCategory.labReport => 'Laudos',
  DeadlineCategory.maintenance => 'Manutenções',
};

/// Linha de contexto do card: "Licença · SEMACE".
String deadlineSubtitle(Deadline d) =>
    [d.category.label, ?d.authority?.shortLabel].join(' · ');

String deadlineFieldMessage(DeadlineFieldError e) =>
    switch ((e.field, e.type)) {
      (DeadlineField.title, _) => 'Informe o título',
      (DeadlineField.reminderDays, DeadlineFieldErrorType.required) =>
        'Adicione ao menos um lembrete',
      (DeadlineField.reminderDays, _) => 'Lembrete inválido',
      (DeadlineField.dueDate, DeadlineFieldErrorType.notAfterPrevious) =>
        'A nova data deve ser depois do vencimento atual',
      (DeadlineField.dueDate, _) => 'Informe o vencimento',
    };

/// Pior situação dos prazos em aberto de um módulo, com a contagem: vencidos
/// antes de a vencer. `null` se só há vigentes (ou nada).
({String label, StatusTone tone})? modulePending(
  Iterable<Deadline> open,
  DateTime today,
) {
  var overdue = 0;
  var dueSoon = 0;
  for (final d in open) {
    switch (d.situationOn(today)) {
      case DeadlineSituation.overdue:
        overdue++;
      case DeadlineSituation.dueSoon:
        dueSoon++;
      case _:
    }
  }
  if (overdue > 0) {
    return (
      label: _plural(overdue, 'vencido', 'vencidos'),
      tone: StatusTone.overdue,
    );
  }
  if (dueSoon > 0) {
    return (label: '$dueSoon a vencer', tone: StatusTone.dueSoon);
  }
  return null;
}

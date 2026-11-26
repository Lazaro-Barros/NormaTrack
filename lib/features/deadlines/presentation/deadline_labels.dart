import 'package:flutter/material.dart' show IconData, Icons;

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../core/utils/date_format.dart';
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

/// Rótulo do chip de situação.
String situationLabel(DeadlineSituation s) => switch (s) {
  DeadlineSituation.current => 'Vigente',
  DeadlineSituation.dueSoon => 'A vencer',
  DeadlineSituation.overdue => 'Vencido',
  DeadlineSituation.renewed => 'Renovado',
  DeadlineSituation.completed => 'Concluído',
  DeadlineSituation.cancelled => 'Cancelado',
};

/// Rótulo dos tiles do Painel: "Vencidos", "A vencer", "Vigentes". Só para as
/// três situações em aberto; as demais caem no rótulo do chip.
String situationPluralLabel(DeadlineSituation s) => switch (s) {
  DeadlineSituation.overdue => 'Vencidos',
  DeadlineSituation.dueSoon => 'A vencer',
  DeadlineSituation.current => 'Vigentes',
  _ => situationLabel(s),
};

/// Ícone da situação: o do tom, exceto renovado, concluído e cancelado.
IconData situationIcon(DeadlineSituation s) => switch (s) {
  DeadlineSituation.renewed => Icons.autorenew,
  DeadlineSituation.completed => Icons.task_alt,
  DeadlineSituation.cancelled => Icons.block,
  _ => StatusChip.iconFor(deadlineTone(s)),
};

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "Alertas a partir de 29/04/2026" (início no futuro) ou "Alertas desde …".
String alertCaption(Deadline d, DateTime today) =>
    _dateOnly(d.alertStartDate).isAfter(_dateOnly(today))
    ? 'Alertas a partir de ${formatDate(d.alertStartDate)}'
    : 'Alertas desde ${formatDate(d.alertStartDate)}';

/// Conteúdo do `StatusBanner` do detalhe.
({StatusTone tone, String title, String? message}) deadlineBanner(
  Deadline d,
  DateTime today,
) {
  final situation = d.situationOn(today);
  final tone = deadlineTone(situation);
  final due = 'Vencimento em ${formatDate(d.dueDate)}';
  return switch (situation) {
    DeadlineSituation.overdue ||
    DeadlineSituation.dueSoon ||
    DeadlineSituation.current => (
      tone: tone,
      title: () {
        final x = deadlineDisplay(d, today);
        return [?x.lead, x.text].join(' ');
      }(),
      message: alertCaption(d, today),
    ),
    DeadlineSituation.completed => (
      tone: tone,
      title: d.completedOn == null
          ? d.status.label
          : 'Concluído em ${formatDate(d.completedOn!)}',
      message: due,
    ),
    DeadlineSituation.cancelled || DeadlineSituation.renewed => (
      tone: tone,
      title: d.status.label,
      message: due,
    ),
  };
}

/// Com início (vencimento do ciclo anterior): "21/09/2022 → 21/09/2026".
/// Sem: "Vencimento em 21/09/2018".
String cycleRangeLabel(Deadline cycle, DateTime? previousDueDate) =>
    previousDueDate == null
    ? 'Vencimento em ${formatDate(cycle.dueDate)}'
    : '${formatDate(previousDueDate)} → ${formatDate(cycle.dueDate)}';

/// "Ciclo atual" para o primeiro da lista (mais novo); "Ciclo anterior" nos
/// demais.
String cycleTitle(int index) => index == 0 ? 'Ciclo atual' : 'Ciclo anterior';

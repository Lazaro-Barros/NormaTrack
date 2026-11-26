import 'package:meta/meta.dart';

import '../../features/deadlines/domain/deadline.dart';
import '../utils/date_format.dart';
import '../utils/search_text.dart';

/// Hora fixa das notificações.
// TODO(RF-PRZ-03): horário fixo às 8h, escolha do usuário; confirmar com a
// cliente (C4).
const notificationHour = 8;

/// Teto de agendamentos: alguns Android (Samsung) limitam a 500 alarmes por app.
const maxScheduledNotifications = 400;

/// Avisos semanais avulsos depois do vencimento, quando a repetição ainda não
/// pode ser usada (ver [planDeadlineNotifications]).
const overdueOneShotWeeks = 4;

/// Uma notificação a agendar. [deadlineId] também vai no payload.
@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.deadlineId,
    required this.fireAt,
    required this.weekly,
    required this.title,
    required this.body,
  });

  final int id;
  final String deadlineId;

  /// Local, sem fuso: `DateTime(y, m, d, 8)`.
  final DateTime fireAt;

  /// Repete toda semana no mesmo dia e hora, a partir de [fireAt].
  final bool weekly;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.id == id &&
      other.deadlineId == deadlineId &&
      other.fireAt == fireAt &&
      other.weekly == weekly &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, deadlineId, fireAt, weekly, title, body);

  @override
  String toString() =>
      'PlannedNotification($id, $deadlineId, $fireAt, '
      'weekly: $weekly, "$title", "$body")';
}

/// Plano de notificações dos prazos em aberto (RF-PRZ-03): às 8h de cada dia de
/// lembrete futuro e, a partir de 7 dias depois do vencimento, toda semana.
/// A semanal é uma notificação repetitiva quando a primeira ocorrência está a
/// menos de 7 dias de [now]; senão, [overdueOneShotWeeks] avisos avulsos.
/// Ordenado por horário (desempate: título sem acento/caixa, depois id) e
/// cortado em [max]. [now] é local.
List<PlannedNotification> planDeadlineNotifications(
  List<Deadline> deadlines,
  Map<String, String> companyNames,
  DateTime now, {
  int max = maxScheduledNotifications,
}) {
  final plan = <PlannedNotification>[];
  for (final d in deadlines) {
    if (!d.isOpen) continue;
    final company = companyNames[d.companyId];
    final due = d.dueDate;
    for (final days in d.reminderDays) {
      final date = reminderDate(due, days);
      final fireAt = _at8(date);
      // TODO(RF-PRZ-03): lembrete de hoje depois das 8h não é agendado; o
      // Painel mostra o prazo (suposição, C4).
      if (!fireAt.isAfter(now)) continue;
      plan.add(
        PlannedNotification(
          id: notificationIdFor(d.id, date, weekly: false),
          deadlineId: d.id,
          fireAt: fireAt,
          weekly: false,
          title: d.title,
          body: _withCompany(company, _reminderText(days, due)),
        ),
      );
    }
    var first = _at8(DateTime(due.year, due.month, due.day + 7));
    while (!first.isAfter(now)) {
      first = _plusWeek(first);
    }
    // O Android repete a partir da próxima ocorrência do dia da semana *a
    // partir de agora*, ignorando a data de início. Só dá para usar a
    // repetição quando a primeira ocorrência está a menos de 7 dias; antes
    // disso, avisos avulsos nas primeiras semanas (a sincronização de uma
    // abertura futura troca pela repetição).
    final repeats = first.difference(now) < const Duration(days: 7);
    var fireAt = first;
    for (var i = 0; i < (repeats ? 1 : overdueOneShotWeeks); i++) {
      plan.add(
        PlannedNotification(
          id: notificationIdFor(d.id, fireAt, weekly: true),
          deadlineId: d.id,
          fireAt: fireAt,
          weekly: repeats,
          title: d.title,
          body: _withCompany(company, 'Vencido desde ${formatDate(due)}'),
        ),
      );
      fireAt = _plusWeek(fireAt);
    }
  }
  plan.sort((a, b) {
    final byTime = a.fireAt.compareTo(b.fireAt);
    if (byTime != 0) return byTime;
    final byTitle = normalizeForSearch(a.title)
        .compareTo(normalizeForSearch(b.title));
    if (byTitle != 0) return byTitle;
    return a.id.compareTo(b.id);
  });
  return plan.length > max ? plan.sublist(0, max) : plan;
}

/// Id estável e positivo (cabe no `int` do Android): FNV-1a 32 bits de
/// `"$deadlineId|yyyy-MM-dd|r"` (lembrete) ou `"…|w"` (aviso de vencido).
int notificationIdFor(
  String deadlineId,
  DateTime date, {
  required bool weekly,
}) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final key = '$deadlineId|$y-$m-$d|${weekly ? 'w' : 'r'}';
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return h & 0x7fffffff;
}

DateTime _at8(DateTime d) => DateTime(d.year, d.month, d.day, notificationHour);

DateTime _plusWeek(DateTime d) => _at8(DateTime(d.year, d.month, d.day + 7));

String _reminderText(int daysBefore, DateTime due) => switch (daysBefore) {
  0 => 'Vence hoje',
  1 => 'Vence amanhã (${formatDate(due)})',
  _ => 'Vence em $daysBefore dias (${formatDate(due)})',
};

String _withCompany(String? company, String text) =>
    company == null || company.isEmpty ? text : '$company · $text';

import 'package:meta/meta.dart';

import 'deadline.dart';
import 'deadline_status.dart';

/// Contagem de prazos em aberto por situação numa data (RF-PRZ-05).
@immutable
class SituationCounts {
  const SituationCounts({this.overdue = 0, this.dueSoon = 0, this.current = 0});

  /// Conta só prazos em aberto; os demais (renovado, concluído, cancelado) são
  /// ignorados.
  factory SituationCounts.of(Iterable<Deadline> deadlines, DateTime today) {
    var overdue = 0, dueSoon = 0, current = 0;
    for (final d in deadlines) {
      switch (d.situationOn(today)) {
        case DeadlineSituation.overdue:
          overdue++;
        case DeadlineSituation.dueSoon:
          dueSoon++;
        case DeadlineSituation.current:
          current++;
        case DeadlineSituation.renewed ||
            DeadlineSituation.completed ||
            DeadlineSituation.cancelled:
          break;
      }
    }
    return SituationCounts(
      overdue: overdue,
      dueSoon: dueSoon,
      current: current,
    );
  }

  final int overdue;
  final int dueSoon;
  final int current;

  int get total => overdue + dueSoon + current;

  /// Contagem de [situation]; 0 para as situações que não são de prazo aberto.
  int of(DeadlineSituation situation) => switch (situation) {
    DeadlineSituation.overdue => overdue,
    DeadlineSituation.dueSoon => dueSoon,
    DeadlineSituation.current => current,
    _ => 0,
  };

  @override
  bool operator ==(Object other) =>
      other is SituationCounts &&
      other.overdue == overdue &&
      other.dueSoon == dueSoon &&
      other.current == current;

  @override
  int get hashCode => Object.hash(overdue, dueSoon, current);

  @override
  String toString() =>
      'SituationCounts(overdue: $overdue, dueSoon: $dueSoon, '
      'current: $current)';
}

/// Prazos de [deadlines] na [situation] em [today], mantendo a ordem.
/// [situation] `null` = todos.
List<Deadline> filterBySituation(
  List<Deadline> deadlines,
  DateTime today,
  DeadlineSituation? situation,
) => situation == null
    ? deadlines
    : [
        for (final d in deadlines)
          if (d.situationOn(today) == situation) d,
      ];

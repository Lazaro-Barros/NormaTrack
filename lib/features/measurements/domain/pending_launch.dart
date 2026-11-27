import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'measurement.dart';
import 'measurement_context.dart';
import 'measurement_frequency.dart';
import 'measurement_parameter.dart';
import 'measurement_period.dart';

/// "A lançar" (período corrente) ou "Atrasado" (período passado) (C26).
enum PendingKind { toLaunch, overdue }

/// Período de um contexto da empresa com algum parâmetro sem medição.
@immutable
class PendingLaunch {
  const PendingLaunch({
    required this.companyId,
    required this.context,
    required this.period,
    required this.kind,
    required this.expected,
    required this.filled,
  });

  final String companyId;
  final MeasurementContext context;
  final MeasurementPeriod period;
  final PendingKind kind;

  /// Parâmetros que cobram lançamento no período.
  final int expected;

  /// Desses, quantos têm medição (valor ou justificativa).
  final int filled;

  @override
  bool operator ==(Object other) =>
      other is PendingLaunch &&
      other.companyId == companyId &&
      other.context == context &&
      other.period == period &&
      other.kind == kind &&
      other.expected == expected &&
      other.filled == filled;

  @override
  int get hashCode =>
      Object.hash(companyId, context, period, kind, expected, filled);

  @override
  String toString() =>
      'PendingLaunch($companyId, ${context.code}, $period, ${kind.name}, '
      '$filled/$expected)';
}

/// Pendências de um contexto de uma empresa numa frequência: o que uma linha
/// do Painel mostra e o que "Lançar" abre.
@immutable
class PendingGroup {
  const PendingGroup({
    required this.oldest,
    required this.overdue,
    required this.total,
  });

  /// Período pendente mais antigo.
  final PendingLaunch oldest;

  /// Períodos atrasados.
  final int overdue;

  /// Atrasados mais o corrente, se pendente.
  final int total;

  String get companyId => oldest.companyId;
  MeasurementContext get context => oldest.context;
  MeasurementFrequency get frequency => oldest.period.frequency;

  /// Atrasado se houver qualquer período atrasado.
  PendingKind get kind =>
      overdue > 0 ? PendingKind.overdue : PendingKind.toLaunch;

  @override
  bool operator ==(Object other) =>
      other is PendingGroup &&
      other.oldest == oldest &&
      other.overdue == overdue &&
      other.total == total;

  @override
  int get hashCode => Object.hash(oldest, overdue, total);

  @override
  String toString() => 'PendingGroup($oldest, $overdue atrasados, $total)';
}

/// Agrupa [pending] por empresa, contexto e frequência. Ordem: início do
/// período mais antigo, contexto, empresa, frequência.
// TODO(RF-AMB-02): uma linha por empresa e contexto no Painel (suposição, C28).
List<PendingGroup> groupPendingLaunches(Iterable<PendingLaunch> pending) {
  final groups = pending.groupListsBy(
    (p) => (p.companyId, p.context, p.period.frequency),
  );
  final result = [
    for (final list in groups.values)
      PendingGroup(
        oldest: list.reduce(
          (a, b) => a.period.start.isAfter(b.period.start) ? b : a,
        ),
        overdue: list.where((p) => p.kind == PendingKind.overdue).length,
        total: list.length,
      ),
  ];
  result.sort((a, b) {
    final byStart = a.oldest.period.start.compareTo(b.oldest.period.start);
    if (byStart != 0) return byStart;
    final byContext = a.context.index.compareTo(b.context.index);
    if (byContext != 0) return byContext;
    final byCompany = a.companyId.compareTo(b.companyId);
    return byCompany != 0
        ? byCompany
        : a.frequency.index.compareTo(b.frequency.index);
  });
  return result;
}

/// Pendências calculadas (nunca gravadas). Só parâmetros não arquivados
/// cobram, do período de início até o período que contém [today]. Um período
/// com só parte dos parâmetros preenchidos continua pendente. Ordem: início do
/// período, contexto, empresa.
List<PendingLaunch> pendingLaunches({
  required Iterable<MeasurementParameter> parameters,
  required Iterable<Measurement> measurements,
  required DateTime today,
}) {
  // TODO(RF-AMB-02): arquivar para de cobrar inclusive o passado (suposição, C26).
  final active = parameters.where((p) => !p.isArchived).toList();
  final filled = <String, Set<DateTime>>{};
  for (final m in measurements) {
    (filled[m.parameterId] ??= {}).add(m.periodStart);
  }
  final groups = active.groupListsBy(
    (p) => (p.companyId, p.context, p.frequency),
  );
  final result = <PendingLaunch>[];
  for (final MapEntry(key: (companyId, context, frequency), value: group)
      in groups.entries) {
    result.addAll(
      _pendingInGroup(companyId, context, frequency, group, filled, today),
    );
  }
  result.sort((a, b) {
    final byStart = a.period.start.compareTo(b.period.start);
    if (byStart != 0) return byStart;
    final byContext = a.context.index.compareTo(b.context.index);
    if (byContext != 0) return byContext;
    final byCompany = a.companyId.compareTo(b.companyId);
    return byCompany != 0
        ? byCompany
        : a.period.frequency.index.compareTo(b.period.frequency.index);
  });
  return result;
}

Iterable<PendingLaunch> _pendingInGroup(
  String companyId,
  MeasurementContext context,
  MeasurementFrequency frequency,
  List<MeasurementParameter> group,
  Map<String, Set<DateTime>> filled,
  DateTime today,
) sync* {
  final current = MeasurementPeriod.containing(frequency, today);
  final starts = {for (final p in group) p: p.firstPeriod.start};
  var period = group
      .map((p) => p.firstPeriod)
      .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
  while (period.compareTo(current) <= 0) {
    final expected = [
      for (final p in group)
        if (!starts[p]!.isAfter(period.start)) p,
    ];
    final done = expected
        .where((p) => filled[p.id]?.contains(period.start) ?? false)
        .length;
    if (expected.isNotEmpty && done < expected.length) {
      yield PendingLaunch(
        companyId: companyId,
        context: context,
        period: period,
        kind: period == current ? PendingKind.toLaunch : PendingKind.overdue,
        expected: expected.length,
        filled: done,
      );
    }
    period = period.next;
  }
}

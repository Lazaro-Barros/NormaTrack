import '../../../app/formatters/decimal_input_formatter.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../domain/measurement.dart';
import '../domain/measurement_frequency.dart';
import '../domain/measurement_parameter.dart';
import '../domain/measurement_period.dart';
import '../domain/pending_launch.dart';

const _months = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', //
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

String _capitalized(String s) => s[0].toUpperCase() + s.substring(1);

/// "Semana 48", "Novembro/2026", "1ª quinzena de novembro", "26/11/2026".
String periodTitle(MeasurementPeriod p) => switch (p.frequency) {
  MeasurementFrequency.weekly => 'Semana ${p.isoWeek}',
  MeasurementFrequency.monthly =>
    '${_capitalized(_months[p.start.month - 1])}/${p.start.year}',
  MeasurementFrequency.biweekly =>
    '${p.start.day == 1 ? '1ª' : '2ª'} quinzena de '
        '${_months[p.start.month - 1]}',
  MeasurementFrequency.daily => formatDate(p.start),
};

/// Intervalo do período: "23 a 29/11/2026", "30/11 a 06/12/2026",
/// "28/12/2026 a 03/01/2027". Diária: vazio.
String periodRange(MeasurementPeriod p) {
  if (p.frequency == MeasurementFrequency.daily) return '';
  final (start, end) = (p.start, p.end);
  String two(int n) => n.toString().padLeft(2, '0');
  if (start.year != end.year) {
    return '${formatDate(start)} a ${formatDate(end)}';
  }
  if (start.month != end.month) {
    return '${two(start.day)}/${two(start.month)} a ${formatDate(end)}';
  }
  return '${two(start.day)} a ${formatDate(end)}';
}

/// "Anterior: 61,8" / "Anterior: sem medição"; `null` sem medição anterior.
String? previousLabel(Measurement? m) => switch (m) {
  null => null,
  Measurement(:final value?) => 'Anterior: ${formatDecimal(value)}',
  _ => 'Anterior: sem medição',
};

/// Aviso quando [value] passa dos limites do ponto; `null` dentro deles.
String? limitLabel(MeasurementParameter p, double? value) {
  if (value == null) return null;
  return switch (p.check(value)) {
    LimitStatus.aboveMax => 'Acima do limite (${formatDecimal(p.limitMax!)})',
    LimitStatus.belowMin => 'Abaixo do limite (${formatDecimal(p.limitMin!)})',
    _ => null,
  };
}

/// Situação de um contexto semanal de medição para a linha do módulo.
({String label, StatusTone? tone}) monitoringStatus(
  List<PendingLaunch> pending,
  int activePoints,
) {
  if (activePoints == 0) return (label: 'Nenhum ponto cadastrado', tone: null);
  final overdue = pending.where((p) => p.kind == PendingKind.overdue).length;
  if (overdue == 1) {
    return (label: '1 semana atrasada', tone: StatusTone.overdue);
  }
  if (overdue > 1) {
    return (label: '$overdue semanas atrasadas', tone: StatusTone.overdue);
  }
  if (pending.isNotEmpty) return (label: 'A lançar', tone: StatusTone.dueSoon);
  return (label: 'Em dia', tone: StatusTone.ok);
}

/// "1 ponto · semanal" / "4 pontos · semanal".
String pointsSubtitle(int n) => '$n ${n == 1 ? 'ponto' : 'pontos'} · semanal';

/// "Limite 70,0 dB(A)" / "Sem limite".
String pointLimitLabel(MeasurementParameter p) => switch (p.limitMax) {
  final max? => 'Limite ${formatDecimal(max)} ${p.unit ?? ''}'.trim(),
  null => 'Sem limite',
};

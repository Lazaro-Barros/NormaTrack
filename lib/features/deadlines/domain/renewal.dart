import 'dart:math' as math;

/// Sugestão de novo vencimento: o mesmo intervalo, em meses, entre o ciclo
/// anterior e o atual; sem ciclo anterior (ou intervalo < 1 mês), 12 meses.
/// O dia é o do vencimento, limitado ao último dia do mês de destino.
// TODO(RF-PRZ-04): sugestão repete o intervalo do ciclo anterior (C22).
DateTime suggestedRenewalDate(DateTime dueDate, {DateTime? previousDueDate}) {
  final prev = previousDueDate;
  var months = prev == null
      ? 0
      : (dueDate.year - prev.year) * 12 + (dueDate.month - prev.month);
  if (months < 1) months = 12;
  final total = dueDate.year * 12 + (dueDate.month - 1) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final day = math.min(dueDate.day, DateTime(year, month + 1, 0).day);
  return DateTime(year, month, day);
}

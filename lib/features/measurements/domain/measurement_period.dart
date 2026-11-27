import 'package:meta/meta.dart';

import 'measurement_frequency.dart';

/// Período de lançamento. Só se cria por [MeasurementPeriod.containing], então
/// [start] é sempre o início do período da frequência: o próprio dia, a
/// segunda-feira da semana ISO, o dia 1 ou 16 da quinzena, ou o dia 1 do mês.
@immutable
class MeasurementPeriod implements Comparable<MeasurementPeriod> {
  const MeasurementPeriod._(this.frequency, this.start);

  factory MeasurementPeriod.containing(
    MeasurementFrequency frequency,
    DateTime date,
  ) {
    final (y, m, d) = (date.year, date.month, date.day);
    return MeasurementPeriod._(frequency, switch (frequency) {
      MeasurementFrequency.daily => DateTime(y, m, d),
      MeasurementFrequency.weekly => DateTime(y, m, d - (date.weekday - 1)),
      MeasurementFrequency.biweekly => DateTime(y, m, d <= 15 ? 1 : 16),
      MeasurementFrequency.monthly => DateTime(y, m),
    });
  }

  final MeasurementFrequency frequency;

  /// Primeiro dia, inclusivo. Só a data, local.
  final DateTime start;

  /// Último dia, inclusivo.
  DateTime get end => switch (frequency) {
    MeasurementFrequency.daily => start,
    MeasurementFrequency.weekly => _day(6),
    MeasurementFrequency.biweekly =>
      start.day == 1
          ? DateTime(start.year, start.month, 15)
          : DateTime(start.year, start.month + 1, 0),
    MeasurementFrequency.monthly => DateTime(start.year, start.month + 1, 0),
  };

  MeasurementPeriod get next => MeasurementPeriod.containing(
    frequency,
    DateTime(end.year, end.month, end.day + 1),
  );

  MeasurementPeriod get previous => MeasurementPeriod.containing(
    frequency,
    DateTime(start.year, start.month, start.day - 1),
  );

  /// Ignora a hora de [date].
  bool contains(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// Número da semana ISO. Só para [MeasurementFrequency.weekly].
  int get isoWeek {
    final thursday = _thursday;
    final dayOfYear =
        DateTime.utc(
          thursday.year,
          thursday.month,
          thursday.day,
        ).difference(DateTime.utc(thursday.year)).inDays +
        1;
    return (dayOfYear - 1) ~/ 7 + 1;
  }

  /// Ano da semana ISO (2026-12-28 está na semana 53 de 2026; 2024-12-30, na
  /// semana 1 de 2025). Só para [MeasurementFrequency.weekly].
  int get isoWeekYear => _thursday.year;

  DateTime get _thursday {
    if (frequency != MeasurementFrequency.weekly) {
      throw StateError('Semana ISO só existe em período semanal');
    }
    return _day(3);
  }

  DateTime _day(int offset) =>
      DateTime(start.year, start.month, start.day + offset);

  /// Por [start]. Frequências diferentes não se comparam.
  @override
  int compareTo(MeasurementPeriod other) {
    if (other.frequency != frequency) {
      throw ArgumentError.value(other, 'other', 'frequência diferente');
    }
    return start.compareTo(other.start);
  }

  @override
  bool operator ==(Object other) =>
      other is MeasurementPeriod &&
      other.frequency == frequency &&
      other.start == start;

  @override
  int get hashCode => Object.hash(frequency, start);

  @override
  String toString() =>
      'MeasurementPeriod(${frequency.code}, ${_iso(start)}..${_iso(end)})';
}

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';
import 'package:normatrack/features/measurements/domain/pending_launch.dart';
import 'package:normatrack/features/measurements/presentation/measurement_labels.dart';

void main() {
  MeasurementPeriod at(MeasurementFrequency f, int y, int m, int d) =>
      MeasurementPeriod.containing(f, DateTime(y, m, d));
  const weekly = MeasurementFrequency.weekly;

  test('periodTitle', () {
    expect(periodTitle(at(weekly, 2026, 9, 23)), 'Semana 39');
    expect(
      periodTitle(at(MeasurementFrequency.monthly, 2026, 11, 5)),
      'Novembro/2026',
    );
    expect(
      periodTitle(at(MeasurementFrequency.biweekly, 2026, 11, 5)),
      '1ª quinzena de novembro',
    );
    expect(
      periodTitle(at(MeasurementFrequency.biweekly, 2026, 3, 20)),
      '2ª quinzena de março',
    );
    expect(
      periodTitle(at(MeasurementFrequency.daily, 2026, 11, 26)),
      '26/11/2026',
    );
  });

  test('periodRange', () {
    expect(periodRange(at(weekly, 2026, 9, 23)), '21 a 27/09/2026');
    expect(periodRange(at(weekly, 2026, 12, 1)), '30/11 a 06/12/2026');
    expect(periodRange(at(weekly, 2026, 12, 30)), '28/12/2026 a 03/01/2027');
    expect(
      periodRange(at(MeasurementFrequency.monthly, 2028, 2, 3)),
      '01 a 29/02/2028',
    );
    expect(periodRange(at(MeasurementFrequency.daily, 2026, 11, 26)), '');
  });

  Measurement m(double? value) => Measurement(
    id: 'm',
    parameterId: 'p',
    periodStart: DateTime(2026, 9, 21),
    value: value,
    note: value == null ? 'Fábrica parada' : null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('previousLabel', () {
    expect(previousLabel(null), isNull);
    expect(previousLabel(m(61.8)), 'Anterior: 61,8');
    expect(previousLabel(m(64)), 'Anterior: 64,0');
    expect(previousLabel(m(null)), 'Anterior: sem medição');
  });

  MeasurementParameter point({double? min, double? max}) =>
      MeasurementParameter(
        id: 'p',
        companyId: 'c',
        context: MeasurementContext.noise,
        name: 'Portão',
        unit: 'dB(A)',
        frequency: weekly,
        position: 0,
        startDate: DateTime(2026, 9, 1),
        limitMin: min,
        limitMax: max,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

  test('limitLabel e pointLimitLabel', () {
    expect(limitLabel(point(max: 70), 70), isNull);
    expect(limitLabel(point(max: 70), 72.5), 'Acima do limite (70,0)');
    expect(limitLabel(point(min: 6, max: 8), 5.5), 'Abaixo do limite (6,0)');
    expect(limitLabel(point(), 120), isNull);
    expect(limitLabel(point(max: 70), null), isNull);
    expect(pointLimitLabel(point(max: 70)), 'Limite 70,0 dB(A)');
    expect(pointLimitLabel(point()), 'Sem limite');
  });

  PendingLaunch pending(PendingKind kind) => PendingLaunch(
    companyId: 'c',
    context: MeasurementContext.noise,
    period: at(weekly, 2026, 9, 29),
    kind: kind,
    expected: 2,
    filled: 0,
  );

  test('monitoringStatus', () {
    expect(monitoringStatus(const [], 0), (
      label: 'Nenhum ponto cadastrado',
      tone: null,
    ));
    expect(monitoringStatus(const [], 2), (
      label: 'Em dia',
      tone: StatusTone.ok,
    ));
    expect(monitoringStatus([pending(PendingKind.toLaunch)], 2), (
      label: 'A lançar',
      tone: StatusTone.dueSoon,
    ));
    expect(
      monitoringStatus([
        pending(PendingKind.overdue),
        pending(PendingKind.toLaunch),
      ], 2),
      (label: '1 semana atrasada', tone: StatusTone.overdue),
    );
    expect(
      monitoringStatus([
        pending(PendingKind.overdue),
        pending(PendingKind.overdue),
      ], 2),
      (label: '2 semanas atrasadas', tone: StatusTone.overdue),
    );
  });

  test('pointsSubtitle', () {
    expect(pointsSubtitle(1), '1 ponto · semanal');
    expect(pointsSubtitle(4), '4 pontos · semanal');
  });

  test('overdueLabel', () {
    expect(overdueLabel(weekly, 1), '1 semana atrasada');
    expect(overdueLabel(weekly, 3), '3 semanas atrasadas');
    expect(
      overdueLabel(MeasurementFrequency.biweekly, 1),
      '1 quinzena atrasada',
    );
    expect(
      overdueLabel(MeasurementFrequency.biweekly, 2),
      '2 quinzenas atrasadas',
    );
    expect(overdueLabel(MeasurementFrequency.monthly, 1), '1 mês atrasado');
    expect(overdueLabel(MeasurementFrequency.monthly, 4), '4 meses atrasados');
    expect(overdueLabel(MeasurementFrequency.daily, 1), '1 dia atrasado');
    expect(overdueLabel(MeasurementFrequency.daily, 5), '5 dias atrasados');
  });

  test('pendingGroupStatus e pendingPeriodLabel', () {
    expect(
      pendingGroupStatus(
        PendingGroup(
          oldest: pending(PendingKind.overdue),
          overdue: 2,
          total: 3,
        ),
      ),
      (label: '2 semanas atrasadas', tone: StatusTone.overdue),
    );
    expect(
      pendingGroupStatus(
        PendingGroup(
          oldest: pending(PendingKind.toLaunch),
          overdue: 0,
          total: 1,
        ),
      ),
      (label: 'A lançar', tone: StatusTone.dueSoon),
    );
    expect(
      pendingPeriodLabel(at(weekly, 2026, 11, 10)),
      'Semana 46 · 09 a 15/11/2026',
    );
    expect(
      pendingPeriodLabel(at(MeasurementFrequency.daily, 2026, 11, 26)),
      '26/11/2026',
    );
  });
}

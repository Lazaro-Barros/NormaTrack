import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';
import 'package:normatrack/features/measurements/domain/pending_launch.dart';

void main() {
  // Quinta, semana 48 (23 a 29/11/2026).
  final today = DateTime(2026, 11, 26);

  MeasurementParameter param(
    String id, {
    String company = 'c1',
    MeasurementContext context = MeasurementContext.noise,
    MeasurementFrequency frequency = MeasurementFrequency.weekly,
    DateTime? start,
    bool archived = false,
  }) => MeasurementParameter(
    id: id,
    companyId: company,
    context: context,
    name: id,
    frequency: frequency,
    position: 0,
    // Quarta da semana 45 (02 a 08/11).
    startDate: start ?? DateTime(2026, 11, 4),
    archivedAt: archived ? DateTime.utc(2026, 11, 20) : null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  var nextId = 0;
  Measurement m(
    String parameterId,
    DateTime periodStart, {
    double? value = 60,
  }) => Measurement(
    id: 'm${++nextId}',
    parameterId: parameterId,
    periodStart: periodStart,
    value: value,
    note: value == null ? 'Fábrica parada' : null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  PendingLaunch pending(
    DateTime start,
    PendingKind kind,
    int filled,
    int expected, {
    String company = 'c1',
    MeasurementContext context = MeasurementContext.noise,
    MeasurementFrequency frequency = MeasurementFrequency.weekly,
  }) => PendingLaunch(
    companyId: company,
    context: context,
    period: MeasurementPeriod.containing(frequency, start),
    kind: kind,
    expected: expected,
    filled: filled,
  );

  final w45 = DateTime(2026, 11, 2);
  final w46 = DateTime(2026, 11, 9);
  final w47 = DateTime(2026, 11, 16);
  final w48 = DateTime(2026, 11, 23);

  final noiseMeasurements = [
    m('p1', w45),
    m('p2', w45),
    m('p1', w46),
    m('p1', w47, value: null), // justificada conta como lançada
    m('p2', w47),
  ];

  test('parcial e período atual sem nada continuam pendentes', () {
    expect(
      pendingLaunches(
        parameters: [param('p1'), param('p2')],
        measurements: noiseMeasurements,
        today: today,
      ),
      [
        pending(w46, PendingKind.overdue, 1, 2),
        pending(w48, PendingKind.toLaunch, 0, 2),
      ],
    );
  });

  test('parâmetro novo só cobra a partir do período de início', () {
    final result = pendingLaunches(
      parameters: [
        param('p1'),
        param('p2'),
        param('p3', start: DateTime(2026, 11, 18)),
      ],
      measurements: noiseMeasurements,
      today: today,
    );
    expect(result, [
      pending(w46, PendingKind.overdue, 1, 2),
      pending(w47, PendingKind.overdue, 2, 3),
      pending(w48, PendingKind.toLaunch, 0, 3),
    ]);
  });

  test('arquivado e início futuro não cobram', () {
    expect(
      pendingLaunches(
        parameters: [
          param('p1', archived: true),
          param('p2', start: DateTime(2026, 11, 30)),
        ],
        measurements: const [],
        today: today,
      ),
      isEmpty,
    );
  });

  test('tudo lançado não gera pendência', () {
    expect(
      pendingLaunches(
        parameters: [param('p1')],
        measurements: [m('p1', w45), m('p1', w46), m('p1', w47), m('p1', w48)],
        today: today,
      ),
      isEmpty,
    );
  });

  test('mensal, diária e quinzenal', () {
    final result = pendingLaunches(
      parameters: [
        param(
          'mes',
          context: MeasurementContext.effluent,
          frequency: MeasurementFrequency.monthly,
          start: DateTime(2026, 9, 15),
        ),
        param(
          'dia',
          context: MeasurementContext.water,
          frequency: MeasurementFrequency.daily,
          start: DateTime(2026, 11, 24),
        ),
        param(
          'quinzena',
          context: MeasurementContext.effluent,
          frequency: MeasurementFrequency.biweekly,
          start: DateTime(2026, 11, 3),
        ),
      ],
      measurements: [
        m('mes', DateTime(2026, 10)),
        m('dia', DateTime(2026, 11, 25)),
      ],
      today: today,
    );
    expect(result, [
      pending(
        DateTime(2026, 9),
        PendingKind.overdue,
        0,
        1,
        context: MeasurementContext.effluent,
        frequency: MeasurementFrequency.monthly,
      ),
      pending(
        DateTime(2026, 11),
        PendingKind.overdue,
        0,
        1,
        context: MeasurementContext.effluent,
        frequency: MeasurementFrequency.biweekly,
      ),
      pending(
        DateTime(2026, 11),
        PendingKind.toLaunch,
        0,
        1,
        context: MeasurementContext.effluent,
        frequency: MeasurementFrequency.monthly,
      ),
      pending(
        DateTime(2026, 11, 16),
        PendingKind.toLaunch,
        0,
        1,
        context: MeasurementContext.effluent,
        frequency: MeasurementFrequency.biweekly,
      ),
      pending(
        DateTime(2026, 11, 24),
        PendingKind.overdue,
        0,
        1,
        context: MeasurementContext.water,
        frequency: MeasurementFrequency.daily,
      ),
      pending(
        DateTime(2026, 11, 26),
        PendingKind.toLaunch,
        0,
        1,
        context: MeasurementContext.water,
        frequency: MeasurementFrequency.daily,
      ),
    ]);
  });

  test(
    'ordena por período, contexto e empresa; ignora medição sem parâmetro',
    () {
      final result = pendingLaunches(
        parameters: [
          param('b', company: 'c2', start: w48),
          param('a', company: 'c1', start: w48),
          param(
            'e',
            company: 'c1',
            context: MeasurementContext.effluent,
            start: w48,
          ),
        ],
        measurements: [m('fantasma', w48)],
        today: today,
      );
      expect(result, [
        pending(w48, PendingKind.toLaunch, 0, 1, company: 'c1'),
        pending(w48, PendingKind.toLaunch, 0, 1, company: 'c2'),
        pending(
          w48,
          PendingKind.toLaunch,
          0,
          1,
          context: MeasurementContext.effluent,
        ),
      ]);
    },
  );
}

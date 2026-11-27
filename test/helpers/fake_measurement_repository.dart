import 'dart:async';

import 'package:normatrack/core/utils/search_text.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';
import 'package:normatrack/features/measurements/domain/measurement_parameter.dart';
import 'package:normatrack/features/measurements/domain/measurement_period.dart';
import 'package:normatrack/features/measurements/domain/measurement_repository.dart';
import 'package:normatrack/features/measurements/domain/measurement_validation.dart';
import 'package:normatrack/features/measurements/domain/pending_launch.dart';

import 'fake_company_repository.dart';

/// Repositório de medições em memória para testes de widget (sem drift). Com
/// [companies], confere empresa viva e módulo habilitado como o real, e as
/// pendências vêm do mesmo `pendingLaunches` do domínio.
class FakeMeasurementRepository implements MeasurementRepository {
  FakeMeasurementRepository({DateTime? now, this.companies})
    : _now = now ?? DateTime.utc(2026, 9, 29, 12);

  final DateTime _now;
  final FakeCompanyRepository? companies;
  final _parameters = <String, MeasurementParameter>{};
  final _measurements = <String, Measurement>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Chamadas a [savePeriod], para os testes conferirem o que foi enviado.
  final saved = <(MeasurementPeriod, Map<String, MeasurementEntry?>)>[];

  /// Medições vivas.
  List<Measurement> get measurements => _measurements.values.toList();

  /// Cria o ponto sem checar empresa (dados de partida dos testes).
  MeasurementParameter seedPoint(
    String companyId,
    String name, {
    double? limitMax,
    DateTime? startDate,
    bool archived = false,
    MeasurementContext context = MeasurementContext.noise,
  }) {
    final id = 'p${_nextId++}';
    final position = _group(companyId, context).length;
    _parameters[id] = MeasurementParameter(
      id: id,
      companyId: companyId,
      context: context,
      name: name,
      unit: context.defaultUnit,
      frequency: MeasurementFrequency.weekly,
      position: position,
      startDate: startDate ?? DateTime(2026, 9, 1),
      limitMax: limitMax,
      archivedAt: archived ? _now : null,
      createdAt: _now,
      updatedAt: _now,
    );
    _notify();
    return _parameters[id]!;
  }

  /// Grava uma medição sem validar (dados de partida dos testes).
  void seedMeasurement(
    String parameterId,
    DateTime periodStart, {
    double? value,
    String? note,
  }) {
    final id = 'm${_nextId++}';
    _measurements[id] = Measurement(
      id: id,
      parameterId: parameterId,
      periodStart: periodStart,
      value: value,
      note: note,
      createdAt: _now,
      updatedAt: _now,
    );
    _notify();
  }

  @override
  Stream<List<MeasurementParameter>> watchParameters(
    String companyId,
    MeasurementContext context, {
    bool includeArchived = false,
  }) => _watch(
    () => [
      for (final p in _group(companyId, context))
        if (includeArchived || !p.isArchived) p,
    ],
  );

  @override
  Future<MeasurementParameter?> findParameter(String id) async =>
      _parameters[id];

  @override
  Future<MeasurementParameter> createParameter(
    String companyId,
    MeasurementContext context,
    MeasurementParameterInput input,
  ) async {
    final companies = this.companies;
    if (companies != null) {
      final company = await companies.findById(companyId);
      if (company == null) throw CompanyNotFoundException(companyId);
      if (!company.hasModule(context.module)) {
        throw MeasurementModuleNotEnabledException(companyId, context.module);
      }
    }
    final data = _validated(companyId, context, input);
    final id = 'p${_nextId++}';
    _parameters[id] = MeasurementParameter(
      id: id,
      companyId: companyId,
      context: context,
      name: data.name,
      unit: data.unit,
      frequency: data.frequency,
      position: _group(companyId, context).length,
      startDate: data.startDate,
      limitMin: data.limitMin,
      limitMax: data.limitMax,
      createdAt: _now,
      updatedAt: _now,
    );
    _notify();
    return _parameters[id]!;
  }

  @override
  Future<MeasurementParameter> updateParameter(
    String id,
    MeasurementParameterInput input,
  ) async {
    final current = _require(id);
    final data = _validated(
      current.companyId,
      current.context,
      input,
      exceptId: id,
    );
    _parameters[id] = _copy(current, input: data);
    _notify();
    return _parameters[id]!;
  }

  @override
  Future<void> reorderParameters(
    String companyId,
    MeasurementContext context,
    List<String> orderedIds,
  ) async {
    for (final (i, id) in orderedIds.indexed) {
      _parameters[id] = _copy(_require(id), position: i);
    }
    _notify();
  }

  @override
  Future<void> archiveParameter(String id) async {
    final p = _require(id);
    if (!p.isArchived) _parameters[id] = _copy(p, archivedAt: _now);
    _notify();
  }

  @override
  Future<void> unarchiveParameter(String id) async {
    final p = _require(id);
    if (p.isArchived) _parameters[id] = _copy(p, unarchive: true);
    _notify();
  }

  @override
  Future<void> deleteParameter(String id) async {
    _require(id);
    _parameters.remove(id);
    _measurements.removeWhere((_, m) => m.parameterId == id);
    _notify();
  }

  @override
  Stream<List<Measurement>> watchMeasurements(
    String companyId,
    MeasurementContext context, {
    DateTime? from,
    DateTime? to,
  }) => _watch(() {
    final ids = {for (final p in _group(companyId, context)) p.id};
    return [
      for (final m in _measurements.values)
        if (ids.contains(m.parameterId) &&
            (from == null || !m.periodStart.isBefore(from)) &&
            (to == null || !m.periodStart.isAfter(to)))
          m,
    ]..sort((a, b) => a.periodStart.compareTo(b.periodStart));
  });

  @override
  Future<void> savePeriod(
    MeasurementPeriod period,
    Map<String, MeasurementEntry?> entries, {
    required DateTime today,
  }) async {
    if (period.compareTo(
          MeasurementPeriod.containing(period.frequency, today),
        ) >
        0) {
      throw FuturePeriodException(period);
    }
    final errors = <String, List<EntryFieldError>>{};
    final clean = <String, MeasurementEntry?>{};
    for (final MapEntry(key: id, value: entry) in entries.entries) {
      _require(id);
      final e = entry == null ? null : normalizeEntry(entry);
      if (e != null && validateEntry(e).isNotEmpty) {
        errors[id] = validateEntry(e);
      }
      clean[id] = e;
    }
    if (errors.isNotEmpty) {
      throw MeasurementValidationException(entryErrors: errors);
    }
    saved.add((period, clean));
    for (final MapEntry(key: id, value: entry) in clean.entries) {
      _measurements.removeWhere(
        (_, m) => m.parameterId == id && m.periodStart == period.start,
      );
      if (entry != null) {
        seedMeasurement(id, period.start, value: entry.value, note: entry.note);
      }
    }
    _notify();
  }

  @override
  Stream<List<PendingLaunch>> watchPendingLaunches({
    required DateTime today,
    String? companyId,
  }) => _watch(() {
    final parameters = [
      for (final p in _parameters.values)
        if ((companyId == null || p.companyId == companyId) &&
            _companyAllows(p))
          p,
    ];
    return pendingLaunches(
      parameters: parameters,
      measurements: _measurements.values,
      today: today,
    );
  }, also: companies?.changes);

  // -------------------------------------------------------------------------

  List<MeasurementParameter> _group(
    String companyId,
    MeasurementContext context,
  ) => [
    for (final p in _parameters.values)
      if (p.companyId == companyId && p.context == context) p,
  ]..sort((a, b) => a.position.compareTo(b.position));

  MeasurementParameter _require(String id) =>
      _parameters[id] ?? (throw MeasurementParameterNotFoundException(id));

  MeasurementParameterInput _validated(
    String companyId,
    MeasurementContext context,
    MeasurementParameterInput input, {
    String? exceptId,
  }) {
    final data = normalizeParameterInput(input);
    final errors = validateParameter(data);
    final key = normalizeForSearch(data.name);
    if (data.name.isNotEmpty &&
        _group(
          companyId,
          context,
        ).any((p) => p.id != exceptId && normalizeForSearch(p.name) == key)) {
      errors.add(
        const ParameterFieldError(
          ParameterField.name,
          ParameterFieldErrorType.duplicate,
        ),
      );
    }
    if (errors.isNotEmpty) {
      throw MeasurementValidationException(parameterErrors: errors);
    }
    return data;
  }

  MeasurementParameter _copy(
    MeasurementParameter p, {
    MeasurementParameterInput? input,
    int? position,
    DateTime? archivedAt,
    bool unarchive = false,
  }) {
    final i = input ?? p.toInput();
    return MeasurementParameter(
      id: p.id,
      companyId: p.companyId,
      context: p.context,
      name: i.name,
      unit: i.unit,
      frequency: i.frequency,
      position: position ?? p.position,
      startDate: i.startDate,
      limitMin: i.limitMin,
      limitMax: i.limitMax,
      archivedAt: unarchive ? null : (archivedAt ?? p.archivedAt),
      createdAt: p.createdAt,
      updatedAt: _now,
    );
  }

  bool _companyAllows(MeasurementParameter p) {
    final companies = this.companies;
    if (companies == null) return true;
    for (final c in companies.all) {
      if (c.id == p.companyId) {
        return !c.isArchived && c.hasModule(p.context.module);
      }
    }
    return false;
  }

  Stream<T> _watch<T>(T Function() load, {Stream<void>? also}) {
    late StreamController<T> controller;
    final subs = <StreamSubscription<void>>[];
    controller = StreamController<T>(
      onListen: () {
        controller.add(load());
        for (final source in [_changes.stream, ?also]) {
          subs.add(source.listen((_) => controller.add(load())));
        }
      },
      onCancel: () {
        for (final s in subs) {
          s.cancel();
        }
      },
    );
    return controller.stream;
  }

  void _notify() => _changes.add(null);
}

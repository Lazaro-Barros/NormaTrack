import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/search_text.dart';
import '../../companies/domain/company_repository.dart';
import '../domain/measurement.dart';
import '../domain/measurement_context.dart';
import '../domain/measurement_parameter.dart';
import '../domain/measurement_period.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_validation.dart';
import '../domain/pending_launch.dart';
import 'measurement_mapper.dart';

/// A UI depende só do tipo [MeasurementRepository].
final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => LocalMeasurementRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

class LocalMeasurementRepository implements MeasurementRepository {
  LocalMeasurementRepository(
    this._db, {
    required this._clock,
    required this._newId,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  $MeasurementParametersTable get _parameters => _db.measurementParameters;
  $MeasurementsTable get _measurements => _db.measurements;
  $CompaniesTable get _companies => _db.companies;
  $CompanyModulesTable get _modules => _db.companyModules;

  // Leitura -----------------------------------------------------------------

  @override
  Stream<List<MeasurementParameter>> watchParameters(
    String companyId,
    MeasurementContext context, {
    bool includeArchived = false,
  }) => _watchList(() async {
    final rows =
        await (_db.select(_parameters)..where((p) {
              var where = _ofGroup(p, companyId, context);
              if (!includeArchived) where &= p.archivedAt.isNull();
              return where;
            }))
            .get();
    return _sorted(rows.map(parameterFromRow).toList());
  });

  @override
  Future<MeasurementParameter?> findParameter(String id) async {
    final row = await _liveParameter(id);
    return row == null ? null : parameterFromRow(row);
  }

  @override
  Stream<List<Measurement>> watchMeasurements(
    String companyId,
    MeasurementContext context, {
    DateTime? from,
    DateTime? to,
  }) => _watchList(() async {
    final query =
        _db.select(_measurements).join([
            innerJoin(
              _parameters,
              _parameters.id.equalsExp(_measurements.parameterId),
            ),
          ])
          ..where(
            _ofGroup(_parameters, companyId, context) &
                _measurements.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(_measurements.periodStart),
            OrderingTerm.asc(_parameters.position),
            OrderingTerm.asc(_measurements.id),
          ]);
    // Datas como texto AAAA-MM-DD: a comparação de texto respeita a ordem.
    if (from != null) {
      query.where(
        _measurements.periodStart.isBiggerOrEqualValue(_dateOnly(from)),
      );
    }
    if (to != null) {
      query.where(
        _measurements.periodStart.isSmallerOrEqualValue(_dateOnly(to)),
      );
    }
    final rows = await query.get();
    return [
      for (final r in rows) measurementFromRow(r.readTable(_measurements)),
    ];
  });

  @override
  Stream<List<PendingLaunch>> watchPendingLaunches({
    required DateTime today,
    String? companyId,
  }) => _watchList(() async {
    final query =
        _db.select(_parameters).join([
          innerJoin(_companies, _companies.id.equalsExp(_parameters.companyId)),
        ])..where(
          _parameters.deletedAt.isNull() &
              _parameters.archivedAt.isNull() &
              _companies.deletedAt.isNull() &
              _companies.archivedAt.isNull(),
        );
    if (companyId != null) query.where(_parameters.companyId.equals(companyId));
    final enabled = await _enabledModules();
    final parameters = [
      for (final r in await query.get())
        parameterFromRow(r.readTable(_parameters)),
    ].where((p) => enabled.contains((p.companyId, p.context.module.code)));
    final ids = [for (final p in parameters) p.id];
    final measurements = ids.isEmpty
        ? const <Measurement>[]
        : [
            for (final r
                in await (_db.select(_measurements)..where(
                      (m) => m.parameterId.isIn(ids) & m.deletedAt.isNull(),
                    ))
                    .get())
              measurementFromRow(r),
          ];
    return pendingLaunches(
      parameters: parameters,
      measurements: measurements,
      today: today,
    );
  });

  Future<Set<(String, String)>> _enabledModules() async => {
    for (final m in await (_db.select(
      _modules,
    )..where((m) => m.enabled.equals(true) & m.deletedAt.isNull())).get())
      (m.companyId, m.moduleType),
  };

  /// Reexecuta [load] quando parâmetros, medições, empresas ou módulos mudam.
  /// O SQL precisa ser único no app (D008).
  Stream<T> _watch<T>(Future<T> Function() load) => _db
      .customSelect(
        'SELECT 1 AS measurements_changed',
        readsFrom: {_parameters, _measurements, _companies, _modules},
      )
      .watch()
      .asyncMap((_) => load());

  Stream<List<T>> _watchList<T>(Future<List<T>> Function() load) =>
      _watch(load).distinct(ListEquality<T>().equals);

  /// Posição, nome sem acento/caixa, id.
  List<MeasurementParameter> _sorted(List<MeasurementParameter> parameters) {
    final names = {
      for (final p in parameters) p.id: normalizeForSearch(p.name),
    };
    return parameters..sort((a, b) {
      final byPosition = a.position.compareTo(b.position);
      if (byPosition != 0) return byPosition;
      final byName = names[a.id]!.compareTo(names[b.id]!);
      return byName != 0 ? byName : a.id.compareTo(b.id);
    });
  }

  // Escrita -----------------------------------------------------------------

  @override
  Future<MeasurementParameter> createParameter(
    String companyId,
    MeasurementContext context,
    MeasurementParameterInput input,
  ) => _db.transaction(() async {
    final company =
        await (_db.select(_companies)
              ..where((c) => c.id.equals(companyId) & c.deletedAt.isNull()))
            .getSingleOrNull();
    if (company == null) throw CompanyNotFoundException(companyId);
    await _checkModuleEnabled(companyId, context);
    final data = await _validated(companyId, context, input);
    final siblings = await (_db.select(
      _parameters,
    )..where((p) => _ofGroup(p, companyId, context))).get();
    final position = siblings.isEmpty
        ? 0
        : siblings.map((p) => p.position).max + 1;
    final id = _newId();
    final now = _clock();
    await _db
        .into(_parameters)
        .insert(
          MeasurementParametersCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            companyId: companyId,
            context: context.code,
            name: data.name,
            unit: Value(data.unit),
            frequency: data.frequency.code,
            position: position,
            startDate: data.startDate,
            limitMin: Value(data.limitMin),
            limitMax: Value(data.limitMax),
          ),
        );
    return (await findParameter(id))!;
  });

  @override
  Future<MeasurementParameter> updateParameter(
    String id,
    MeasurementParameterInput input,
  ) => _db.transaction(() async {
    final current = parameterFromRow(await _requireLive(id));
    final data = await _validated(
      current.companyId,
      current.context,
      input,
      exceptId: id,
    );
    if (data == current.toInput()) return current;
    if (data.frequency != current.frequency && await _hasMeasurements(id)) {
      throw const MeasurementValidationException(
        parameterErrors: [
          ParameterFieldError(
            ParameterField.frequency,
            ParameterFieldErrorType.locked,
          ),
        ],
      );
    }
    await (_db.update(_parameters)..where((p) => p.id.equals(id))).write(
      MeasurementParametersCompanion(
        name: Value(data.name),
        unit: Value(data.unit),
        frequency: Value(data.frequency.code),
        startDate: Value(data.startDate),
        limitMin: Value(data.limitMin),
        limitMax: Value(data.limitMax),
        updatedAt: Value(_clock()),
      ),
    );
    return (await findParameter(id))!;
  });

  @override
  Future<void> reorderParameters(
    String companyId,
    MeasurementContext context,
    List<String> orderedIds,
  ) => _db.transaction(() async {
    final rows = await (_db.select(
      _parameters,
    )..where((p) => _ofGroup(p, companyId, context))).get();
    final byId = {for (final r in rows) r.id: r};
    if (orderedIds.length != byId.length ||
        !const SetEquality<String>().equals(
          orderedIds.toSet(),
          byId.keys.toSet(),
        )) {
      throw ArgumentError.value(
        orderedIds,
        'orderedIds',
        'precisa ter exatamente os parâmetros do contexto',
      );
    }
    final now = _clock();
    for (final (position, id) in orderedIds.indexed) {
      if (byId[id]!.position == position) continue;
      await (_db.update(_parameters)..where((p) => p.id.equals(id))).write(
        MeasurementParametersCompanion(
          position: Value(position),
          updatedAt: Value(now),
        ),
      );
    }
  });

  @override
  Future<void> archiveParameter(String id) => _setArchived(id, archived: true);

  @override
  Future<void> unarchiveParameter(String id) =>
      _setArchived(id, archived: false);

  Future<void> _setArchived(String id, {required bool archived}) =>
      _db.transaction(() async {
        final row = await _requireLive(id);
        if ((row.archivedAt != null) == archived) return;
        final now = _clock();
        await (_db.update(_parameters)..where((p) => p.id.equals(id))).write(
          MeasurementParametersCompanion(
            archivedAt: Value(archived ? now : null),
            updatedAt: Value(now),
          ),
        );
      });

  @override
  Future<void> deleteParameter(String id) => _db.transaction(() async {
    await _requireLive(id);
    final now = _clock();
    await (_db.update(
      _measurements,
    )..where((m) => m.parameterId.equals(id) & m.deletedAt.isNull())).write(
      MeasurementsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (_db.update(_parameters)..where((p) => p.id.equals(id))).write(
      MeasurementParametersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  });

  @override
  Future<void> savePeriod(
    MeasurementPeriod period,
    Map<String, MeasurementEntry?> entries, {
    required DateTime today,
  }) => _db.transaction(() async {
    if (period.compareTo(
          MeasurementPeriod.containing(period.frequency, today),
        ) >
        0) {
      throw FuturePeriodException(period);
    }
    final normalized = <String, MeasurementEntry?>{};
    final errors = <String, List<EntryFieldError>>{};
    for (final MapEntry(key: id, value: entry) in entries.entries) {
      final row = await _liveParameter(id);
      if (row == null) throw MeasurementParameterNotFoundException(id);
      if (row.frequency != period.frequency.code) {
        throw ArgumentError.value(
          id,
          'entries',
          'parâmetro ${row.frequency}, período ${period.frequency.code}',
        );
      }
      final clean = entry == null ? null : normalizeEntry(entry);
      if (clean != null) {
        final entryErrors = validateEntry(clean);
        if (entryErrors.isNotEmpty) errors[id] = entryErrors;
      }
      normalized[id] = clean;
    }
    if (errors.isNotEmpty) {
      throw MeasurementValidationException(entryErrors: errors);
    }
    final now = _clock();
    for (final MapEntry(key: id, value: entry) in normalized.entries) {
      final existing =
          await (_db.select(_measurements)..where(
                (m) =>
                    m.parameterId.equals(id) &
                    m.periodStart.equalsValue(period.start) &
                    m.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (entry == null) {
        if (existing == null) continue;
        await (_db.update(
          _measurements,
        )..where((m) => m.id.equals(existing.id))).write(
          MeasurementsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      } else if (existing == null) {
        await _db
            .into(_measurements)
            .insert(
              MeasurementsCompanion.insert(
                id: _newId(),
                createdAt: now,
                updatedAt: now,
                parameterId: id,
                periodStart: period.start,
                value: Value(entry.value),
                note: Value(entry.note),
              ),
            );
      } else if (measurementFromRow(existing).toEntry() != entry) {
        await (_db.update(
          _measurements,
        )..where((m) => m.id.equals(existing.id))).write(
          MeasurementsCompanion(
            value: Value(entry.value),
            note: Value(entry.note),
            updatedAt: Value(now),
          ),
        );
      }
    }
  });

  // Apoio -------------------------------------------------------------------

  Expression<bool> _ofGroup(
    $MeasurementParametersTable p,
    String companyId,
    MeasurementContext context,
  ) =>
      p.companyId.equals(companyId) &
      p.context.equals(context.code) &
      p.deletedAt.isNull();

  Future<MeasurementParameterRow?> _liveParameter(String id) => (_db.select(
    _parameters,
  )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();

  Future<MeasurementParameterRow> _requireLive(String id) async =>
      await _liveParameter(id) ??
      (throw MeasurementParameterNotFoundException(id));

  Future<bool> _hasMeasurements(String id) async =>
      await (_db.select(_measurements)
            ..where((m) => m.parameterId.equals(id) & m.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull() !=
      null;

  Future<MeasurementParameterInput> _validated(
    String companyId,
    MeasurementContext context,
    MeasurementParameterInput input, {
    String? exceptId,
  }) async {
    final data = normalizeParameterInput(input);
    final errors = validateParameter(data);
    if (data.name.isNotEmpty) {
      final key = normalizeForSearch(data.name);
      final siblings = await (_db.select(
        _parameters,
      )..where((p) => _ofGroup(p, companyId, context))).get();
      if (siblings.any(
        (p) => p.id != exceptId && normalizeForSearch(p.name) == key,
      )) {
        errors.add(
          const ParameterFieldError(
            ParameterField.name,
            ParameterFieldErrorType.duplicate,
          ),
        );
      }
    }
    if (errors.isNotEmpty) {
      throw MeasurementValidationException(parameterErrors: errors);
    }
    return data;
  }

  Future<void> _checkModuleEnabled(
    String companyId,
    MeasurementContext context,
  ) async {
    final row =
        await (_db.select(_modules)..where(
              (m) =>
                  m.companyId.equals(companyId) &
                  m.moduleType.equals(context.module.code) &
                  m.enabled.equals(true) &
                  m.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw MeasurementModuleNotEnabledException(companyId, context.module);
    }
  }
}

String _dateOnly(DateTime d) => const DateOnlyConverter().toSql(d);

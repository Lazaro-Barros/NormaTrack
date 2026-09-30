import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/search_text.dart';
import '../../companies/domain/company_repository.dart';
import '../../companies/domain/module_type.dart';
import '../domain/deadline.dart';
import '../domain/deadline_repository.dart';
import '../domain/deadline_status.dart';
import '../domain/deadline_validation.dart';
import 'deadline_mapper.dart';

/// A UI depende só do tipo [DeadlineRepository].
final deadlineRepositoryProvider = Provider<DeadlineRepository>(
  (ref) => LocalDeadlineRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

/// Proteção contra cadeia de ciclos corrompida (laço).
const _maxChainSteps = 1000;

class LocalDeadlineRepository implements DeadlineRepository {
  LocalDeadlineRepository(
    this._db, {
    required this._clock,
    required this._newId,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  $DeadlinesTable get _deadlines => _db.deadlines;
  $DeadlineRemindersTable get _reminders => _db.deadlineReminders;
  $CompaniesTable get _companies => _db.companies;
  $CompanyModulesTable get _modules => _db.companyModules;

  // Leitura -----------------------------------------------------------------

  @override
  Stream<List<Deadline>> watchByCompany(
    String companyId, {
    ModuleType? module,
    Set<DeadlineStatus> statuses = const {DeadlineStatus.active},
  }) => _watchList(() async {
    final query = _db.select(_deadlines)
      ..where((d) {
        var where =
            d.companyId.equals(companyId) &
            d.deletedAt.isNull() &
            d.status.isIn(statuses.map((s) => s.code));
        if (module != null) where &= d.module.equals(module.code);
        return where;
      });
    return _assemble(await query.get());
  });

  @override
  Stream<List<Deadline>> watchUpcoming() => _watchList(() async {
    final query =
        _db.select(_deadlines).join([
          innerJoin(_companies, _companies.id.equalsExp(_deadlines.companyId)),
          innerJoin(
            _modules,
            _modules.companyId.equalsExp(_deadlines.companyId) &
                _modules.moduleType.equalsExp(_deadlines.module),
          ),
        ])..where(
          _deadlines.deletedAt.isNull() &
              _deadlines.status.equals(DeadlineStatus.active.code) &
              _companies.deletedAt.isNull() &
              _companies.archivedAt.isNull() &
              // TODO(RF-EMP-02): prazos de módulo desabilitado somem do painel (C20).
              _modules.enabled.equals(true) &
              _modules.deletedAt.isNull(),
        );
    final rows = await query.get();
    return _assemble([for (final r in rows) r.readTable(_deadlines)]);
  });

  @override
  Stream<Deadline?> watchById(String id) =>
      _watch(() => findById(id)).distinct();

  @override
  Future<Deadline?> findById(String id) async {
    final row = await _liveDeadline(id);
    if (row == null) return null;
    return (await _assemble([row])).single;
  }

  @override
  Stream<List<Deadline>> watchHistory(String id) =>
      _watch(() => _loadHistory(id))
          .distinct(const ListEquality<Deadline>().equals);

  /// Reexecuta [load] sempre que prazos, lembretes, empresas ou módulos mudam.
  /// O SQL precisa ser único no app: o drift reaproveita streams com o mesmo
  /// SQL e variáveis, sem olhar `readsFrom` (D008).
  Stream<T> _watch<T>(Future<T> Function() load) => _db
      .customSelect(
        'SELECT 1 AS deadlines_changed',
        readsFrom: {_deadlines, _reminders, _companies, _modules},
      )
      .watch()
      .asyncMap((_) => load());

  Stream<List<Deadline>> _watchList(Future<List<Deadline>> Function() load) =>
      _watch(() async => _sorted(await load()))
          .distinct(const ListEquality<Deadline>().equals);

  /// Vencimento, título sem acento/caixa, id.
  List<Deadline> _sorted(List<Deadline> deadlines) {
    final titles = {for (final d in deadlines) d: normalizeForSearch(d.title)};
    return deadlines..sort((a, b) {
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      final byTitle = titles[a]!.compareTo(titles[b]!);
      return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
    });
  }

  Future<List<Deadline>> _assemble(List<DeadlineRow> rows) async {
    if (rows.isEmpty) return [];
    final ids = rows.map((r) => r.id).toList();
    final reminders = await (_db.select(
      _reminders,
    )..where((r) => r.deadlineId.isIn(ids) & r.deletedAt.isNull())).get();
    final remindersById = reminders.groupListsBy((r) => r.deadlineId);
    return [
      for (final row in rows)
        deadlineFromRows(row, remindersById[row.id] ?? const []),
    ];
  }

  /// Sobe por `previousDeadlineId` e desce pelos ciclos seguintes, passando
  /// por dentro dos excluídos sem retorná-los. Mais novo primeiro.
  Future<List<Deadline>> _loadHistory(String id) async {
    final start = await _liveDeadline(id);
    if (start == null) return [];

    final older = <DeadlineRow>[];
    var previousId = start.previousDeadlineId;
    for (var i = 0; previousId != null && i < _maxChainSteps; i++) {
      final row = await _anyDeadline(previousId);
      if (row == null) break;
      older.add(row);
      previousId = row.previousDeadlineId;
    }

    final newer = <DeadlineRow>[];
    var currentId = start.id;
    for (var i = 0; i < _maxChainSteps; i++) {
      final next = await _nextCycle(currentId);
      if (next == null) break;
      newer.add(next);
      currentId = next.id;
    }

    final chain = [...newer.reversed, start, ...older];
    return _assemble([
      for (final row in chain)
        if (row.deletedAt == null) row,
    ]);
  }

  /// Ciclo seguinte: o vivo, se houver; senão o excluído mais recente.
  Future<DeadlineRow?> _nextCycle(String id) async {
    final children =
        await (_db.select(_deadlines)
              ..where((d) => d.previousDeadlineId.equals(id))
              ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
            .get();
    return children.firstWhereOrNull((r) => r.deletedAt == null) ??
        children.firstOrNull;
  }

  // Escrita -----------------------------------------------------------------

  @override
  Future<Deadline> create(String companyId, DeadlineInput input) =>
      _db.transaction(() async {
        final data = _validated(input);
        final company =
            await (_db.select(_companies)
                  ..where((c) => c.id.equals(companyId) & c.deletedAt.isNull()))
                .getSingleOrNull();
        if (company == null) throw CompanyNotFoundException(companyId);
        await _checkModuleEnabled(companyId, data.module);
        final id = _newId();
        await _insertDeadline(id: id, companyId: companyId, data: data);
        return (await findById(id))!;
      });

  @override
  Future<Deadline> update(String id, DeadlineInput input) =>
      _db.transaction(() async {
        final current = await _requireLive(id);
        final data = _validated(input);
        await _checkModuleEnabled(current.companyId, data.module);
        final before = current.toInput();
        if (before == data) return current;

        final now = _clock();
        await (_db.update(_deadlines)..where((d) => d.id.equals(id))).write(
          deadlineDataCompanion(data).copyWith(updatedAt: Value(now)),
        );
        if (!const ListEquality<int>().equals(
          before.reminderDays,
          data.reminderDays,
        )) {
          await _syncReminders(id, data.reminderDays!, now);
        }
        return (await findById(id))!;
      });

  @override
  Future<Deadline> renew(String id, {required DateTime newDueDate}) =>
      _db.transaction(() async {
        final current = await _requireLive(id);
        _requireStatus(current, {DeadlineStatus.active}, DeadlineAction.renew);
        final due = DateTime(newDueDate.year, newDueDate.month, newDueDate.day);
        // TODO(RF-PRZ-04): nova data sempre posterior à anterior (C20).
        if (!due.isAfter(current.dueDate)) {
          throw const DeadlineValidationException([
            DeadlineFieldError(
              DeadlineField.dueDate,
              DeadlineFieldErrorType.notAfterPrevious,
            ),
          ]);
        }
        final now = _clock();
        await _writeStatus(id, DeadlineStatus.renewed, now);
        final nextId = _newId();
        final input = current.toInput();
        await _insertDeadline(
          id: nextId,
          companyId: current.companyId,
          data: DeadlineInput(
            module: input.module,
            category: input.category,
            authority: input.authority,
            title: input.title,
            dueDate: due,
            reminderDays: input.reminderDays,
          ),
          previousDeadlineId: id,
        );
        return (await findById(nextId))!;
      });

  @override
  Future<void> complete(String id, {required DateTime completedOn}) =>
      _db.transaction(() async {
        final current = await _requireLive(id);
        _requireStatus(current, {
          DeadlineStatus.active,
        }, DeadlineAction.complete);
        if (!current.category.canBeCompleted) {
          throw InvalidDeadlineTransitionException(
            id,
            current.status,
            DeadlineAction.complete,
          );
        }
        await _writeStatus(
          id,
          DeadlineStatus.completed,
          _clock(),
          completedOn: DateTime(
            completedOn.year,
            completedOn.month,
            completedOn.day,
          ),
        );
      });

  @override
  Future<void> cancel(String id) => _db.transaction(() async {
    final current = await _requireLive(id);
    _requireStatus(current, {DeadlineStatus.active}, DeadlineAction.cancel);
    await _writeStatus(id, DeadlineStatus.cancelled, _clock());
  });

  @override
  Future<void> reopen(String id) => _db.transaction(() async {
    final current = await _requireLive(id);
    _requireStatus(current, {
      DeadlineStatus.completed,
      DeadlineStatus.cancelled,
    }, DeadlineAction.reopen);
    await _writeStatus(id, DeadlineStatus.active, _clock());
  });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    final row = await _liveDeadline(id);
    if (row == null) throw DeadlineNotFoundException(id);
    final now = _clock();
    await (_db.update(_deadlines)..where((d) => d.id.equals(id))).write(
      DeadlinesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (_db.update(
      _reminders,
    )..where((r) => r.deadlineId.equals(id) & r.deletedAt.isNull())).write(
      DeadlineRemindersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );

    // Excluir o ciclo em aberto desfaz a renovação que o criou.
    // TODO(RF-PRZ-04): excluir o ciclo atual reabre o anterior (C20).
    final previousId = row.previousDeadlineId;
    if (row.status != DeadlineStatus.active.code || previousId == null) return;
    final previous = await _liveDeadline(previousId);
    if (previous?.status == DeadlineStatus.renewed.code) {
      await _writeStatus(previousId, DeadlineStatus.active, now);
    }
  });

  Future<void> _insertDeadline({
    required String id,
    required String companyId,
    required DeadlineInput data,
    String? previousDeadlineId,
  }) async {
    final now = _clock();
    await _db
        .into(_deadlines)
        .insert(
          deadlineDataCompanion(data).copyWith(
            id: Value(id),
            createdAt: Value(now),
            updatedAt: Value(now),
            companyId: Value(companyId),
            status: Value(DeadlineStatus.active.code),
            previousDeadlineId: Value(previousDeadlineId),
          ),
        );
    for (final days in data.reminderDays!) {
      await _insertReminder(id, days, now);
    }
  }

  /// Muda o estado. `completedOn` só fica gravado com `completed`.
  Future<void> _writeStatus(
    String id,
    DeadlineStatus status,
    DateTime now, {
    DateTime? completedOn,
  }) => (_db.update(_deadlines)..where((d) => d.id.equals(id))).write(
    DeadlinesCompanion(
      status: Value(status.code),
      completedOn: Value(completedOn),
      updatedAt: Value(now),
    ),
  );

  /// Valor presente: reaproveita a linha (mesmo excluída) ou insere. Valor que
  /// saiu: exclusão lógica.
  Future<void> _syncReminders(
    String deadlineId,
    List<int> days,
    DateTime now,
  ) async {
    final rows = await (_db.select(
      _reminders,
    )..where((r) => r.deadlineId.equals(deadlineId))).get();
    final byDays = {for (final r in rows) r.daysBefore: r};
    for (final value in days) {
      final row = byDays[value];
      if (row == null) {
        await _insertReminder(deadlineId, value, now);
      } else if (row.deletedAt != null) {
        await _writeReminderDeleted(row.id, null, now);
      }
    }
    for (final row in rows) {
      if (row.deletedAt == null && !days.contains(row.daysBefore)) {
        await _writeReminderDeleted(row.id, now, now);
      }
    }
  }

  Future<void> _writeReminderDeleted(
    String id,
    DateTime? deletedAt,
    DateTime now,
  ) => (_db.update(_reminders)..where((r) => r.id.equals(id))).write(
    DeadlineRemindersCompanion(
      deletedAt: Value(deletedAt),
      updatedAt: Value(now),
    ),
  );

  Future<void> _insertReminder(String deadlineId, int days, DateTime now) => _db
      .into(_reminders)
      .insert(
        DeadlineRemindersCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          deadlineId: deadlineId,
          daysBefore: days,
        ),
      );

  // Regras ------------------------------------------------------------------

  DeadlineInput _validated(DeadlineInput input) {
    final data = normalizeDeadlineInput(input);
    final errors = validateDeadline(data);
    if (errors.isNotEmpty) throw DeadlineValidationException(errors);
    return data;
  }

  Future<void> _checkModuleEnabled(String companyId, ModuleType module) async {
    final row =
        await (_db.select(_modules)..where(
              (m) =>
                  m.companyId.equals(companyId) &
                  m.moduleType.equals(module.code) &
                  m.enabled.equals(true) &
                  m.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) throw ModuleNotEnabledException(companyId, module);
  }

  void _requireStatus(
    Deadline deadline,
    Set<DeadlineStatus> allowed,
    DeadlineAction action,
  ) {
    if (!allowed.contains(deadline.status)) {
      throw InvalidDeadlineTransitionException(
        deadline.id,
        deadline.status,
        action,
      );
    }
  }

  Future<DeadlineRow?> _anyDeadline(String id) =>
      (_db.select(_deadlines)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<DeadlineRow?> _liveDeadline(String id) => (_db.select(
    _deadlines,
  )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).getSingleOrNull();

  Future<Deadline> _requireLive(String id) async {
    final deadline = await findById(id);
    if (deadline == null) throw DeadlineNotFoundException(id);
    return deadline;
  }
}

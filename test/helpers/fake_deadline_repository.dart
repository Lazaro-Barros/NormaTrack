import 'dart:async';

import 'package:normatrack/core/utils/search_text.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';
import 'package:normatrack/features/deadlines/domain/deadline_validation.dart';

import 'fake_company_repository.dart';

/// Repositório de prazos em memória para testes de widget (sem drift). Com
/// [companies], confere empresa viva e módulo habilitado como o real.
class FakeDeadlineRepository implements DeadlineRepository {
  FakeDeadlineRepository({DateTime? now, this.companies})
    : _now = now ?? DateTime.utc(2026, 9, 29, 12);

  final DateTime _now;
  final FakeCompanyRepository? companies;
  final _deadlines = <String, Deadline>{};
  final _deleted = <String>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Prazos vivos, em ordem de criação.
  List<Deadline> get all => [
    for (final d in _deadlines.values)
      if (!_deleted.contains(d.id)) d,
  ];

  Future<Deadline> seed(String companyId, DeadlineInput input) =>
      create(companyId, input);

  @override
  Stream<List<Deadline>> watchByCompany(
    String companyId, {
    ModuleType? module,
    Set<DeadlineStatus> statuses = const {DeadlineStatus.active},
  }) => _watch(
    () => _sorted([
      for (final d in all)
        if (d.companyId == companyId &&
            statuses.contains(d.status) &&
            (module == null || d.module == module))
          d,
    ]),
  );

  /// Como o real quando há [companies]: só prazos de empresa viva, não
  /// arquivada e com o módulo habilitado; reage também a mudanças de empresa.
  @override
  Stream<List<Deadline>> watchUpcoming() => _watch(
    () => _sorted([
      for (final d in all)
        if (d.isOpen && _companyAllows(d)) d,
    ]),
    also: companies?.changes,
  );

  @override
  Stream<Deadline?> watchById(String id) => _watch(() => _live(id));

  @override
  Future<Deadline?> findById(String id) async => _live(id);

  @override
  Stream<List<Deadline>> watchHistory(String id) => _watch(() => _chain(id));

  @override
  Future<Deadline> create(String companyId, DeadlineInput input) async {
    final data = _validated(input);
    final companies = this.companies;
    if (companies != null) {
      final company = await companies.findById(companyId);
      if (company == null) throw CompanyNotFoundException(companyId);
      if (!company.hasModule(data.module)) {
        throw ModuleNotEnabledException(companyId, data.module);
      }
    }
    final id = 'd${_nextId++}';
    _deadlines[id] = _build(id, companyId, data);
    _notify();
    return _deadlines[id]!;
  }

  @override
  Future<Deadline> update(String id, DeadlineInput input) async {
    final current = _require(id);
    final data = _validated(input);
    _deadlines[id] = _build(
      id,
      current.companyId,
      data,
      status: current.status,
      completedOn: current.completedOn,
      previousDeadlineId: current.previousDeadlineId,
      createdAt: current.createdAt,
    );
    _notify();
    return _deadlines[id]!;
  }

  @override
  Future<Deadline> renew(String id, {required DateTime newDueDate}) async {
    final current = _require(id);
    if (current.status != DeadlineStatus.active) {
      throw InvalidDeadlineTransitionException(
        id,
        current.status,
        DeadlineAction.renew,
      );
    }
    if (!newDueDate.isAfter(current.dueDate)) {
      throw const DeadlineValidationException([
        DeadlineFieldError(
          DeadlineField.dueDate,
          DeadlineFieldErrorType.notAfterPrevious,
        ),
      ]);
    }
    _setStatus(current, DeadlineStatus.renewed);
    final input = current.toInput();
    final nextId = 'd${_nextId++}';
    _deadlines[nextId] = _build(
      nextId,
      current.companyId,
      DeadlineInput(
        module: input.module,
        category: input.category,
        authority: input.authority,
        title: input.title,
        dueDate: newDueDate,
        reminderDays: input.reminderDays,
      ),
      previousDeadlineId: id,
    );
    _notify();
    return _deadlines[nextId]!;
  }

  @override
  Future<void> complete(String id, {required DateTime completedOn}) async {
    final d = _require(id);
    if (d.status != DeadlineStatus.active || !d.category.canBeCompleted) {
      throw InvalidDeadlineTransitionException(
        id,
        d.status,
        DeadlineAction.complete,
      );
    }
    _setStatus(d, DeadlineStatus.completed, completedOn);
  }

  @override
  Future<void> cancel(String id) async {
    final d = _require(id);
    if (d.status != DeadlineStatus.active) {
      throw InvalidDeadlineTransitionException(
        id,
        d.status,
        DeadlineAction.cancel,
      );
    }
    _setStatus(d, DeadlineStatus.cancelled);
  }

  @override
  Future<void> reopen(String id) async {
    final d = _require(id);
    if (d.status != DeadlineStatus.completed &&
        d.status != DeadlineStatus.cancelled) {
      throw InvalidDeadlineTransitionException(
        id,
        d.status,
        DeadlineAction.reopen,
      );
    }
    _setStatus(d, DeadlineStatus.active);
  }

  @override
  Future<void> delete(String id) async {
    final d = _require(id);
    _deleted.add(id);
    final prevId = d.previousDeadlineId;
    if (d.status == DeadlineStatus.active && prevId != null) {
      final prev = _live(prevId);
      if (prev != null && prev.status == DeadlineStatus.renewed) {
        _setStatus(prev, DeadlineStatus.active);
        return;
      }
    }
    _notify();
  }

  // -------------------------------------------------------------------------

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

  bool _companyAllows(Deadline d) {
    final companies = this.companies;
    if (companies == null) return true;
    for (final c in companies.all) {
      if (c.id == d.companyId) return !c.isArchived && c.hasModule(d.module);
    }
    return false;
  }

  void _notify() => _changes.add(null);

  /// Cadeia que contém [id], do mais novo para o mais antigo.
  List<Deadline> _chain(String id) {
    final start = _live(id);
    if (start == null) return const [];
    final older = <Deadline>[];
    var cur = start;
    while (cur.previousDeadlineId != null) {
      final prev = _live(cur.previousDeadlineId!);
      if (prev == null) break;
      older.add(prev);
      cur = prev;
    }
    final newer = <Deadline>[];
    cur = start;
    while (true) {
      final next = all.where((d) => d.previousDeadlineId == cur.id);
      if (next.isEmpty) break;
      cur = next.first;
      newer.add(cur);
    }
    return [...newer.reversed, start, ...older];
  }

  Deadline? _live(String id) => _deleted.contains(id) ? null : _deadlines[id];

  Deadline _require(String id) =>
      _live(id) ?? (throw DeadlineNotFoundException(id));

  void _setStatus(Deadline d, DeadlineStatus status, [DateTime? completedOn]) {
    _deadlines[d.id] = _build(
      d.id,
      d.companyId,
      d.toInput(),
      status: status,
      completedOn: completedOn,
      previousDeadlineId: d.previousDeadlineId,
      createdAt: d.createdAt,
    );
    _notify();
  }

  List<Deadline> _sorted(List<Deadline> list) => list
    ..sort((a, b) {
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      final byTitle = normalizeForSearch(a.title)
          .compareTo(normalizeForSearch(b.title));
      if (byTitle != 0) return byTitle;
      return a.id.compareTo(b.id);
    });

  DeadlineInput _validated(DeadlineInput input) {
    final data = normalizeDeadlineInput(input);
    final errors = validateDeadline(data);
    if (errors.isNotEmpty) throw DeadlineValidationException(errors);
    return data;
  }

  Deadline _build(
    String id,
    String companyId,
    DeadlineInput d, {
    DeadlineStatus status = DeadlineStatus.active,
    DateTime? completedOn,
    String? previousDeadlineId,
    DateTime? createdAt,
  }) => Deadline(
    id: id,
    companyId: companyId,
    module: d.module,
    category: d.category,
    authority: d.authority,
    title: d.title,
    dueDate: d.dueDate,
    reminderDays: d.reminderDays!,
    status: status,
    completedOn: completedOn,
    previousDeadlineId: previousDeadlineId,
    createdAt: createdAt ?? _now,
    updatedAt: _now,
  );
}

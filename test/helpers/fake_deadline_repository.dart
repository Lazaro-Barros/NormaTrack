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

  @override
  Stream<List<Deadline>> watchUpcoming() => _watch(
    () => _sorted([
      for (final d in all)
        if (d.isOpen) d,
    ]),
  );

  @override
  Stream<Deadline?> watchById(String id) => _watch(() => _live(id));

  @override
  Future<Deadline?> findById(String id) async => _live(id);

  @override
  Stream<List<Deadline>> watchHistory(String id) => _watch(() => [?_live(id)]);

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
  Future<void> complete(String id, {required DateTime completedOn}) async =>
      _setStatus(_require(id), DeadlineStatus.completed, completedOn);

  @override
  Future<void> cancel(String id) async =>
      _setStatus(_require(id), DeadlineStatus.cancelled);

  @override
  Future<void> reopen(String id) async =>
      _setStatus(_require(id), DeadlineStatus.active);

  @override
  Future<void> delete(String id) async {
    _require(id);
    _deleted.add(id);
    _notify();
  }

  // -------------------------------------------------------------------------

  Stream<T> _watch<T>(T Function() load) {
    late StreamController<T> controller;
    StreamSubscription<void>? sub;
    controller = StreamController<T>(
      onListen: () {
        controller.add(load());
        sub = _changes.stream.listen((_) => controller.add(load()));
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  void _notify() => _changes.add(null);

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
      return normalizeForSearch(a.title).compareTo(normalizeForSearch(b.title));
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

import 'dart:async';

import 'package:normatrack/core/utils/br_documents.dart';
import 'package:normatrack/core/utils/search_text.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/domain/company_validation.dart';

/// Repositório em memória para testes de widget (sem drift). `watchAll` só
/// aplica `archived` e `query`.
class FakeCompanyRepository implements CompanyRepository {
  FakeCompanyRepository({DateTime? now})
    : _now = now ?? DateTime.utc(2026, 9, 29, 12);

  final DateTime _now;
  final _companies = <String, Company>{};
  final _deleted = <String>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Empresas vivas (não excluídas), em ordem de criação.
  List<Company> get all => [
    for (final c in _companies.values)
      if (!_deleted.contains(c.id)) c,
  ];

  Future<Company> seed(CompanyInput input, {bool archived = false}) async {
    final company = await create(input);
    if (archived) await archive(company.id);
    return _companies[company.id]!;
  }

  @override
  Stream<List<Company>> watchAll([
    CompanyFilter filter = const CompanyFilter(),
  ]) => _watch(() => _list(filter));

  @override
  Stream<Company?> watchById(String id) => _watch(() => _live(id));

  @override
  Future<Company?> findById(String id) async => _live(id);

  @override
  Future<Company> create(CompanyInput input) async {
    final data = _validated(input);
    _checkDuplicate(data.cnpj);
    final id = 'c${_nextId++}';
    _companies[id] = _build(id, data, createdAt: _now);
    _notify();
    return _companies[id]!;
  }

  @override
  Future<Company> update(String id, CompanyInput input) async {
    final current = _require(id);
    final data = _validated(input);
    _checkDuplicate(data.cnpj, exceptId: id);
    _companies[id] = _build(
      id,
      data,
      createdAt: current.createdAt,
      archivedAt: current.archivedAt,
    );
    _notify();
    return _companies[id]!;
  }

  @override
  Future<void> archive(String id) async => _setArchived(id, true);

  @override
  Future<void> unarchive(String id) async => _setArchived(id, false);

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

  Company? _live(String id) => _deleted.contains(id) ? null : _companies[id];

  Company _require(String id) =>
      _live(id) ?? (throw CompanyNotFoundException(id));

  void _setArchived(String id, bool archived) {
    final c = _require(id);
    if (c.isArchived == archived) return;
    _companies[id] = _build(
      id,
      c.toInput(),
      createdAt: c.createdAt,
      archivedAt: archived ? _now : null,
    );
    _notify();
  }

  List<Company> _list(CompanyFilter filter) {
    final query = filter.query?.trim() ?? '';
    bool matches(Company c) {
      if (query.isEmpty) return true;
      final text = normalizeForSearch(query);
      if (normalizeForSearch(c.legalName).contains(text)) return true;
      final trade = c.tradeName;
      if (trade != null && normalizeForSearch(trade).contains(text)) {
        return true;
      }
      final cnpj = normalizeCnpj(query);
      return cnpj.isNotEmpty && (c.cnpj?.contains(cnpj) ?? false);
    }

    return [
      for (final c in all)
        if (c.isArchived == filter.archived && matches(c)) c,
    ]..sort(
      (a, b) =>
          normalizeForSearch(a.displayName)
              .compareTo(normalizeForSearch(b.displayName)),
    );
  }

  CompanyInput _validated(CompanyInput input) {
    final data = normalizeCompanyInput(input);
    final errors = validateCompany(data);
    if (errors.isNotEmpty) throw CompanyValidationException(errors);
    return data;
  }

  void _checkDuplicate(String? cnpj, {String? exceptId}) {
    if (cnpj == null) return;
    if (all.any((c) => c.cnpj == cnpj && c.id != exceptId)) {
      throw DuplicateCnpjException(cnpj);
    }
  }

  Company _build(
    String id,
    CompanyInput d, {
    required DateTime createdAt,
    DateTime? archivedAt,
  }) => Company(
    id: id,
    legalName: d.legalName,
    tradeName: d.tradeName,
    cnpj: d.cnpj,
    stateRegistration: d.stateRegistration,
    address: d.address,
    phone: d.phone,
    email: d.email,
    legalRepresentative: d.legalRepresentative,
    enabledModules: d.enabledModules,
    registrations: d.registrations,
    archivedAt: archivedAt,
    createdAt: createdAt,
    updatedAt: _now,
  );
}

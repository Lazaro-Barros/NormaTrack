import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/br_documents.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/search_text.dart';
import '../domain/authority.dart';
import '../domain/company.dart';
import '../domain/company_repository.dart';
import '../domain/company_validation.dart';
import '../domain/module_type.dart';
import 'company_mapper.dart';

/// A UI depende só do tipo [CompanyRepository].
final companyRepositoryProvider = Provider<CompanyRepository>(
  (ref) => LocalCompanyRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

class LocalCompanyRepository implements CompanyRepository {
  LocalCompanyRepository(
    this._db, {
    required this._clock,
    required this._newId,
  });

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _newId;

  $CompaniesTable get _companies => _db.companies;
  $CompanyModulesTable get _modules => _db.companyModules;
  $CompanyAuthoritiesTable get _authorities => _db.companyAuthorities;

  // Leitura -----------------------------------------------------------------

  @override
  Stream<List<Company>> watchAll([
    CompanyFilter filter = const CompanyFilter(),
  ]) =>
      _watch(() => _loadAll(filter))
          .distinct(const ListEquality<Company>().equals);

  @override
  Stream<Company?> watchById(String id) =>
      _watch(() => findById(id)).distinct();

  @override
  Future<Company?> findById(String id) async {
    final row = await _liveCompany(id);
    if (row == null) return null;
    return (await _assemble([row])).single;
  }

  /// Reexecuta [load] sempre que qualquer uma das três tabelas muda. O SQL
  /// precisa ser único no app: o drift reaproveita streams com o mesmo SQL e
  /// variáveis, sem olhar `readsFrom` (D008).
  Stream<T> _watch<T>(Future<T> Function() load) => _db
      .customSelect(
        'SELECT 1 AS companies_changed',
        readsFrom: {_companies, _modules, _authorities},
      )
      .watch()
      .asyncMap((_) => load());

  Future<List<Company>> _loadAll(CompanyFilter filter) async {
    final query = _db.select(_companies)
      ..where(
        (c) =>
            c.deletedAt.isNull() &
            (filter.archived
                ? c.archivedAt.isNotNull()
                : c.archivedAt.isNull()),
      );
    final companies = (await _assemble(await query.get()))
        .where((c) => _matches(c, filter))
        .toList();
    final keys = {
      for (final c in companies) c: normalizeForSearch(c.displayName),
    };
    return companies..sort((a, b) {
      final byName = keys[a]!.compareTo(keys[b]!);
      return byName != 0 ? byName : a.id.compareTo(b.id);
    });
  }

  Future<List<Company>> _assemble(List<CompanyRow> rows) async {
    if (rows.isEmpty) return [];
    final ids = rows.map((r) => r.id).toList();
    final modules = await (_db.select(
      _modules,
    )..where((m) => m.companyId.isIn(ids) & m.deletedAt.isNull())).get();
    final authorities = await (_db.select(
      _authorities,
    )..where((a) => a.companyId.isIn(ids) & a.deletedAt.isNull())).get();
    final modulesById = modules.groupListsBy((m) => m.companyId);
    final authoritiesById = authorities.groupListsBy((a) => a.companyId);
    return [
      for (final row in rows)
        companyFromRows(
          row,
          modulesById[row.id] ?? const [],
          authoritiesById[row.id] ?? const [],
        ),
    ];
  }

  bool _matches(Company company, CompanyFilter filter) {
    final module = filter.module;
    if (module != null && !company.hasModule(module)) return false;

    final authority = filter.authority;
    final status = filter.status;
    if (authority != null) {
      final registration = company.registrationFor(authority);
      if (registration == null) return false;
      if (status != null && registration.status != status) return false;
    } else if (status != null &&
        !company.registrations.values.any((r) => r.status == status)) {
      return false;
    }

    final query = filter.query?.trim() ?? '';
    if (query.isEmpty) return true;
    final text = normalizeForSearch(query);
    if (normalizeForSearch(company.legalName).contains(text)) return true;
    final tradeName = company.tradeName;
    if (tradeName != null && normalizeForSearch(tradeName).contains(text)) {
      return true;
    }
    final cnpj = normalizeCnpj(query);
    return cnpj.isNotEmpty && (company.cnpj?.contains(cnpj) ?? false);
  }

  // Escrita -----------------------------------------------------------------

  @override
  Future<Company> create(CompanyInput input) => _db.transaction(() async {
    final data = _validated(input);
    await _checkDuplicateCnpj(data.cnpj);
    final id = _newId();
    final now = _clock();
    await _db
        .into(_companies)
        .insert(
          companyDataCompanion(data).copyWith(
            id: Value(id),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    for (final module in data.enabledModules) {
      await _insertModule(id, module, now);
    }
    for (final registration in data.registrations.values) {
      await _insertRegistration(id, registration, now);
    }
    return (await findById(id))!;
  });

  @override
  Future<Company> update(String id, CompanyInput input) =>
      _db.transaction(() async {
        final row = await _requireLive(id);
        final data = _validated(input);
        await _checkDuplicateCnpj(data.cnpj, exceptId: id);
        final now = _clock();

        final scalars = CompanyInput(
          legalName: data.legalName,
          tradeName: data.tradeName,
          cnpj: data.cnpj,
          stateRegistration: data.stateRegistration,
          address: data.address,
          phone: data.phone,
          email: data.email,
          legalRepresentative: data.legalRepresentative,
        );
        if (companyInputFromRow(row) != scalars) {
          await (_db.update(_companies)..where((c) => c.id.equals(id))).write(
            companyDataCompanion(scalars).copyWith(updatedAt: Value(now)),
          );
        }

        await _syncModules(id, data.enabledModules, now);
        await _syncRegistrations(id, data.registrations, now);
        return (await findById(id))!;
      });

  @override
  Future<void> archive(String id) => _setArchived(id, archived: true);

  @override
  Future<void> unarchive(String id) => _setArchived(id, archived: false);

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    await _requireLive(id);
    final now = _clock();
    await (_db.update(_companies)..where((c) => c.id.equals(id))).write(
      CompaniesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (_db.update(
      _modules,
    )..where((m) => m.companyId.equals(id) & m.deletedAt.isNull())).write(
      CompanyModulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (_db.update(
      _authorities,
    )..where((a) => a.companyId.equals(id) & a.deletedAt.isNull())).write(
      CompanyAuthoritiesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await _deleteDeadlines(id, now);
  });

  /// Prazos da empresa e os lembretes deles (task 006).
  Future<void> _deleteDeadlines(String companyId, DateTime now) async {
    final deadlines = _db.deadlines;
    final reminders = _db.deadlineReminders;
    final ids = _db.selectOnly(deadlines)
      ..addColumns([deadlines.id])
      ..where(deadlines.companyId.equals(companyId));
    await (_db.update(
      reminders,
    )..where((r) => r.deadlineId.isInQuery(ids) & r.deletedAt.isNull())).write(
      DeadlineRemindersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (_db.update(deadlines)
          ..where((d) => d.companyId.equals(companyId) & d.deletedAt.isNull()))
        .write(
          DeadlinesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
  }

  Future<void> _setArchived(String id, {required bool archived}) =>
      _db.transaction(() async {
        final row = await _requireLive(id);
        if ((row.archivedAt != null) == archived) return;
        final now = _clock();
        await (_db.update(_companies)..where((c) => c.id.equals(id))).write(
          CompaniesCompanion(
            archivedAt: Value(archived ? now : null),
            updatedAt: Value(now),
          ),
        );
      });

  /// Upsert por `(company_id, module_type)`, só para módulos que já têm linha
  /// ou que estão habilitados.
  Future<void> _syncModules(
    String companyId,
    Set<ModuleType> enabled,
    DateTime now,
  ) async {
    final rows = await (_db.select(
      _modules,
    )..where((m) => m.companyId.equals(companyId))).get();
    final byCode = {for (final r in rows) r.moduleType: r};
    for (final module in ModuleType.values) {
      final want = enabled.contains(module);
      final row = byCode[module.code];
      if (row == null) {
        if (want) await _insertModule(companyId, module, now);
      } else if (row.enabled != want || row.deletedAt != null) {
        await (_db.update(_modules)..where((m) => m.id.equals(row.id))).write(
          CompanyModulesCompanion(
            enabled: Value(want),
            deletedAt: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  /// Órgão presente: upsert (reaproveita a linha, mesmo excluída). Ausente com
  /// linha viva: exclusão lógica.
  Future<void> _syncRegistrations(
    String companyId,
    Map<Authority, AuthorityRegistration> registrations,
    DateTime now,
  ) async {
    final rows = await (_db.select(
      _authorities,
    )..where((a) => a.companyId.equals(companyId))).get();
    final byCode = {for (final r in rows) r.authority: r};
    for (final authority in Authority.values) {
      final registration = registrations[authority];
      final row = byCode[authority.code];
      if (registration != null) {
        if (row == null) {
          await _insertRegistration(companyId, registration, now);
        } else if (row.deletedAt != null ||
            registrationFromRow(row) != registration) {
          await (_db.update(
            _authorities,
          )..where((a) => a.id.equals(row.id))).write(
            registrationDataCompanion(registration)
                .copyWith(deletedAt: const Value(null), updatedAt: Value(now)),
          );
        }
      } else if (row != null && row.deletedAt == null) {
        await (_db.update(
          _authorities,
        )..where((a) => a.id.equals(row.id))).write(
          CompanyAuthoritiesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  Future<void> _insertModule(
    String companyId,
    ModuleType module,
    DateTime now,
  ) => _db
      .into(_modules)
      .insert(
        CompanyModulesCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          companyId: companyId,
          moduleType: module.code,
          enabled: true,
        ),
      );

  Future<void> _insertRegistration(
    String companyId,
    AuthorityRegistration registration,
    DateTime now,
  ) => _db
      .into(_authorities)
      .insert(
        registrationDataCompanion(registration).copyWith(
          id: Value(_newId()),
          createdAt: Value(now),
          updatedAt: Value(now),
          companyId: Value(companyId),
          authority: Value(registration.authority.code),
        ),
      );

  // Regras ------------------------------------------------------------------

  CompanyInput _validated(CompanyInput input) {
    final data = normalizeCompanyInput(input);
    final errors = validateCompany(data);
    if (errors.isNotEmpty) throw CompanyValidationException(errors);
    return data;
  }

  /// Duplicado = outra empresa não excluída (ativa ou arquivada) com o mesmo
  /// CNPJ normalizado.
  Future<void> _checkDuplicateCnpj(String? cnpj, {String? exceptId}) async {
    if (cnpj == null) return;
    final query = _db.select(_companies)
      ..where((c) {
        final same = c.cnpj.equals(cnpj) & c.deletedAt.isNull();
        return exceptId == null ? same : same & c.id.equals(exceptId).not();
      })
      ..limit(1);
    if (await query.getSingleOrNull() != null) {
      throw DuplicateCnpjException(cnpj);
    }
  }

  Future<CompanyRow?> _liveCompany(String id) => (_db.select(
    _companies,
  )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();

  Future<CompanyRow> _requireLive(String id) async {
    final row = await _liveCompany(id);
    if (row == null) throw CompanyNotFoundException(id);
    return row;
  }
}

import 'package:meta/meta.dart';

import 'authority.dart';
import 'company.dart';
import 'company_validation.dart';
import 'module_type.dart';

abstract interface class CompanyRepository {
  /// Não excluídas, filtradas e ordenadas por `normalizeForSearch(displayName)`.
  Stream<List<Company>> watchAll([
    CompanyFilter filter = const CompanyFilter(),
  ]);

  /// `null` se não existe ou está excluída.
  Stream<Company?> watchById(String id);

  Future<Company?> findById(String id);

  /// Lança [CompanyValidationException] ou [DuplicateCnpjException].
  Future<Company> create(CompanyInput input);

  /// Lança [CompanyValidationException], [DuplicateCnpjException] ou
  /// [CompanyNotFoundException].
  Future<Company> update(String id, CompanyInput input);

  /// Idempotente. Lança [CompanyNotFoundException].
  Future<void> archive(String id);

  /// Idempotente. Lança [CompanyNotFoundException].
  Future<void> unarchive(String id);

  /// Exclusão lógica, em cascata nos módulos e registros. Lança
  /// [CompanyNotFoundException].
  Future<void> delete(String id);
}

@immutable
class CompanyFilter {
  const CompanyFilter({
    this.archived = false,
    this.query,
    this.module,
    this.authority,
    this.status,
  });

  /// `false` = só ativas; `true` = só arquivadas.
  final bool archived;

  /// Razão social, nome fantasia (sem acento/caixa) ou CNPJ (com ou sem máscara).
  final String? query;

  /// Empresas com o módulo habilitado.
  final ModuleType? module;

  /// Empresas com registro (qualquer situação) no órgão.
  final Authority? authority;

  /// Com [authority]: situação naquele órgão. Sem: em qualquer órgão.
  final RegistrationStatus? status;

  @override
  bool operator ==(Object other) =>
      other is CompanyFilter &&
      other.archived == archived &&
      other.query == query &&
      other.module == module &&
      other.authority == authority &&
      other.status == status;

  @override
  int get hashCode => Object.hash(archived, query, module, authority, status);
}

sealed class CompanyException implements Exception {
  const CompanyException();
}

final class CompanyValidationException extends CompanyException {
  const CompanyValidationException(this.errors);

  final List<CompanyFieldError> errors;

  @override
  String toString() => 'CompanyValidationException($errors)';
}

final class DuplicateCnpjException extends CompanyException {
  const DuplicateCnpjException(this.cnpj);

  final String cnpj;

  @override
  String toString() => 'DuplicateCnpjException($cnpj)';
}

final class CompanyNotFoundException extends CompanyException {
  const CompanyNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'CompanyNotFoundException($id)';
}

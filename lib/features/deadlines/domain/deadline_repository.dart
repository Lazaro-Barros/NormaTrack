import '../../companies/domain/company_repository.dart';
import '../../companies/domain/module_type.dart';
import 'deadline.dart';
import 'deadline_status.dart';
import 'deadline_validation.dart';

abstract interface class DeadlineRepository {
  /// Não excluídos da empresa, com [statuses] (padrão: só em aberto), do
  /// módulo se informado. Ordem: vencimento, título (sem acento/caixa), id.
  Stream<List<Deadline>> watchByCompany(
    String companyId, {
    ModuleType? module,
    Set<DeadlineStatus> statuses = const {DeadlineStatus.active},
  });

  /// Próximos vencimentos de todas as empresas (RF-PRZ-05): em aberto, não
  /// excluídos, de empresas não excluídas e não arquivadas, com o módulo
  /// habilitado. Mesma ordem de [watchByCompany].
  Stream<List<Deadline>> watchUpcoming();

  /// `null` se não existe ou está excluído.
  Stream<Deadline?> watchById(String id);

  Future<Deadline?> findById(String id);

  /// Ciclos da cadeia que contém [id], sem os excluídos, do mais novo para o
  /// mais antigo. Vazio se [id] não existe ou está excluído.
  Stream<List<Deadline>> watchHistory(String id);

  /// Lança [DeadlineValidationException], [CompanyNotFoundException] ou
  /// [ModuleNotEnabledException].
  Future<Deadline> create(String companyId, DeadlineInput input);

  /// Qualquer status; não muda o status. Lança [DeadlineValidationException],
  /// [DeadlineNotFoundException] ou [ModuleNotEnabledException].
  Future<Deadline> update(String id, DeadlineInput input);

  /// Fecha o ciclo e abre o próximo (RF-PRZ-04). Só em aberto. Lança
  /// [DeadlineNotFoundException], [InvalidDeadlineTransitionException] ou
  /// [DeadlineValidationException] (`dueDate`, `notAfterPrevious`).
  Future<Deadline> renew(String id, {required DateTime newDueDate});

  /// Só em aberto, e só laudo ou manutenção (RF-AMB-06). Lança
  /// [DeadlineNotFoundException] ou [InvalidDeadlineTransitionException].
  Future<void> complete(String id, {required DateTime completedOn});

  /// Só em aberto. Lança [DeadlineNotFoundException] ou
  /// [InvalidDeadlineTransitionException].
  Future<void> cancel(String id);

  /// Concluído ou cancelado → em aberto (desfazer). Lança
  /// [DeadlineNotFoundException] ou [InvalidDeadlineTransitionException].
  Future<void> reopen(String id);

  /// Exclusão lógica do prazo e dos lembretes. Excluir o ciclo atual reabre
  /// o anterior. Lança [DeadlineNotFoundException].
  Future<void> delete(String id);
}

enum DeadlineAction { renew, complete, cancel, reopen }

sealed class DeadlineException implements Exception {
  const DeadlineException();
}

final class DeadlineValidationException extends DeadlineException {
  const DeadlineValidationException(this.errors);

  final List<DeadlineFieldError> errors;

  @override
  String toString() => 'DeadlineValidationException($errors)';
}

final class DeadlineNotFoundException extends DeadlineException {
  const DeadlineNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'DeadlineNotFoundException($id)';
}

final class ModuleNotEnabledException extends DeadlineException {
  const ModuleNotEnabledException(this.companyId, this.module);

  final String companyId;
  final ModuleType module;

  @override
  String toString() => 'ModuleNotEnabledException($companyId, ${module.code})';
}

final class InvalidDeadlineTransitionException extends DeadlineException {
  const InvalidDeadlineTransitionException(this.id, this.status, this.action);

  final String id;
  final DeadlineStatus status;
  final DeadlineAction action;

  @override
  String toString() =>
      'InvalidDeadlineTransitionException($id, ${status.code}, ${action.name})';
}

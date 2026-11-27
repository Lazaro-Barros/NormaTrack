import '../../companies/domain/company_repository.dart';
import '../../companies/domain/module_type.dart';
import 'measurement.dart';
import 'measurement_context.dart';
import 'measurement_parameter.dart';
import 'measurement_period.dart';
import 'measurement_validation.dart';
import 'pending_launch.dart';

abstract interface class MeasurementRepository {
  /// Da empresa e do contexto, não excluídos; arquivados só com
  /// [includeArchived]. Ordem: position, nome sem acento/caixa, id.
  Stream<List<MeasurementParameter>> watchParameters(
    String companyId,
    MeasurementContext context, {
    bool includeArchived = false,
  });

  /// `null` se não existe ou está excluído.
  Future<MeasurementParameter?> findParameter(String id);

  /// Vai para o fim da lista. Lança [MeasurementValidationException],
  /// [CompanyNotFoundException] ou [MeasurementModuleNotEnabledException].
  Future<MeasurementParameter> createParameter(
    String companyId,
    MeasurementContext context,
    MeasurementParameterInput input,
  );

  /// Também arquivado. Não muda posição, contexto nem arquivamento. Mudar a
  /// frequência com medições vivas dá `frequency/locked`. Lança
  /// [MeasurementValidationException] ou
  /// [MeasurementParameterNotFoundException].
  Future<MeasurementParameter> updateParameter(
    String id,
    MeasurementParameterInput input,
  );

  /// [orderedIds] = exatamente os parâmetros não excluídos (arquivados
  /// incluídos) da empresa e do contexto; senão [ArgumentError].
  Future<void> reorderParameters(
    String companyId,
    MeasurementContext context,
    List<String> orderedIds,
  );

  /// Idempotente. Lança [MeasurementParameterNotFoundException].
  Future<void> archiveParameter(String id);

  /// Idempotente. Lança [MeasurementParameterNotFoundException].
  Future<void> unarchiveParameter(String id);

  /// Exclusão lógica do parâmetro e das medições dele. Lança
  /// [MeasurementParameterNotFoundException].
  Future<void> deleteParameter(String id);

  /// Medições não excluídas de parâmetros não excluídos (arquivados
  /// incluídos) da empresa e do contexto, com início do período entre [from]
  /// e [to] (inclusivos). Ordem: início do período, posição do parâmetro, id.
  Stream<List<Measurement>> watchMeasurements(
    String companyId,
    MeasurementContext context, {
    DateTime? from,
    DateTime? to,
  });

  /// Grava o [period] de uma vez, numa transação: parameterId → entrada;
  /// `null` apaga a medição do período; parâmetros fora do mapa não mudam.
  /// Período passado e parâmetro arquivado são aceitos; futuro (depois do que
  /// contém [today]) lança [FuturePeriodException]. Lança também
  /// [MeasurementParameterNotFoundException], [ArgumentError] (parâmetro de
  /// outra frequência) ou [MeasurementValidationException] (nada é gravado).
  Future<void> savePeriod(
    MeasurementPeriod period,
    Map<String, MeasurementEntry?> entries, {
    required DateTime today,
  });

  /// Pendências (C26) de empresas não excluídas e não arquivadas com o módulo
  /// do contexto habilitado; só de [companyId] se informado.
  Stream<List<PendingLaunch>> watchPendingLaunches({
    required DateTime today,
    String? companyId,
  });
}

sealed class MeasurementException implements Exception {
  const MeasurementException();
}

final class MeasurementValidationException extends MeasurementException {
  const MeasurementValidationException({
    this.parameterErrors = const [],
    this.entryErrors = const {},
  });

  final List<ParameterFieldError> parameterErrors;

  /// parameterId → erros da entrada.
  final Map<String, List<EntryFieldError>> entryErrors;

  @override
  String toString() =>
      'MeasurementValidationException($parameterErrors, $entryErrors)';
}

final class MeasurementParameterNotFoundException extends MeasurementException {
  const MeasurementParameterNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'MeasurementParameterNotFoundException($id)';
}

final class MeasurementModuleNotEnabledException extends MeasurementException {
  const MeasurementModuleNotEnabledException(this.companyId, this.module);

  final String companyId;
  final ModuleType module;

  @override
  String toString() =>
      'MeasurementModuleNotEnabledException($companyId, ${module.code})';
}

final class FuturePeriodException extends MeasurementException {
  const FuturePeriodException(this.period);

  final MeasurementPeriod period;

  @override
  String toString() => 'FuturePeriodException($period)';
}

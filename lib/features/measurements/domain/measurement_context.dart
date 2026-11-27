import '../../companies/domain/module_type.dart';

/// Onde a medição acontece (RF-AMB-02/07).
///
/// A ordem é a de exibição. `code` é persistido e nunca muda (D007).
enum MeasurementContext {
  noise('noise', 'Ruídos', ModuleType.environmental, 'dB(A)'),
  // TODO(RF-AMB-07): várias estações por empresa entram na task 017 (C8).
  effluent('effluent', 'Controle da ETE', ModuleType.environmental, null),
  water('water', 'Controle da ETA', ModuleType.environmental, null);

  const MeasurementContext(
    this.code,
    this.label,
    this.module,
    this.defaultUnit,
  );

  final String code;
  final String label;

  /// Módulo que precisa estar habilitado na empresa.
  final ModuleType module;

  /// Unidade sugerida para parâmetros novos.
  final String? defaultUnit;

  static MeasurementContext fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'MeasurementContext'),
  );
}

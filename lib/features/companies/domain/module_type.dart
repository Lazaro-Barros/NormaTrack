/// Módulos que podem ser habilitados por empresa (RF-EMP-02).
///
/// A ordem é a de exibição. `code` é persistido e nunca muda.
enum ModuleType {
  environmental('environmental', 'Ambiental'),
  controlledProducts('controlled_products', 'Produtos controlados'),
  qualityControl('quality_control', 'Controle de qualidade');

  const ModuleType(this.code, this.label);

  final String code;
  final String label;

  static ModuleType fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'ModuleType'),
  );
}

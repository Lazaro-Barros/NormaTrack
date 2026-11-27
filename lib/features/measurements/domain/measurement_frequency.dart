/// Frequência de lançamento de um parâmetro (C8: ETA diária; ETE semanal,
/// quinzenal ou mensal; ruídos semanal).
///
/// A ordem é a de exibição. `code` é persistido e nunca muda (D007).
enum MeasurementFrequency {
  daily('daily', 'Diária'),
  weekly('weekly', 'Semanal'),
  // TODO(RF-AMB-07): quinzena = dias 1 a 15 e 16 ao fim do mês (suposição, C8).
  biweekly('biweekly', 'Quinzenal'),
  monthly('monthly', 'Mensal');

  const MeasurementFrequency(this.code, this.label);

  final String code;
  final String label;

  static MeasurementFrequency fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () =>
        throw ArgumentError.value(code, 'code', 'MeasurementFrequency'),
  );
}

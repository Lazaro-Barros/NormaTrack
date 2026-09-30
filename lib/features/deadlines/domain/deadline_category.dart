/// Categoria do prazo (RF-PRZ-01, RF-AMB-01/05/06, RF-PCT-01).
///
/// A ordem é a de exibição. `code` é persistido e nunca muda.
enum DeadlineCategory {
  // TODO(RF-PRZ-02): padrões por categoria a confirmar com a cliente (C3).
  license('license', 'Licença', [150, 30, 10, 3, 0]),
  labReport('lab_report', 'Laudo', [30, 10, 3, 0]),
  maintenance('maintenance', 'Manutenção', [30, 10, 3, 0]);

  const DeadlineCategory(this.code, this.label, this.defaultReminderDays);

  final String code;
  final String label;

  /// Dias antes do vencimento, em ordem decrescente. O primeiro é a
  /// antecedência do alerta.
  final List<int> defaultReminderDays;

  /// Pode ser concluído (RF-AMB-06). Licença só se renova.
  bool get canBeCompleted => this != license;

  static DeadlineCategory fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'DeadlineCategory'),
  );
}

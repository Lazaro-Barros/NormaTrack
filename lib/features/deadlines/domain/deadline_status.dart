/// Estado gravado do prazo. `code` é persistido e nunca muda.
enum DeadlineStatus {
  active('active', 'Em aberto'),
  renewed('renewed', 'Renovado'),
  completed('completed', 'Concluído'),
  cancelled('cancelled', 'Cancelado');

  const DeadlineStatus(this.code, this.label);

  final String code;
  final String label;

  static DeadlineStatus fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'DeadlineStatus'),
  );
}

/// Situação de um prazo numa data. Derivada, nunca gravada. A UI converte
/// para `StatusTone`.
enum DeadlineSituation {
  current,
  dueSoon,
  overdue,
  renewed,
  completed,
  cancelled,
}

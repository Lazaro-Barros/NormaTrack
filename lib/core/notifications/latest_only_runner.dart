import 'dart:async';

/// Executa [apply] uma vez por vez e, se chegarem vários valores enquanto um
/// roda, aplica só o mais recente. Evita que duas substituições de
/// agendamentos se intercalem e deixem itens de um plano antigo.
class LatestOnlyRunner<T> {
  LatestOnlyRunner(this._apply);

  final Future<void> Function(T value) _apply;
  T? _pending;
  var _hasPending = false;
  Future<void>? _running;

  /// Completa quando não houver mais nada pendente.
  Future<void> run(T value) {
    _pending = value;
    _hasPending = true;
    return _running ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_hasPending) {
        final value = _pending as T;
        _pending = null;
        _hasPending = false;
        await _apply(value);
      }
    } finally {
      _running = null;
    }
  }
}

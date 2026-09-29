/// Fonte do "agora". Injetada para que os testes controlem o tempo.
typedef Clock = DateTime Function();

/// Relógio do sistema, em UTC.
DateTime systemClock() => DateTime.now().toUtc();

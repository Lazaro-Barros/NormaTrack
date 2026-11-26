# Protótipos

Wireframes, spikes de código, consultas e arquivos de exemplo desta task. Material descartável: nada aqui é importado por `lib/`, e `tasks/**` fica fora do `flutter analyze`.

| Arquivo | O que testa | Resultado |
|---|---|---|
| [`spike/spike_main.dart`](spike/spike_main.dart) | Plugin de notificação, fuso local, permissão do Android 13+, agendamento inexato e semanal, `SharedPreferencesAsync`. Rodado numa cópia do projeto com os pacotes do plano | 2026-11-26: tudo funcionou no emulador API 37 (ver journal) |
| [`spike/android.diff`](spike/android.diff) | Mudanças de Gradle e manifest que o plugin exige (AGP 9.1.1, compileSdk 37, desugaring, receivers) | Compilou |

# Protótipos

Wireframes, spikes de código, consultas e arquivos de exemplo desta task. Material descartável: nada aqui é importado por `lib/`, e `tasks/**` fica fora do `flutter analyze`.

| Arquivo | O que testa | Resultado |
|---|---|---|
| [`seed_main.dart`](seed_main.dart) | Ponto de entrada para conferir o Painel no emulador com dados: duas empresas com prazos vencido, a vencer (2) e vigente, uma arquivada e uma com o módulo desligado. Só cadastra se não existe a "Indústria Alfa Ltda". `flutter run -d emulator-5554 -t tasks/009-painel-vencimentos/prototypes/seed_main.dart` | Usado em 2026-11-26: contagens 1 · 2 · 1, ordem e exclusões conferidas |

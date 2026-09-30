# Journal — 005

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Task criada a partir da verificação da task 003 no emulador (achado 4, [journal da 003](../003-empresas-telas/journal.md)): o `filledButtonTheme` pinta o `FilledButton.tonal` de petróleo cheio, e a ação do `EmptyState` parece um botão primário. A usuária pediu para fazer antes da próxima tela.
- Plano escrito e conferido no código do Flutter 3.47.5 (`filled_button.dart`): um só `style` de tema para as duas variantes; o tonal usa `secondaryContainer`/`onSecondaryContainer`.

**Decidido**
- Tirar as cores do `filledButtonTheme` e ajustar `onSecondaryContainer` para `primary`, para bater com os wireframes (fundo `#DCEBEA`, texto `#0E5A63`). Alternativas descartadas no plano.

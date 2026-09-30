# Journal — 005

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Task criada a partir da verificação da task 003 no emulador (achado 4, [journal da 003](../003-empresas-telas/journal.md)): o `filledButtonTheme` pinta o `FilledButton.tonal` de petróleo cheio, e a ação do `EmptyState` parece um botão primário. A usuária pediu para fazer antes da próxima tela.
- Plano escrito e conferido no código do Flutter 3.47.5 (`filled_button.dart`): um só `style` de tema para as duas variantes; o tonal usa `secondaryContainer`/`onSecondaryContainer`.

**Decidido**
- Tirar as cores do `filledButtonTheme` e ajustar `onSecondaryContainer` para `primary`, para bater com os wireframes (fundo `#DCEBEA`, texto `#0E5A63`). Alternativas descartadas no plano.

## 2026-09-30 — Implementada e concluída

**Feito**
- `AppTheme`: `filledButtonTheme` sem `backgroundColor`/`foregroundColor` (mantém tamanho, padding, forma e texto); `onSecondaryContainer` de `primaryStrong` para `primary`.
- Testes em `app_theme_test.dart`: contraste do texto do tonal (6,4:1), cores do primário e do tonal, e desabilitados com a cor padrão (`onSurface` a 12%; comparado com tolerância porque o Flutter arredonda o alfa com `withOpacity`). O teste do tonal falhava antes da correção. 155 testes verdes, `flutter analyze` limpo.
- `docs/07-design-system.md`: papéis de `primary`/`primarySoft` na tabela de cores e cores do tonal na linha "Botões".
- Emulador: "Ver empresas" no Painel agora em petróleo claro com texto petróleo; "Salvar empresa" do formulário continua petróleo com texto branco. Sem exceções no log. O "Cadastrar empresa" da lista vazia não foi visto porque o emulador tinha uma empresa cadastrada, mas é o mesmo `EmptyState`, e a cor está coberta por teste.

**Pendente / dúvidas**
- **Tonal sobre o fundo tingido fica discreto:** o fundo do botão (`primarySoft`, `#DCEBEA`) contra o fundo da tela (`ground`, `#E6EFEE`) tem contraste de 1,05:1, e o contorno do botão quase some no `EmptyState`, que fica direto sobre o fundo. O texto continua legível (6,4:1), e nos wireframes o tonal aparece sobre cards brancos (1,23:1), onde se destaca um pouco mais. Não mudei: é decisão de design. Opções: aceitar; usar `OutlinedButton` no `EmptyState`; ou pôr o `EmptyState` dentro de um card.

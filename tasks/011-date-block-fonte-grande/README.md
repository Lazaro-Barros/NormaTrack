# 011 — Bloco de data com a fonte do sistema grande

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RNF-06 (design system) · RF-PRZ-05 (Painel) · RF-PRZ-01/04 (detalhe do prazo) |
| **Depende de** | 009 (solução do `StatTile` para fonte grande) |
| **Wireframe** | — |

## Objetivo

Com a fonte do sistema aumentada (Configurações › Tamanho da fonte), o bloco de data das listas de prazos e o banner do detalhe do prazo deixam de estourar: crescem junto com o texto, até um limite, e o dia e o mês continuam legíveis.

> **Ponto de partida para quem for implementar:** [plan.md](plan.md).

## Escopo

- `DateBlock` (`lib/app/widgets/date_block.dart`): escala do texto limitada a 1,5× dentro do bloco, com largura e altura calculadas pela escala. 48 × 52 na escala 1.
- `StatusBanner`: mesma escala limitada para o título e a mensagem, altura calculada (`StatusBanner.heightOf(context)`), usada no `AppBar.bottom` do detalhe do prazo. 76 na escala 1.
- `DeadlineCard`: conferir que acompanha o bloco maior sem estouro (a altura já é mínima, não fixa).
- Helper comum para a altura de uma linha escalada (`AppTypography.lineHeight`), reaproveitado pelo `StatTile`.
- `docs/07-design-system.md`: DateBlock, DeadlineCard, StatusBanner e a regra de fonte grande.

## Fora de escopo

- Outros componentes de altura fixa que não usam o `DateBlock` (faixas de título, segmentado, barra inferior). Se aparecerem estouros neles, viram task própria.
- Embarcar as fontes Manrope e IBM Plex Sans (`TODO(RNF-01)` em `app_typography.dart`).

## Critérios de aceite

- [x] Na escala 1, `DateBlock` mede 48 × 52 e `StatusBanner` mede 76 de altura (sem mudança visual).
- [x] Testes de widget de `DateBlock`, `StatusBanner` e `DeadlineCard` com `TextScaler.linear(1.3)`, `TextScaler.linear(2)` e um `TextScaler` não linear, sem exceção de overflow.
- [x] Acima de 1,5× o bloco e o banner param de crescer (escala limitada).
- [x] Detalhe do prazo usa `StatusBanner.heightOf(context)` no `AppBar.bottom`.
- [x] Conferido no emulador `Medium_Phone_API_37.0` em `font_scale` 1,3 e 2,0 (listas do módulo, Painel e detalhe), sem a faixa listrada de overflow; `font_scale` volta ao valor original (1.0).
- [x] `docs/07-design-system.md` atualizado.
- [x] `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

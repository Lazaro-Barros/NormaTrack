# 009 — Painel de próximos vencimentos

| | |
|---|---|
| **Status** | rascunho |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-05 |
| **Depende de** | 007, 008 |
| **Wireframe** | [Main](../../docs/design/wireframes/Main.dc.html) |

## Objetivo

O Painel deixa de ser placeholder: mostra a contagem por situação e os próximos vencimentos de todas as empresas, e leva ao detalhe do prazo.

## Escopo

- Faixa com `StatTile` por situação (tocar filtra a lista).
- Lista de próximos vencimentos com `DeadlineCard` e o nome da empresa, a partir de `DeadlineRepository.watchUpcoming`.

## Fora de escopo

- Lançamentos pendentes (Fase 2).

## Critérios de aceite

- [ ] A definir no refinamento.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

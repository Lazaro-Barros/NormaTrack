# 008 — Prazos: detalhe, histórico e renovação

| | |
|---|---|
| **Status** | rascunho |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-01, RF-PRZ-04 · RF-AMB-06 |
| **Depende de** | 007 |
| **Wireframe** | [PrazoDetalhe](../../docs/design/wireframes/PrazoDetalhe.dc.html) |

## Objetivo

A usuária abre um prazo, vê a situação em destaque, os dados e o histórico de ciclos, e registra a renovação, a conclusão (laudo e manutenção), o cancelamento ou a exclusão.

## Escopo

- Tela de detalhe do prazo com situação, dados e histórico de ciclos (`StatusChip`).
- Ações: renovar (nova data), concluir, cancelar, reabrir e excluir, com confirmação nas destrutivas.
- Componente `StatusBanner` se o prazo estiver vencido.

## Fora de escopo

- Cadastro e lista (task 007).

## Critérios de aceite

- [ ] A definir no refinamento.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

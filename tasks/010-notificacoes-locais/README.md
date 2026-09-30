# 010 — Notificações locais de prazo

| | |
|---|---|
| **Status** | rascunho |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-03 · D004 |
| **Depende de** | 006, 008 |
| **Wireframe** | [Ajustes](../../docs/design/wireframes/Ajustes.dc.html) |

## Objetivo

O celular avisa a usuária nos dias de lembrete de cada prazo em aberto, mesmo com o app fechado.

## Escopo

- Agendamento de notificações locais a partir de `Deadline.reminderDates`, reagendadas quando o prazo muda.
- Permissão de notificação no Android e ajuste em Ajustes.

## Fora de escopo

- Alertas por e-mail (Fase 5).

## Critérios de aceite

- [ ] A definir no refinamento.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

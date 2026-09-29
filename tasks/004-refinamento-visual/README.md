# 004 — Refinamento visual: menos informação e mais cor

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RNF-06; base visual de todas as telas |
| **Depende de** | 001 |
| **Wireframe** | [prototypes/](prototypes/) (propostas A e B) |

## Objetivo

As telas da versão 0.1 do design system ficaram muito brancas e com informação repetida. Esta task escolhe uma direção visual mais limpa e com mais cor e a aplica ao design system, ao tema Flutter e aos wireframes, antes da implementação das telas da task 003.

## Escopo

- Escolher entre as propostas A e B (ver [prototypes/](prototypes/)).
- Atualizar `docs/07-design-system.md` (v0.2), `lib/app/theme/` e os testes de contraste.
- Atualizar `docs/design/wireframes/` para a direção escolhida.
- Revisar o escopo/wireframes da task 003 com a nova direção.

## Fora de escopo

- Implementar telas de feature (fica nas tasks de cada tela).
- Tema escuro.

## Critérios de aceite

- [x] Direção escolhida pelo usuário e registrada no journal (A)
- [x] `docs/07-design-system.md` atualizado para v0.2 (fundo, faixa de cabeçalho, card de prazo, superfícies)
- [x] `lib/app/theme/` atualizado; testes de contraste cobrem as novas cores
- [x] Wireframes em `docs/design/wireframes/` refletem a direção escolhida
- [x] Task 003 revisada
- [x] Usuário aprova os wireframes v0.2 (2026-09-29)
- [x] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

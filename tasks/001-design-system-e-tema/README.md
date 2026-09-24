# 001 — Design system e tema Flutter

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 0 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RNF-06 (interface pt-BR); base visual para todas as telas |
| **Depende de** | — |
| **Wireframe** | [docs/design/wireframes/](../../docs/design/wireframes/) (todas as telas + `DS-*`) |

## Objetivo

Definir uma identidade visual mínima e os wireframes das telas principais antes de desenvolver as funcionalidades, para que todas as telas fiquem consistentes. Transformar isso no tema Flutter usado pelo app.

## Escopo

- Wireframes em alto nível das telas principais (Painel, Empresas, Empresa, cadastro de empresa, módulo Ambiental, prazo, lançamento, relatório, ajustes).
- Design system: princípios, cores, situação de prazo, tipografia, espaçamento, raios, ícones e componentes.
- Tema Flutter (`AppTheme.light`) e primeiro componente compartilhado (`StatusChip`).
- Regras no `CLAUDE.md` para que novas funcionalidades usem o design system.

## Fora de escopo

- Arquivos das fontes (Manrope, IBM Plex Sans) em `assets/fonts/` — pendente.
- Tema escuro.
- Telas de Produtos Controlados (lançamento mensal) e Controle de Qualidade (lotes).
- Demais componentes listados em `docs/07-design-system.md` (criados sob demanda nas tasks que os usarem).

## Critérios de aceite

- [x] Wireframes das telas principais publicados e salvos em `docs/design/wireframes/`
- [x] `docs/07-design-system.md` com tokens, componentes e inventário de telas
- [x] `lib/app/theme/` implementa os tokens; `main.dart` usa `AppTheme.light`
- [x] Teste de contraste (≥ 4,5:1) para texto e pares de situação
- [x] `CLAUDE.md` exige o design system em toda UI nova
- [x] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

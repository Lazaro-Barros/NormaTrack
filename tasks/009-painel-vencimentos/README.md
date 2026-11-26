# 009 — Painel de próximos vencimentos

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-05 |
| **Depende de** | 007, 008 |
| **Wireframe** | [Main](../../docs/design/wireframes/Main.dc.html) |

## Objetivo

O Painel deixa de ser placeholder: mostra a contagem por situação e os próximos vencimentos de todas as empresas, e leva ao detalhe do prazo.

> **Ponto de partida para quem for implementar:** [plan.md](plan.md).

## Escopo

- Faixa de cabeçalho com três `StatTile` (Vencidos · A vencer · Vigentes). Tocar num tile filtra a lista por aquela situação; tocar de novo no mesmo volta a mostrar todos. Sem filtro por padrão.
- Lista "Próximos vencimentos": **todos** os prazos em aberto, sem limite, na ordem de `DeadlineRepository.watchUpcoming` (vencimento, vencidos primeiro). Cada item é um `DeadlineCard` com o nome da empresa na linha de contexto; tocar abre o detalhe do prazo.
- Novo componente `StatTile` em `lib/app/widgets/`, com teste.
- Estados: carregando, erro, nenhum prazo em aberto (com ação "Ver empresas") e nenhum prazo na situação filtrada.
- Substitui `DashboardPlaceholderScreen`.

## Fora de escopo

- Lançamentos pendentes ("Para lançar"): Fase 2.
- Notificações locais e o sino da faixa: task 010.
- "Ver todos" e limite da lista; linha com a data de hoje na faixa (o wireframe foi ajustado).
- Filtro por empresa ou módulo; persistir o filtro entre sessões.

## Decisões (2026-11-16)

- Lista sem limite; tiles Vencidos · A vencer · Vigentes com filtro que alterna (respostas da usuária).
- **[suposição]** Linha de contexto do card = nome da empresa (`displayName`), como no wireframe. Registrado em C23.
- **[suposição]** Voltar do detalhe leva ao Painel (abre-se com `push`). Registrado em C23.

## Critérios de aceite

- [ ] O Painel mostra três tiles com a contagem de prazos em aberto vencidos, a vencer e vigentes, de empresas não arquivadas com o módulo habilitado.
- [ ] A lista traz todos os prazos em aberto na ordem do repositório, cada um com título, nome da empresa e situação em texto (`DeadlineCard`).
- [ ] Tocar num tile mostra só aquela situação e dá anel ao tile; tocar de novo no mesmo volta a mostrar todos.
- [ ] Tocar num prazo abre o detalhe; voltar retorna ao Painel (com o filtro mantido).
- [ ] Com nenhum prazo em aberto, aparece o vazio com "Ver empresas"; filtro sem resultado mostra o vazio do filtro, sem ação.
- [ ] A tela atualiza sozinha ao criar, renovar, concluir ou excluir um prazo (stream).
- [ ] `StatTile` documentado em `docs/07-design-system.md`, com teste de widget.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros; conferido no emulador.

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

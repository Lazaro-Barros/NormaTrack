# 015 — Painel: lançamentos pendentes

| | |
|---|---|
| **Status** | em andamento |
| **Fase** | 2 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-AMB-02, RF-PRZ-05 |
| **Depende de** | 013 (pendências calculadas), 014 (Ruídos e a tela de lançamento) |
| **Wireframe** | [Main.dc.html](../../docs/design/wireframes/Main.dc.html) (a atualizar com o [protótipo](prototypes/Main.dc.html)) e `PendingRow` em [DS-Componentes](../../docs/design/wireframes/DS-Componentes.dc.html) |

## Objetivo

Ao abrir o app, o usuário vê no Painel, acima dos próximos vencimentos, os lançamentos periódicos que faltam fazer em **todas** as empresas, uma linha por empresa e contexto (ex.: "Ruídos · Indústria Alfa", "Semana 46 · 09 a 15/11/2026", "2 semanas atrasadas"), e chega à semana certa com "Lançar". As telas que dependem da data de hoje passam a virar o dia sozinhas.

## Escopo

- Componente `PendingRow` em `lib/app/widgets/` (genérico, com teste e fonte grande sem estouro).
- Domínio: agrupar as pendências por empresa, contexto e frequência (`PendingGroup`), com a mais antiga e a contagem de atrasadas.
- Painel: seção "Lançamentos pendentes" (com a contagem) acima de "Próximos vencimentos"; some quando um tile filtra a lista; sem limite nem "Ver todas". Os tiles continuam contando só prazos.
- "Lançar" abre a semana pendente mais antiga daquela empresa (`AppRoutes.noise(companyId, week:)`); depois de salvar, a linha passa para a seguinte.
- Virada do dia: `todayProvider` muda à meia-noite e ao voltar o app para a frente; usado no Painel, no módulo, no detalhe da empresa, no detalhe do prazo e no lançamento de ruídos.
- Docs: `docs/07-design-system.md`, wireframe `Main`, `docs/05-roadmap.md`, `docs/06-perguntas-em-aberto.md` (C28).

## Fora de escopo

- Tiles contando pendências (decidido: só prazos).
- Notificação de lançamento pendente (as notificações seguem só para prazos, RF-PRZ-03).
- Reagendar as notificações na virada do dia (o plano das notificações continua refeito na abertura e a cada mudança).
- Rotas de lançamento de outros contextos (ETE/ETA na 017; até lá, contexto sem tela própria abre o módulo Ambiental).
- Formulários (cadastro de prazo, empresa, ponto) continuam lendo a data na hora de salvar.

## Critérios de aceite

- [ ] `PendingRow` em `lib/app/widgets/` com teste (textos, tom com ícone, "Lançar" chama a ação, semântica) e sem estouro com fonte 1,3×, 2× e não linear; no design system.
- [ ] Domínio: `groupPendingLaunches` agrupa por empresa, contexto e frequência, com a mais antiga e a contagem de atrasadas, em ordem da mais antiga; testes de domínio.
- [ ] Painel mostra "Lançamentos pendentes" com a contagem, acima de "Próximos vencimentos", com "Ruídos · empresa", "Semana n · intervalo" e "A lançar" / "n semanas atrasadas"; empresa arquivada, excluída ou com Ambiental desligado não aparece; reage a lançamentos.
- [ ] "Lançar" abre a semana pendente mais antiga da empresa; voltar retorna ao Painel.
- [ ] Com um tile selecionado a seção some; sem prazos mas com pendências, a seção aparece e o vazio de prazos fica abaixo dela; sem nada, o vazio atual.
- [ ] `todayProvider` vira o dia à meia-noite e ao voltar o app para a frente (teste); Painel, módulo, detalhe da empresa, detalhe do prazo e lançamento de ruídos usam ele.
- [ ] Conferido no emulador sem perder os dados de teste (Indústria Alfa com as semanas de ruído pendentes).
- [ ] Docs atualizados; `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Links

- [Plano técnico](plan.md) (ponto de partida para implementar) · [Journal](journal.md) · [Protótipos](prototypes/)

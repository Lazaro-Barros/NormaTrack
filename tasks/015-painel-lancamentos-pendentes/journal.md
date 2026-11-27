# Journal — 015

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-27 — Task criada, refinada e planejada

**Feito**
- Task criada a partir da quebra da Fase 2 (`tasks/README.md`), depois da 014. Lidos o Painel (`dashboard_screen.dart`), o domínio de pendências (`pending_launch.dart`), os rótulos e providers de medições, o `PendingRow` desenhado em `DS-Componentes` e o wireframe `Main`.
- Protótipo `prototypes/Main.dc.html` (Painel com a seção "Lançamentos pendentes"), conferido em 390 px. Primeira versão tinha "Ruídos · Semana 46" no título e "empresa · intervalo" no subtítulo, que quebrava em duas linhas; ficou "Ruídos · empresa" no título e "Semana 46 · 09 a 15/11/2026" no subtítulo.
- `plan.md` escrito; status → `planejada`.

**Decidido** (respostas do usuário)
- Uma linha por empresa e contexto (a semana mais antiga e "n semanas atrasadas"); "Lançar" abre a mais antiga. Sem limite nem "Ver todas". Descartado: uma linha por semana.
- Seção acima de "Próximos vencimentos"; some quando um tile filtra a lista.
- Tiles continuam contando só prazos; a seção mostra a contagem no título.
- Virada do dia em todas as telas com situação relativa a hoje (Painel, módulo, detalhe da empresa e do prazo, lançamento de ruídos), por um `todayProvider` que vira à meia-noite e ao voltar o app para a frente.

**Pendente / dúvidas**
- Aprovação do plano e do protótipo pelo usuário.

## 2026-11-27 — Passo 1: data de hoje que vira sozinha

**Feito**
- Plano e protótipo aprovados pelo usuário. Status → `em andamento`.
- `lib/core/today.dart`: `todayProvider` (`Notifier<DateTime>`, data local sem hora) com timer para um segundo depois da meia-noite e `refresh()`, que só notifica se a data mudou. `NormaTrackApp` chama `refresh()` no `onResume` de um `AppLifecycleListener`.
- Painel, módulo (`_DeadlinesState` e `MonitoringSection`), detalhe da empresa, detalhe do prazo e lançamento de ruídos usam `ref.watch(todayProvider)`. No lançamento, `_current` deixou de ser `late final`: a seta "próxima" passa a habilitar quando a semana vira com a tela aberta.
- `pumpApp` aceita `clock` (relógio mutável). Testes: `test/core/today_test.dart` (meia-noite, reagendamento, `refresh` sem mudança não notifica) e, no Painel, "Venceu há 3 dias" → "há 4 dias" ao voltar o app para a frente → "há 5 dias" com o timer.

**Decidido**
- Nos testes de `ProviderContainer` em `testWidgets`, o contêiner é descartado dentro do teste: a checagem de timers pendentes roda antes do `tearDown`. Com `pumpApp` não precisa (desmontar o `ProviderScope` cancela o timer).

## 2026-11-27 — Passo 2: agrupamento e PendingRow

**Feito**
- Domínio: `PendingGroup` e `groupPendingLaunches` em `pending_launch.dart` (por empresa, contexto e frequência; ordem pela mais antiga), com 4 testes.
- Rótulos: `overdueLabel` (semana, quinzena, mês, dia; singular e plural), `pendingGroupStatus` e `pendingPeriodLabel` ("Semana 46 · 09 a 15/11/2026"; diária só a data). `monitoringStatus` passa a usar `overdueLabel` (mesmos textos).
- `PendingRow` em `lib/app/widgets/` com 7 testes (textos, tom, ação, sem subtítulo, posição do botão, fonte 1,3×/2×/não linear sem estouro, botão abaixo em 2×). `docs/07-design-system.md` atualizado.

**Decidido**
- Sem espaço extra entre as três linhas de texto do `PendingRow` (a altura de linha do tema basta; evita um `AppSpacing.xs / 2` solto).

## 2026-11-27 — Passo 3: pendências no Painel

**Feito**
- `pendingLaunchesProvider` (todas as empresas, por `today`) e `pending_section.dart` (`launchRouteFor`, `pendingSection`: título "Lançamentos pendentes" com a contagem e uma `PendingRow` por grupo; "Lançar" faz `push` para a semana mais antiga).
- Painel: seção acima de "Próximos vencimentos", escondida com tile selecionado; sem prazos e com pendências, o vazio dos prazos vai `inline` abaixo da seção; sem nada (ou com filtro e sem prazos), o vazio de antes. Erro em prazos, nomes ou pendências → "Não foi possível carregar o Painel".
- 6 testes novos no `dashboard_screen_test.dart` (linhas, ordem, tons, contagem, posição; "Lançar" abre a semana 38 e voltar retorna; lançar a 38 passa a linha para a 39; filtro esconde; sem prazos; arquivada e Ambiental desligado).
- Wireframe `Main` substituído pelo protótipo aprovado; `docs/07-design-system.md` (tela Painel).

**Decidido**
- No Painel, grupos do mesmo período ficam em ordem alfabética do nome da empresa (o domínio desempata pelo id).
- Na virada do dia a família do provider muda de chave e o Painel mostra o indicador de carregamento por um instante; aceitável (acontece uma vez por dia).

## 2026-11-27 — Verificação no emulador

**Feito** (emulador `Medium_Phone_API_37.0`; cópia do banco antes em `antes.sqlite` no scratchpad da sessão; `flutter build apk --debug` + `adb install -r`, sem `pm clear` nem desinstalar)
- Na abertura, o Painel sem a seção: a semana 48 da Indústria Alfa estava completa (72,5 em "Divisa norte" e "sem medição" em "Galpao B").
- Apagado o 72,5 na tela de Ruídos e salvo ("1 de 2"): o Painel mostra "Lançamentos pendentes 1" com "Ruídos · Indústria Alfa Ltda", "Semana 48 · 23 a 29/11/2026", "A lançar" e "Lançar", igual ao protótipo. Tile "Vencidos" selecionado esconde a seção; tocar de novo volta.
- "Lançar" abre a semana 48 da Alfa; digitado 72.5 (vira "72,5"), "Semana 48 salva", voltar leva ao Painel já sem a seção.
- Fonte do sistema 2,0: título e período quebram a linha, o botão desce para baixo dos textos, sem corte; fonte voltou a 1,0.
- Depois: `quick_check` ok; `companies`, `company_modules`, `company_authorities`, `deadlines`, `deadline_reminders` e `measurement_parameters` iguais à cópia de antes. Em `measurements`, o 72,5 da semana 48 voltou como linha nova (as duas anteriores ficaram excluídas logicamente, pelos dois ciclos de apagar e lançar).
- A virada do dia não foi observada no emulador (exigiria mudar o relógio do aparelho); fica coberta pelos testes do passo 1.

## 2026-11-27 — Fechamento

**Feito**
- Todos os critérios de aceite marcados. Status → `concluída` aqui e no índice.
- Docs: `docs/07-design-system.md` (`PendingRow` e tela Painel, passos 2 e 3), wireframe `Main` (passo 3), `docs/05-roadmap.md` (item novo da Fase 2), `docs/06-perguntas-em-aberto.md` (C28 com as escolhas desta task).

**Como verificar**
```bash
dart format . && flutter analyze && flutter test
```
Emulador: Painel com uma empresa com ruído pendente → seção "Lançamentos pendentes" → "Lançar".

**Pendente / dúvidas**
- C28 a confirmar com a cliente; `// TODO(RF-AMB-02)` em `groupPendingLaunches`.
- ETE/ETA (017): `launchRouteFor` abre o módulo Ambiental até existir a tela de lançamento (`// TODO(RF-AMB-07)`); a 017 também agrupa por estação.
- As notificações não são replanejadas na virada do dia (fora de escopo; continuam refeitas na abertura e a cada mudança).

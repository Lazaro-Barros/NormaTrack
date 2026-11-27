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

# Journal — 009

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Criada junto com as tasks 007 a 010, na divisão das telas de prazo depois da task 006 (domínio e dados): 007 módulo e cadastro, 008 detalhe e renovação, 009 painel, 010 notificações.

**Pendente / dúvidas**
- Rascunho.

## 2026-11-16 — Refinamento e plano

**Feito**
- README refeito (escopo, fora de escopo, 8 critérios de aceite) e `plan.md` escrito (contratos, `StatTile`, regras, testes com dados conferidos, passos). Status → `planejada`.
- `Main.dc.html` ajustado ao escopo: sem sino (task 010), sem data na faixa, sem "Ver todos" e sem "Para lançar" (Fase 2).
- Conferido no código: `watchUpcoming` do repositório real já cumpre RF-PRZ-05 e tem teste; o `FakeDeadlineRepository` não filtra empresa arquivada nem módulo desligado (passo 1 do plano corrige). `StatTile` ainda não existe.

**Decidido** (respostas da usuária)
- Lista com todos os prazos em aberto, sem limite e sem "Ver todos". Alternativas descartadas: 10 primeiros com "Ver todos"; só vencidos e a vencer.
- Tiles Vencidos · A vencer · Vigentes, tocar filtra e tocar de novo limpa; sem filtro por padrão. Alternativas descartadas: Vigentes escondido; tiles só informativos.
- Por minha conta, registrado em C23: contexto do card = empresa; abrir o detalhe com `push` (voltar retorna ao Painel); excluir no detalhe volta com `pop` quando possível.

**Pendente / dúvidas**
- Nenhuma que bloqueie. Aguardando aprovação do plano para implementar.

## 2026-11-26 — Implementação (passos 1 a 5)

**Feito**
- Branch `task/009-painel-vencimentos`. Status → `em andamento`.
- Passo 1: `FakeDeadlineRepository.watchUpcoming` segue o contrato quando há `companies` (empresa viva, não arquivada, com módulo habilitado) e reage a mudanças de empresa via o novo `FakeCompanyRepository.changes`; desempate por id, como o real.
- Passo 2: `StatTile` em `lib/app/widgets/` com 6 testes; linha do `docs/07-design-system.md` marcada ✅ e detalhada.
- Passo 3: `deadline_summary.dart` (`SituationCounts`, `filterBySituation`) e `situationPluralLabel`, com testes.
- Passo 4: `upcomingDeadlinesProvider` e `companyNamesProvider`.
- Passo 5: `DashboardScreen` no lugar do `DashboardPlaceholderScreen` (removido); excluir no detalhe volta com `pop` quando possível; `test/widget_test.dart` ajustado; `dashboard_screen_test.dart` com 8 testes. Suíte: 309 testes verdes (286 + 23).

**Decidido**
- Rótulo do tile com `Flexible` + reticências, para não estourar em tela estreita.
- Voltar nos testes com `find.byTooltip('Voltar')`: `tester.pageBack()` não acha o botão do `AppBar` (mesmo padrão do `module_screen_test`).
- Linha de coautoria dos commits: `Claude Opus 5.5` (o plano citava Sonnet).

**Refs:** commits 2c83e6a, fee9d79, c39e097, d936623, d76909e

## 2026-11-26 — Emulador, fonte grande e fechamento

**Feito**
- Conferido no emulador (`Medium_Phone_API_37.0`) com `prototypes/seed_main.dart`: vazio com "Ver empresas"; contagens 1 · 2 · 1 e lista na ordem, com o nome da empresa e o ano quando não é o corrente; prazos da empresa arquivada e da que tem o módulo desligado não aparecem; tocar no tile filtra e dá anel, tocar de novo limpa; card abre o detalhe e voltar retorna ao Painel com o filtro; concluir um laudo a partir do Painel muda as contagens para 1 · 1 · 1 ao voltar.
- **Fonte do sistema grande:** com altura fixa 78, os tiles estouravam (6 px em 1,3×, 27 px em 2×). Correção: `StatTile.heightOf(context)` calcula a altura pela escala do texto, limitada a 1,5× (`maxTextScale`); acima disso o rótulo encurta com reticências. Primeiro cálculo escalava a altura da linha e ainda estourava 2,4 px no aparelho: o Android 14+ escala de forma não linear e o `TextPainter` arredonda a altura do parágrafo para cima. Agora escala o `fontSize` de cada estilo e faz `ceil` por linha. Teste com um `TextScaler` não linear reproduz o caso. Conferido de novo no emulador em 1,3× e 2×: sem estouro nos tiles.
- `docs/07-design-system.md` (StatTile e linha do Painel), `docs/05-roadmap.md` (item marcado), critérios de aceite marcados, status `concluída`.
- `dart format .`, `flutter analyze` e `flutter test` (312) sem erros.

**Pendente / dúvidas**
- **Fora desta task:** o `DateBlock` (task 001, usado pelo `DeadlineCard` e pelo `StatusBanner`) estoura 1 px em 1,3× e 25 px em 2× com a fonte do sistema. Mesmo problema de altura fixa; precisa de task própria.
- C23 segue aguardando confirmação da cliente (suposições do Painel).

**Refs:** commit 4c16838 (fonte grande) · branch `task/009-painel-vencimentos`

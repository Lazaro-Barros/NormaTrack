# Journal — 006

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Task criada a partir do roadmap: com as tasks 001–005 concluídas, o próximo item em aberto da Fase 1 é o CRUD de prazos. Segue a divisão usada em empresas (002 dados → 003 telas): esta task cobre domínio e dados; telas, painel (RF-PRZ-05) e notificações (RF-PRZ-03) ficam para tasks seguintes.
- Branch `task/006-prazos-dominio-e-dados`.

**Pendente / dúvidas (na criação)**
- Refinar com a usuária antes do plano: antecedência padrão de laudo e manutenção (C3), conclusão de manutenção (RF-AMB-06), prazos sem órgão e o que conta como "vencido" no dia do vencimento.

## 2026-09-30 — Refinamento com a usuária

**Decidido** (respostas da usuária)
- **Antecedência (C3):** laudo e manutenção usam 30 dias; licença continua com 150. O modelo deve aceitar vários lembretes personalizáveis por prazo, com avisos menores depois do primeiro: 30, 10 e 3 dias e o próprio dia. Padrões: licença `150, 30, 10, 3, 0`; laudo e manutenção `30, 10, 3, 0`. O maior valor abre a janela "a vencer". As notificações em si continuam fora do escopo (RF-PRZ-03).
- **Manutenção (RF-AMB-06):** novo estado persistido `completed`, com data de conclusão. O prazo concluído sai dos próximos vencimentos. Manutenção periódica usa renovar.
- **Dia do vencimento:** o prazo vale até o dia do vencimento, inclusive; nesse dia está "a vencer" e fica "vencido" a partir do dia seguinte (mesma regra da validade do registro no órgão, C18).
- **Órgão:** opcional em qualquer categoria.
- README da task atualizado com essas regras.

**Pendente / dúvidas**
- Escrever o `plan.md`: como guardar a lista de lembretes (coluna de texto ou tabela filha), migração v1 → v2 e atualizar `docs/03-dominio.md`.

## 2026-09-30 — Plano escrito

**Feito**
- `plan.md` escrito e conferido contra o código (`lib/features/companies/`, `lib/core/database/`) e o `drift_dev` 2.35.0 do pub cache: `make-migrations` gera `app_database.steps.dart` com `stepByStep(from1To2: (m, Schema2 schema) …)` e **não sobrescreve** um `migration_test.dart` existente; por isso o plano renomeia o atual para `schema_test.dart` antes.
- Datas de exemplo dos testes calculadas por script (vencimento 2026-10-31 → alerta a partir de 2026-06-03).
- Suposições novas registradas em `docs/06-perguntas-em-aberto.md` (C20, C21). Status → `planejada`.

**Decidido**
- **Lembretes em tabela filha** `deadline_reminders` (escolha da usuária), com `(deadline_id, days_before)` único e reaproveitamento de linha excluída, como os registros em órgão. Vira D011 no fechamento.
- Sem `alertDaysBefore` gravado: a antecedência é o maior lembrete.
- Ações de estado explícitas no repositório: `renew`, `complete` (só laudo e manutenção), `cancel`, `reopen` (desfazer concluir/cancelar). `update` não muda estado.
- `watchUpcoming` devolve `Deadline` sem dados da empresa; o painel cruza com `CompanyRepository`.
- Excluir empresa passa a excluir os prazos dela (mudança em `LocalCompanyRepository.delete`).
- Suposições marcadas no plano: qualquer categoria em qualquer módulo; renovação com data posterior; excluir ciclo atual reabre o anterior; módulo desabilitado tira os prazos do painel (C20).

**Pendente / dúvidas**
- Revisão do plano pela usuária antes de implementar.

## 2026-09-30 — Passos 1 a 3: domínio, tabelas e migração v2

**Feito**
- Domínio em `lib/features/deadlines/domain/` conforme o plano, com 23 testes (enums, situação nos limites 2026-06-02/03, 2026-10-31 e 2026-11-01, datas dos lembretes, normalização e validação). Status → `em andamento`.
- `Deadlines` e `DeadlineReminders`, mapper, `AppDatabase` v2 com `stepByStep(from1To2: …)` criando as duas tabelas e os três índices.
- `make-migrations` gerou `drift_schemas/app/drift_schema_v2.json`, `app_database.steps.dart` e o teste de migração. O teste de dados foi preenchido: empresa, módulo e registro gravados na v1 continuam iguais na v2, e `deadlines` sai vazia. Conferido que o teste falha com `from1To2` vazio.
- 179 testes verdes, `flutter analyze` limpo.

**Decidido**
- Acréscimo ao plano: `DeadlineCategory.canBeCompleted` (falso só para licença), usado por `complete`.
- **Desvio do plano:** com `databases: app:` no `build.yaml`, o `make-migrations` escreve em `test/core/database/app/` (`migration_test.dart` e `generated/`), não em `test/core/database/`. A pasta `test/core/database/generated/` da task 002 ficou duplicada e foi removida; `schema_test.dart` (o antigo `migration_test.dart`, renomeado como previsto) perdeu o teste "schema v1 bate com o dump", agora coberto pela migração 1 → 2, e passou a checar também os índices parciais de `deadlines`.

**Refs:** commits c8f4cc7 · 1a258ea

## 2026-09-30 — Passos 4 e 5: repositório e cascata

**Feito**
- `LocalDeadlineRepository` e `deadlineRepositoryProvider`, com 25 testes de banco em memória (create/update, lembretes, renovar, concluir, cancelar, reabrir, excluir, histórico e listagens). Conferido com mutações que os testes pegam a falta do filtro de módulo habilitado, da reabertura do ciclo anterior e da descida na cadeia do histórico.
- `LocalCompanyRepository.delete` exclui logicamente os prazos e lembretes da empresa na mesma transação; teste novo (falha sem a mudança).

**Decidido**
- **Refinamento do plano:** excluir um prazo só reabre o anterior se o excluído estiver **em aberto** (for o ciclo atual). Sem essa condição, excluir um ciclo antigo renovado reabriria o ciclo ainda mais antigo e haveria dois ciclos em aberto, contrariando "excluir um ciclo antigo não muda os outros". `plan.md` corrigido.
- `update` grava as colunas do prazo sempre que algo muda (inclusive só os lembretes), para atualizar `updatedAt`; os lembretes só são sincronizados se a lista mudou.
- `watchHistory` segue para o ciclo seguinte preferindo o vivo e, sem vivo, o excluído mais recente (caso de renovar, excluir e renovar de novo).

**Refs:** commits 0a2f37c · 8e6899c

## 2026-09-30 — Task concluída

**Feito**
- Docs: `docs/03-dominio.md` (modelo `Deadline` + `DeadlineReminder` e regras), `docs/decisoes.md` ([D011](../../docs/decisoes.md#d011--lembretes-de-prazo-em-tabela-filha)), `docs/07-design-system.md` (situação derivada do maior lembrete; concluído e cancelado usam `statusClosed`), `docs/05-roadmap.md` (itens de prazo e renovação "em parte", faltam as telas). C20 e C21 já estavam em `docs/06-perguntas-em-aberto.md`.
- Todos os critérios de aceite marcados. `dart format .` (0 alterações), `flutter analyze` sem issues, `flutter test` com 205 testes verdes. `build_runner` e `make-migrations` rodados de novo sem diff. `grep` de Flutter/drift no domínio de prazos sem resultado.
- Status → `concluída` aqui e no índice.

**Como verificar**
```bash
dart run build_runner build --delete-conflicting-outputs   # sem diff
dart run drift_dev make-migrations                          # sem diff
dart format . && flutter analyze && flutter test
grep -rE "package:(flutter|drift)" lib/features/deadlines/domain   # vazio
```

**Pendente / dúvidas**
- Suposições a confirmar com a cliente: C3 (padrões de lembrete), C20 (categoria em qualquer módulo, renovação com data posterior, excluir ciclo atual reabre o anterior, módulo desabilitado tira o prazo do painel) e C21 (data de início do ciclo). Todas com `// TODO(RF-…)` no código.
- "Nº do documento" do wireframe `PrazoDetalhe` segue fora do modelo (C5/C13).
- Próximas tasks: telas de prazo (lista no módulo, cadastro, detalhe com histórico e renovação), painel de próximos vencimentos (RF-PRZ-05) e notificações (RF-PRZ-03, usando `Deadline.reminderDates`).

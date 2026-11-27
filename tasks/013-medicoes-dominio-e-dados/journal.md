# Journal — 013

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-26 — Task criada, quebra da Fase 2 e perguntas

**Feito**
- Fase 2 do roadmap quebrada em sete tasks (013–019), registradas com dependências e ordem em `tasks/README.md`. Esta é a primeira: a base genérica de parâmetros e medições, sem tela.
- Lidos: `docs/briefing-videos.md`, `02-requisitos`, `03-dominio`, `04-arquitetura`, `07-design-system`, `decisoes` (D005, D007, D008, D011, D014), wireframes `Lancamento`, `ModuloAmbiental`, `Relatorio`, `Main`, e os journals das tasks 006 (migração v1 → v2) e 012 (backup).
- Perguntas feitas ao usuário (AskUserQuestion), respostas em `docs/06-perguntas-em-aberto.md`.

**Decidido** (respostas do usuário)
- C6, ruídos: quantos pontos a empresa quiser (sugestão de 4 na primeira vez, task 014), unidade dB(A), limite máximo opcional por ponto, com aviso "Acima do limite".
- C26 (nova), lançamentos periódicos: período corrente "A lançar" e anteriores sem valor "Atrasado", a partir do período de início do parâmetro; parcial continua pendente; pode salvar parcial; passado e atual editáveis, futuro não; semana ISO de segunda a domingo (como o wireframe: semana 39 = 21 a 27/09/2026).
- "Sem medição no período" com justificativa: **sim** (o usuário escolheu essa opção em vez da recomendação "não por ora"). Na base: medição com `value` nulo e `note` obrigatória.
- C7, resíduos perigosos: tipos cadastrados pelo usuário, gerado e armazenado em kg, mensal (task 016).
- C7 (sólidos) e C8 (ETE/ETA): o usuário pediu perguntas mais simples para levar à cliente, com a explicação das classes e de ETE/ETA. Escritas em `docs/06-perguntas-em-aberto.md` ("Perguntas para levar à cliente"). Não bloqueiam esta task: a base aceita qualquer lista de parâmetros com unidade, frequência e faixa.
- Técnico (agente): resíduos ficam fora da estrutura genérica (tabela própria na 016); uma ETE e uma ETA por empresa como contextos, sem tabela de estação; sem frequência diária até C8.

**Pendente / dúvidas**
- Mostrar o plano ao usuário antes de implementar.

## 2026-11-27 — Respostas da cliente (C7, C8) e ajuste do plano

**Feito**
- Respostas da cliente por WhatsApp (perguntas enviadas pelo usuário em 2026-11-26) registradas em `docs/06-perguntas-em-aberto.md` (C7, C8) e na quebra da Fase 2 (`tasks/README.md`, tasks 016 e 017).
- `plan.md` ajustado: frequências `daily` e `biweekly` além de `weekly` e `monthly`, com testes de período e de pendência para as duas.

**Decidido**
- ETA diária e ETE semanal, quinzenal ou mensal entram já na base (só enum e cálculo de período; sem impacto no banco).
- Quinzena = dias 1–15 e 16–fim do mês **[suposição]** (C8).
- Mais de uma ETE/ETA por empresa: a tabela de estações fica para a 017 (migração própria), para a 013 não passar de duas tabelas. A base mantém os contextos `effluent`/`water`.
- Faixa de pH 6–8 da ETE já cabe em `limitMin`/`limitMax`.
- Resíduos: tipos por classe, kg, semanal (perigosos = Classe I). A 016 decide se reaproveita esta base.

**Pendente / dúvidas**
- Aprovação do plano ajustado pelo usuário.

## 2026-11-27 — Resíduos: armazenada em todas as classes

**Decidido** (usuário)
- A quantidade armazenada vale para todas as classes de resíduo, não só para a Classe I. Registrado em C7 e na linha da task 016.
- Frequência dos resíduos: por tipo, com padrão semanal; não precisa perguntar à cliente (explicado ao usuário que a frequência só define o que o app cobra, a navegação da tela e a soma do relatório).
- Sem impacto na 013: resíduos com dois valores por lançamento são da 016.

## 2026-11-27 — Passo 1: domínio

**Feito**
- Plano aprovado pelo usuário. Status → `em andamento`.
- `lib/features/measurements/domain/`: `MeasurementContext`, `MeasurementFrequency` (diária, semanal, quinzenal, mensal), `MeasurementPeriod`, `MeasurementParameter` (com `LimitStatus`), `Measurement`/`MeasurementEntry`, validação, `pendingLaunches` e a interface `MeasurementRepository` com as exceções. 37 testes de domínio.

**Decidido**
- Desempate extra na ordem das pendências: depois de período, contexto e empresa, a frequência (dois grupos do mesmo contexto podem começar no mesmo dia, ex.: quinzenal e mensal em 01/11).

## 2026-11-27 — Passo 2: tabelas e migração v3

**Feito**
- `measurement_parameters` e `measurements` (`lib/features/measurements/data/measurement_tables.dart`) com os índices parciais do plano; `AppDatabase` v3 com `from2To3`.
- `make-migrations` gerou `drift_schemas/app/drift_schema_v3.json`, `schema_v3.dart` e o passo no `app_database.steps.dart`; rodado de novo sem diff.
- Teste "v2 → v3 não corrompe dados" escrito à mão (empresa arquivada, módulo, registro, prazo renovado + atual e lembrete excluído iguais coluna a coluna; tabelas novas vazias). Conferido que falha com o `from2To3` vazio. `schema_test.dart` checa os dois índices novos.
- Testes de backup passam a esperar `AppDatabase.currentSchemaVersion` em vez de 2, para a suíte seguir verde neste passo (as tabelas novas entram no backup no passo 4).

**Decidido**
- Nota de processo: na checagem do `from2To3` vazio, um `git checkout` do arquivo desfez também as mudanças ainda não commitadas; o arquivo foi restaurado da cópia feita antes. Para checagens assim, restaurar sempre da cópia, nunca do git.

## 2026-11-27 — Passo 3: repositório e cascata

**Feito**
- `measurement_mapper.dart`, `LocalMeasurementRepository` e `measurementRepositoryProvider`, conforme o contrato do plano. Consulta-gatilho própria (`SELECT 1 AS measurements_changed`, D008).
- `LocalCompanyRepository.delete` exclui logicamente os parâmetros e as medições da empresa na mesma transação; teste novo em `local_company_repository_test.dart`.
- 20 testes de banco em memória para o repositório: criar (normalização, posição, duplicado sem acento/caixa, empresa inexistente/excluída/sem módulo, arquivada pode), editar (sem mudança não grava, duplicado, frequência travada e liberada), ordenar, arquivar, excluir em cascata, `savePeriod` (parcial, edição, apagar, justificativa, linha nova depois de apagar, passado/atual/arquivado aceitos, futuro recusado, inválido não grava nada, excluído e frequência errada), `watchMeasurements` com `from`/`to` e `watchPendingLaunches` (stream reage ao `savePeriod`; empresa arquivada, excluída ou com módulo desligado some).

**Decidido**
- Desligar o módulo tira as pendências da empresa (como os prazos do Painel, C20), mas não apaga parâmetros nem medições.

## 2026-11-27 — Passo 4: backup v3

**Feito**
- `_tablesByVersion[3] = ['measurement_parameters', 'measurements']` (D014). A "última alteração" do resumo passa a considerar as duas tabelas (consulta montada a partir de uma lista de tabelas por versão, em vez de condicionais no SQL).
- Testes novos em `local_backup_service_test.dart`: backup v2 com empresa, módulo, prazo e lembrete é aceito (resumo v2), restaurado e migrado para v3 (`validateDatabaseSchema`, prazo e lembrete intactos); backup v3 com ponto e medição faz ida e volta (restaurar outro e depois ele de novo traz a medição) e a medição conta como última alteração; arquivo marcado v3 sem as tabelas de medições é recusado. Conferido que este último falha sem a linha nova em `_tablesByVersion`.

## 2026-11-27 — Verificação no emulador

**Feito** (emulador `Medium_Phone_API_37.0`; sem `pm clear`, sem desinstalar, instalado com `adb install -r`)
- Antes de instalar: banco copiado para o Mac (`antes.sqlite` no scratchpad da sessão): `user_version` 2, `quick_check` ok, 5 empresas (incluindo "Alfa To To To To"), 8 prazos (5 em aberto, 1 cancelado, 1 concluído, 1 renovado), 38 lembretes.
- Backup pelo app (Ajustes → Fazer backup): `NormaTrack-backup-2026-11-27-1214.ntbackup` gerado; folha fechada sem enviar. Cópia em `/sdcard/Download/antes-task013.ntbackup` (fica no emulador como salvaguarda, ao lado de `original-usuaria.ntbackup`).
- `flutter build apk --debug` + `adb install -r`. Na abertura o banco foi para a v3: `quick_check` ok, `measurement_parameters` e `measurements` vazias com os dois índices parciais, e as 5 tabelas antigas **iguais linha a linha** à cópia de antes (comparação por hash de `SELECT * … ORDER BY id`). Painel com os mesmos prazos.
- Restaurado pelo app o backup v2 de antes da atualização: confirmação "5 empresas e 6 prazos, com última alteração em 26/11/2026" (6 = em aberto + concluído + cancelado, sem o renovado e um excluído), SnackBar "Backup restaurado" com "Desfazer". Depois da restauração o banco está na v3, íntegro, e as 5 tabelas antigas continuam iguais às de antes.

**Decidido**
- Observação, não corrigida aqui: o processo antigo do app estava aberto desde 26/11 e o Painel mostrava "Venceu há 3 dias" em 27/11 (depois de reabrir, "há 4 dias"). As listas não viram o dia sozinhas. A task 015 já prevê reassinar as pendências na virada do dia; o mesmo vale para os prazos do Painel.

## 2026-11-27 — Fechamento

**Feito**
- Todos os critérios de aceite marcados. Status → `concluída` aqui e no índice.
- Docs: `docs/03-dominio.md` (glossário, modelo `MeasurementParameter`/`Measurement`, regras de medições e pendências), `docs/decisoes.md` (D005 aceita e [D015](../../docs/decisoes.md#d015--medições-genéricas-por-período)), `docs/04-arquitetura.md` (`features/measurements/`), `docs/05-roadmap.md` (item "Parâmetros e medições" marcado). C6, C7, C8 e C26 já estavam em `docs/06-perguntas-em-aberto.md`.

**Como verificar**
```bash
dart run build_runner build --delete-conflicting-outputs   # sem diff
dart run drift_dev make-migrations                          # sem diff
dart format . && flutter analyze && flutter test
grep -rE "package:(flutter|drift)" lib/features/measurements/domain   # vazio
```

**Pendente / dúvidas**
- Suposições a confirmar com a cliente, com `// TODO(RF-AMB-…)` no código: quinzena 1–15/16–fim (C8); arquivar um parâmetro tira inclusive as pendências passadas (C26); C6 e C26 respondidas pelo usuário, falta a cliente.
- Próximas: 014 (Ruídos: pontos e lançamento), depois 015 (Painel com pendências). A 017 acrescenta a tabela de estações e agrupa as pendências também por estação.

## 2026-11-27 — Correção de termos

**Feito**
- A pedido do usuário: a pessoa que usa o app é sempre "o usuário" (nunca "a usuária"). Termo corrigido em todos os docs, tasks, na skill de tasks e no nome de um teste (26 arquivos). "A cliente" (quem pediu o app, nos vídeos) continua como está.
- Os dados do emulador (empresas como "Alfa To To To To") são **de teste**: nada foi publicado e não há dados reais. Textos das tasks 012 e 013 que falavam em "dados do usuário" passam a dizer "dados de teste do emulador". O cuidado com eles (não apagar, `adb install -r`, cópia antes de migrar) continua valendo, porque são a base das verificações.

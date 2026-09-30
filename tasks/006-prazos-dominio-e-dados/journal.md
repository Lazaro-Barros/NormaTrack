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

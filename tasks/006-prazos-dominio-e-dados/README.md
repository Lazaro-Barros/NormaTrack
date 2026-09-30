# 006 — Prazos: domínio e dados

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-01, RF-PRZ-02, RF-PRZ-04 · RF-AMB-01, RF-AMB-05, RF-AMB-06, RF-PCT-01 (como categorias de prazo) |
| **Depende de** | 002 (concluída) |
| **Wireframe** | — (sem UI; telas numa task seguinte) |

## Objetivo

Modelar e persistir os prazos de cada empresa (licenças, laudos e manutenções), com a situação calculada no domínio e a renovação guardando o histórico. Essa é a base das telas de prazo, do painel de próximos vencimentos (RF-PRZ-05) e das notificações (RF-PRZ-03).

## Escopo

- Domínio (Dart puro):
  - `Deadline` com empresa, módulo (`ModuleType`), categoria (`DeadlineCategory`: licença, laudo, manutenção), órgão opcional em qualquer categoria (`Authority`), título, data de vencimento, lista de lembretes em dias antes do vencimento, estado persistido (`active`/`renewed`/`completed`/`cancelled`), data de conclusão e o prazo anterior (`previousDeadlineId`).
  - Lembretes: o maior valor é a antecedência do alerta (RF-PRZ-02) e abre a janela "a vencer"; os demais são avisos extras para as notificações da task futura. Padrão por categoria: licença `150, 30, 10, 3, 0`; laudo e manutenção `30, 10, 3, 0`. Editável por prazo.
  - Situação derivada (`DeadlineSituation`: vigente, a vencer, vencido, renovado, concluído, cancelado), calculada a partir de `dueDate`, dos lembretes, do estado e da data atual. Não é persistida. O prazo vale até o dia do vencimento, inclusive: nesse dia está "a vencer"; "vencido" a partir do dia seguinte.
  - Concluir (manutenção e laudo, RF-AMB-06): estado `completed` com data de conclusão; sai dos próximos vencimentos. Manutenção periódica usa renovar.
  - Validação: título obrigatório, lembretes ≥ 0 sem repetição e ao menos um, módulo habilitado na empresa.
  - `DeadlineRepository` (interface): criar, editar, concluir, cancelar, reabrir, excluir (lógico), renovar, listar por empresa e por módulo, listar os próximos vencimentos de todas as empresas e consultar o histórico de um prazo.
- Dados: tabela `deadlines` e tabela filha `deadline_reminders` (schema **v2**, a primeira migração real), mapper e `LocalDeadlineRepository`. Renovar roda numa transação.
- Provider Riverpod do repositório.
- Excluir uma empresa exclui (logicamente) os prazos dela.

## Fora de escopo

- Telas de prazo e o painel (tasks seguintes).
- Notificações locais (RF-PRZ-03, C4).
- Prazo gerado automaticamente pela validade do registro no órgão (C16).
- Anexos (C13).

## Critérios de aceite

- [ ] Criar, editar, concluir, cancelar e excluir (lógico) um prazo. Título obrigatório; módulo precisa estar habilitado na empresa; o erro é um tipo do domínio.
- [ ] Os lembretes vêm preenchidos pela categoria (licença `150, 30, 10, 3, 0`; laudo e manutenção `30, 10, 3, 0`) e podem ser editados por prazo.
- [ ] A situação (vigente, a vencer, vencido, renovado, concluído, cancelado) é calculada no domínio e testada nos limites da janela de alerta e do dia do vencimento.
- [ ] Renovar encerra o ciclo atual (`renewed`) e cria o próximo, com nova data, apontando para o anterior, numa transação. O histórico de ciclos pode ser consultado.
- [ ] Listagens reativas (`Stream`): por empresa, por empresa e módulo, e próximos vencimentos de todas as empresas (sem empresas arquivadas e sem prazos excluídos, cancelados, concluídos ou renovados).
- [ ] Tabelas `deadlines` e `deadline_reminders` com `id` UUID, `createdAt`, `updatedAt` e `deletedAt`. Migração v1 → v2 com teste gerado pelo `drift_dev make-migrations`.
- [ ] `docs/03-dominio.md` e `docs/06-perguntas-em-aberto.md` refletem o modelo e as suposições.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Para quem vai implementar

Comece pelo [plano](plan.md): ele é autocontido (ordem dos passos, contratos, valores de referência, regras, testes e como verificar). Depois leia o fim do [journal](journal.md).

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

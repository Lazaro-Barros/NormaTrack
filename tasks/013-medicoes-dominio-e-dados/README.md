# 013 — Medições: domínio e dados

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 2 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-AMB-02, RF-AMB-07 (base genérica), RNF-03, RNF-04 |
| **Depende de** | 006 (padrões de domínio e dados), 012 (backup, D014) |
| **Wireframe** | [Lancamento.dc.html](../../docs/design/wireframes/Lancamento.dc.html) (só como referência do que a base precisa suportar; a tela é da task 014) |

## Objetivo

Criar a base genérica de **parâmetros e medições** ([domínio](../../docs/03-dominio.md), D005) que as tasks de Ruídos (014), Painel (015) e ETE/ETA (017) vão usar: pontos/parâmetros por empresa, lançamento por período (dia, semana ISO, quinzena ou mês), justificativa de "sem medição", limites e pendências calculadas. Sem tela nesta task. O banco passa da versão 2 para a 3 sem perder dados, e backups v2 continuam restauráveis.

## Escopo

- Domínio puro em `lib/features/measurements/domain/`: contexto (`noise`, `effluent`, `water`), frequência (`daily`, `weekly`, `biweekly`, `monthly`), período, parâmetro com limites, medição (valor **ou** justificativa), validação e cálculo de pendências ("A lançar" / "Atrasado").
- Tabelas `measurement_parameters` e `measurements`, migração drift v2 → v3 com `make-migrations` e teste de migração com dados.
- `MeasurementRepository` + `LocalMeasurementRepository` (banco em memória nos testes), provider Riverpod.
- Excluir empresa exclui logicamente os parâmetros e as medições dela.
- Backup (D014): tabelas novas em `_tablesByVersion`, última alteração considera as medições, backup v2 restaurável (migrado para v3).
- Docs: `docs/03-dominio.md`, `docs/04-arquitetura.md`, `docs/decisoes.md` (D015), `docs/05-roadmap.md`, `docs/06-perguntas-em-aberto.md`.

## Fora de escopo

- Telas: cadastro de pontos, lançamento e aba Lançamentos (014); `PendingRow` e Painel (015).
- Resíduos (016, tabela própria), estações ETE/ETA com lista própria (017), exportação (018).
- Estações (várias ETE/ETA por empresa, C8): tabela própria na task 017.

## Critérios de aceite

- [x] `lib/features/measurements/domain` sem imports de Flutter ou drift; testes de período (semana ISO, virada de ano, mês), limites, validação e pendências passam.
- [x] Banco na versão 3 com as duas tabelas e os índices parciais do plano; `make-migrations` gerou `drift_schema_v3.json`, `schema_v3.dart` e o passo `from2To3`.
- [x] Teste de migração v2 → v3 com dados (empresa, módulo, registro, prazo e lembrete iguais depois; tabelas novas vazias) e migrações simples 1→3 e 2→3 verdes.
- [x] Repositório cobre criar/editar/ordenar/arquivar/excluir parâmetro, salvar período (parcial, edição, apagar, justificativa, futuro recusado) e pendências, com testes de banco em memória.
- [x] Excluir empresa exclui logicamente parâmetros e medições dela (teste).
- [x] Backup: `_tablesByVersion` tem a v3; teste de backup v2 restaurado e migrado para v3 com os dados intactos; backup v3 com medições faz ida e volta.
- [x] Conferido no emulador: banco da usuária migrado para v3 sem perda (tabelas antigas iguais linha a linha à cópia de antes) e backup v2 feito pelo app restaurável depois da atualização.
- [x] Docs atualizados; `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Links

- [Plano técnico](plan.md) (ponto de partida para implementar) · [Journal](journal.md) · [Protótipos](prototypes/)

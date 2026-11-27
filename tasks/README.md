# Tasks

Cada task é uma pasta `NNN-slug/` com escopo (`README.md`), plano técnico (`plan.md`), diário (`journal.md`) e protótipos (`prototypes/`). O fluxo completo está na skill [`.claude/skills/task/SKILL.md`](../.claude/skills/task/SKILL.md). Para criar uma task, copie [`_template/`](_template/).

Status: `rascunho` · `planejada` · `em andamento` · `concluída` · `bloqueada` · `cancelada`

| # | Task | Requisitos | Fase | Status |
|---|---|---|---|---|
| 001 | [Design system e tema Flutter](001-design-system-e-tema/) | RNF-06 | 0 | concluída |
| 002 | [Empresas: domínio e dados](002-empresas-dominio-e-dados/) | RF-EMP-01/02/04/05 | 1 | concluída |
| 003 | [Empresas: telas de lista, cadastro e detalhe](003-empresas-telas/) | RF-EMP-01..05 | 1 | concluída |
| 004 | [Refinamento visual: menos informação e mais cor](004-refinamento-visual/) | RNF-06 | 1 | concluída |
| 005 | [Botão tonal com as cores do design system](005-botao-tonal/) | RNF-06 | 1 | concluída |
| 006 | [Prazos: domínio e dados](006-prazos-dominio-e-dados/) | RF-PRZ-01/02/04 | 1 | concluída |
| 007 | [Prazos: tela do módulo e cadastro](007-prazos-modulo-e-cadastro/) | RF-PRZ-01/02 | 1 | concluída |
| 008 | [Prazos: detalhe, histórico e renovação](008-prazo-detalhe/) | RF-PRZ-01/04 | 1 | concluída |
| 009 | [Painel de próximos vencimentos](009-painel-vencimentos/) | RF-PRZ-05 | 1 | concluída |
| 010 | [Notificações locais de prazo](010-notificacoes-locais/) | RF-PRZ-03 | 1 | concluída |
| 011 | [Bloco de data com a fonte do sistema grande](011-date-block-fonte-grande/) | RNF-06 | 1 | concluída |
| 012 | [Backup e restauração manual do banco](012-backup-restauracao/) | RNF-04 | 1 | concluída |
| 013 | [Medições: domínio e dados](013-medicoes-dominio-e-dados/) | RF-AMB-02/07, RNF-04 | 2 | concluída |
| 014 | [Ruídos: pontos de medição e lançamento semanal](014-ruidos-pontos-e-lancamento/) | RF-AMB-02 | 2 | concluída |

## Fase 2 — quebra em tasks (2026-11-26)

Quebra do item "Fase 2 — Automonitoramento ambiental" do [roadmap](../docs/05-roadmap.md), pelo critério da skill (uma tela grande ou uma tabela com regras próprias por task, até ~8 critérios de aceite). Os números ficam reservados; a pasta de cada uma é criada quando ela começar. A ordem proposta é a da tabela.

| # | Task prevista | Requisitos | Depende de | Entrega |
|---|---|---|---|---|
| 013 | Medições: domínio e dados (parâmetros, medições, períodos e pendências; migração v2 → v3) | RF-AMB-02/07 (base) | 006, 012 | Base genérica `MeasurementParameter` + `Measurement`, sem tela |
| 014 | Ruídos: pontos de medição e lançamento semanal | RF-AMB-02 | 013 | Cadastro dos pontos, tela "Lançamento periódico" e seção "Automonitoramento" no módulo Ambiental |
| 015 | Painel: lançamentos pendentes | RF-AMB-02, RF-PRZ-05 | 014 | `PendingRow` e a seção de pendências no Painel (genérica para qualquer contexto de medição) |
| 016 | Resíduos sólidos e perigosos | RF-AMB-03/04 | 013, 015 | Tipos de resíduo por classe (I, II-A, II-B; perigosos = Classe I), em kg, com quantidade gerada **e** armazenada em todas as classes, frequência por tipo com padrão semanal (C7). Reavaliar no refinamento se cabe na base genérica (dois valores por medição) ou se precisa de tabela própria |
| 017 | Controle da ETE/ETA | RF-AMB-07 | 014, 015 | Estações por empresa (pode haver mais de uma, C8: tabela de estações e migração), parâmetros por estação (ETE semanal/quinzenal/mensal, pH 6–8; ETA diária) reaproveitando a tela de lançamento da 014 |
| 018 | Exportação `.xlsx` e compartilhamento | RF-REL-01/03 | 014, 016, 017 | Tela "Gerar relatório" (período e conteúdo), planilha e folha de compartilhamento |
| 019 | Prova de conceito de `.docx` a partir de modelo | RF-REL-02 | 018 | Spike em `prototypes/`, sem tela; decide o pacote para a Fase 3 |

Dependências: 013 é a base de tudo. 014 → 015 (o Painel precisa de um lançamento real para mostrar). 016 e 017 são independentes entre si depois da 015. 018 exporta o que 014, 016 e 017 gravam; pode começar só com Ruídos se as outras atrasarem. 019 só precisa da 018 para reaproveitar a montagem dos dados do relatório.

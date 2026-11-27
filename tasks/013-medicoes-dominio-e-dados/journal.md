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
- C7, resíduos perigosos: tipos cadastrados pela usuária, gerado e armazenado em kg, mensal (task 016).
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

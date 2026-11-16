# Journal — 008

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Criada junto com as tasks 007 a 010, na divisão das telas de prazo depois da task 006 (domínio e dados): 007 módulo e cadastro, 008 detalhe e renovação, 009 painel, 010 notificações.

**Pendente / dúvidas**
- Rascunho. Antes de refinar, levar à cliente C21 (data de início/emissão do ciclo) e o "Nº do documento" (C5/C13), que aparecem no wireframe.

## 2026-11-16 — Refinamento e plano

**Feito**
- README refeito (escopo, fora de escopo e 8 critérios de aceite) e `plan.md` escrito: rotas, domínio (`suggestedRenewalDate`), widgets (`DateBlock`, `StatusBanner`, `StatusChip.icon`, `dismissLabel`), rótulos, tela de detalhe, ações, sheets, segmentado "Em aberto | Encerrados" e testes por arquivo. Status → `planejada`.
- `PrazoDetalhe.dc.html` ajustado: sem "Nº do documento", "Alerta" virou "Lembretes" (uma linha por aviso), ciclo mais antigo sem início.
- `docs/06-perguntas-em-aberto.md`: C13 e C21 com a suposição adotada; C22 nova.
- Conferido no código: o repositório real já cobre todas as transições; o `FakeDeadlineRepository` não (histórico, validações, exclusão que reabre o anterior), então o passo 1 do plano o corrige.

**Decidido** (respostas da usuária)
- C21 e C13: assumir o mais simples. Sem data de emissão do ciclo, sem anexos, sem "Nº do documento" (tirado do wireframe e do escopo).
- Encerrados: segmentado "Em aberto | Encerrados" na tela do módulo (concluídos e cancelados; renovados só no histórico). Alternativas descartadas: seção no fim da lista e deixar para depois.
- Renovação: sheet com data sugerida (mesmo intervalo em meses do ciclo anterior; sem anterior, +1 ano), editável, sem aceitar data até o vencimento atual. Alternativa descartada: seletor direto.
- Excluir: item do menu ⋮ com confirmação destrutiva que avisa quando reabre o ciclo anterior. Alternativa descartada: botão no corpo.
- Por minha conta (registrado em C22): laudo/manutenção têm **Concluir** como primário e renovar no menu; licença tem **Renovar** como primário; cancelar usa confirmação não destrutiva com botões "Voltar" e "Cancelar prazo" (é reversível); reabrir sem confirmação; renovado é somente leitura.

**Pendente / dúvidas**
- Nenhuma que bloqueie. Levar C13, C21 e C22 à cliente quando possível.

**Próximo:** implementar pelo passo 1 do plano, na branch `task/008-prazo-detalhe`.

## 2026-11-16 — Implementação, passos 1 a 5

**Feito**
- Branch `task/008-prazo-detalhe`. Passo 1: `FakeDeadlineRepository` agora valida como o real (histórico por cadeia, `renew` com data posterior, transições inválidas, `delete` que reabre o anterior). Passo 2: `suggestedRenewalDate`. Passo 3: `DateBlock`, `StatusBanner`, `StatusChip.icon`, `showConfirmDialog(dismissLabel:)` + `docs/07-design-system.md`. Passo 4: providers e rótulos. Passo 5: rota `prazos/:prazo` (com `editar` aninhada) e `DeadlineDetailScreen` somente leitura; o card do módulo abre o detalhe.
- Suíte: 274 testes verdes.

**Decidido**
- A linha vertical de 2 px entre os círculos do histórico (plan.md) ficou de fora: o `SectionCard` já separa os ciclos com `Divider` e a linha ficaria cortada. Sem impacto funcional.
- O teste de edição do formulário passou a abrir direto em `editDeadline(...)`; o fluxo pelo botão Editar é testado no passo 6.
- `deadlineBanner` não usa `!` em `completedOn`: sem data, o título cai em "Concluído".


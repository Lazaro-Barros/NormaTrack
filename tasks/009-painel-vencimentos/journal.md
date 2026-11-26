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

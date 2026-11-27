# Journal — 014

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-27 — Task criada e refinada

**Feito**
- Task criada a partir da quebra da Fase 2 (`tasks/README.md`), depois da 013. Lidos o wireframe `Lancamento`, `ModuloAmbiental`, a tela do módulo (`module_screen.dart`), as rotas e os widgets de `lib/app/widgets/`.

**Decidido** (respostas do usuário)
- Ruídos entra no módulo Ambiental como seção "Automonitoramento" no topo da lista, com a linha "Ruídos" e a situação à direita. A faixa do módulo não muda (as abas do wireframe ficam descartadas: a faixa já tem "Em aberto | Encerrados" e o design system permite um bloco).
- "Sem medição": para a semana inteira (pontos vazios) **e** por ponto, sempre com motivo.
- Primeira vez sem pontos: cadastrar um por um (sem o atalho "Criar 4 pontos").
- Sem botão "Rascunho": só "Salvar", que grava parcial; a semana segue pendente até completar.

**Pendente / dúvidas**
- Mostrar o plano ao usuário antes de implementar.

## 2026-11-27 — Passo 1: protótipos aprovados

**Feito**
- Plano aprovado pelo usuário. Status → `em andamento`.
- Protótipos `Lancamento`, `PontosMedicao`, `PontoSheet` e `ModuloAmbiental` (gerados a partir do `Lancamento` antigo, conferidos em 390 × 844) aprovados pelo usuário e copiados para `docs/design/wireframes/` (substituem `Lancamento` e `ModuloAmbiental`).
- Dúvida do usuário respondida: o caminho é Empresas → empresa → Ambiental → Ruídos; o atalho para todas as empresas é o Painel com pendências (task 015).

**Decidido**
- `ModuloAmbiental` passa a mostrar a faixa como está no app ("Em aberto | Encerrados"), sem as abas e sem o botão de relatório (que entra na 018).

# Journal — 003

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-24 — Task criada

**Feito**
- Task criada junto com a [002](../002-empresas-dominio-e-dados/), a partir do pedido de cadastro de empresa. Esta task cobre só a interface. Modelo e decisões de dados estão no journal da 002.

**Pendente / dúvidas**
- Plano técnico a escrever depois que a 002 estiver implementada (os nomes do domínio podem mudar). Ele precisa passar no teste do agente novo (skill `task`, passo 3) antes do status `planejada`, com o mesmo nível de detalhe do plano da 002.
- O formulário ficou longo (6 seções). Prototipar antes: uma tela rolável com seções ou etapas.

## 2026-09-29 — Wireframes refeitos no design system v0.2

**Feito**
- Na [task 004](../004-refinamento-visual/) os wireframes `Empresas`, `EmpresaForm` e `EmpresaDetalhe` foram refeitos na direção A, e foi criado `EmpresaOrgao` (bottom sheet de registro em órgão).

**Decidido**
- Formulário: uma tela rolável com seções em cards (não etapas). Cada órgão é uma linha com a situação em pílula; tocar abre o bottom sheet com situação, nº, validade e observações. Mantém a tela curta mesmo com 9 órgãos.
- Lista de empresas mostra só nome, cidade/UF e pior situação; CNPJ e módulos ficam no detalhe.
- Detalhe mostra só os órgãos que se aplicam, com link "Ver todos os 9 órgãos".

**Pendente / dúvidas**
- Aprovação da usuária para os wireframes v0.2 (critério de aceite desta task).
- Componentes novos da v0.2 que esta task vai precisar: `NavRow`, `SwitchRow`, `AppTextField`, `EmptyState` e a faixa de cabeçalho com bloco extra (busca na lista, resumo no detalhe).

## 2026-09-29 — Wireframes v0.2 aprovados

**Decidido**
- Usuária aprovou os wireframes v0.2 de `Empresas`, `EmpresaForm`, `EmpresaOrgao` e `EmpresaDetalhe`. Critério de aceite do wireframe do formulário atendido.

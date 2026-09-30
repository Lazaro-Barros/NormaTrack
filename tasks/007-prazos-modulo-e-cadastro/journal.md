# Journal — 007

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Criada junto com as tasks 007 a 010, na divisão das telas de prazo depois da task 006 (domínio e dados): 007 módulo e cadastro, 008 detalhe e renovação, 009 painel, 010 notificações.

**Pendente / dúvidas**
- Rascunho. Refinar com a usuária antes do plano.

## 2026-09-30 — Refinamento com a usuária

**Decidido** (respostas da usuária)
- **Lembretes:** lista livre no formulário (cada lembrete removível, "Adicionar lembrete"), em vez do contador único do wireframe. Adicionar abre um bottom sheet com campo de dias e atalhos, no padrão do sheet de órgão.
- **Tela do módulo:** só prazos, sem abas; Lançamentos e Relatórios entram quando existirem.
- **Agrupamento:** por categoria (Licenças, Laudos, Manutenções). O "ETE e ETA" do wireframe depende de estações (Fase 2).
- **Toque no prazo:** abre a edição até a task 008 trazer o detalhe.
- **EmptyState:** passa a ficar dentro de um card branco, onde o botão tonal tem contraste (fecha a pendência da task 005). Muda o componente para todas as telas.
- **Pendências por módulo:** entram nesta task. A linha do módulo no detalhe da empresa mostra a pior situação com a contagem (fecha o `TODO(RF-EMP-03)` de `company_detail_screen.dart`).
- **Protótipo:** fazer o do formulário antes do plano; aprovado, vira o wireframe oficial.
- README atualizado com o escopo.

**Pendente / dúvidas**
- Protótipo do formulário em `prototypes/` para aprovação.

## 2026-09-30 — Protótipo do formulário

**Feito**
- `prototypes/PrazoForm.dc.html` e `prototypes/PrazoLembrete.dc.html`, a partir do wireframe `PrazoForm` e do sheet `EmpresaOrgao`. Conferidos em screenshot headless (390 × 844).
- Tasks 008, 009 e 010 criadas como `rascunho` junto com esta.

**Decidido**
- O contador "Alertar com antecedência" sai; a legenda "Alertas a partir de …" vai para o título da seção Lembretes.
- Os atalhos do sheet escondem os valores que já estão na lista; valor repetido digitado à mão não é adicionado de novo (a normalização do domínio já remove repetidos).

**Pendente / dúvidas**
- Aprovação da usuária. Aprovado: copiar para `docs/design/wireframes/` (`PrazoForm` e um novo `PrazoLembrete`) e escrever o plano.

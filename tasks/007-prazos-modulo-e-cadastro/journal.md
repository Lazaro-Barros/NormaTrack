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

## 2026-09-30 — Protótipo aprovado e plano escrito

**Feito**
- Usuária aprovou o protótipo. `docs/design/wireframes/PrazoForm.dc.html` substituído e `PrazoLembrete.dc.html` criado.
- `plan.md` escrito, conferido contra o código de empresas (formulário, sheet de órgão, detalhe, lista), o tema e os helpers de teste. Datas de exemplo calculadas por script a partir de `testNow` (29/09/2026). Critérios de aceite no README. Status → `planejada`.

**Decidido**
- Rotas aninhadas na empresa: `/empresas/:id/modulos/:modulo[/prazos/novo | /prazos/:prazo/editar]`, com slug pt-BR do módulo (`ambiental`, `produtos-controlados`, `controle-de-qualidade`).
- Categoria no segmentado da faixa, como no protótipo: componente novo `BandSegmentedButton` e cor `onBandSegment` (`#307179`, branco a 14 % sobre o petróleo), com teste de contraste.
- Componentes pequenos que faltavam: `AppTextField.helperText`, `FieldErrorText` (erro fora de campo) e `AppDropdownField.noneLabel` ("Nenhum" para órgão).
- Texto relativo do card: "Venceu ontem / há n dias", "Vence hoje / amanhã / em n dias", vigente "Em n dias" até 365 e "Em n anos" acima. Ano no bloco de data só quando não é o ano corrente. Decisão de interface, não regra de negócio.
- Pendências no detalhe da empresa: vencidos têm prioridade sobre a vencer; só vigentes não mostram nada.
- `pumpApp` passa a sobrescrever `deadlineRepositoryProvider` com um fake por padrão (senão os testes de widget tentariam abrir o banco real).

**Pendente / dúvidas**
- Revisão do plano pela usuária antes de implementar.

## 2026-09-30 — Implementação, passos 1 a 6 (código escrito, testes de tela pendentes)

**Feito**
- Passo 1 (commit): `FakeDeadlineRepository` e `pumpApp` com override de `deadlineRepositoryProvider`; suíte continuou verde (205). Status → `em andamento`.
- Passo 2 (commit): `formatMonthAbbr` e `reminderDate` (domínio), com testes.
- Passos 3 a 6 escritos, **ainda sem commit e sem rodar análise/testes**: `DeadlineCard`, `BandSegmentedButton` (+ `AppColors.onBandSegment`, `BandColors.segment`), `EmptyState` em card, `AppTextField.helperText`, `AppDropdownField.noneLabel`, `FieldErrorText`, com testes; `deadline_labels.dart` (+ teste), `deadline_providers.dart`, slug em `company_labels.dart`; rotas; `ModuleScreen`; pendências e navegação no detalhe da empresa; `reminder_sheet.dart`; `DeadlineFormScreen`.

**Decidido**
- O FAB "Novo prazo" aparece também com a lista vazia (junto do botão do `EmptyState`); some só nos estados de erro/ausência, que usam outro `Scaffold`.
- O formulário carrega empresa e prazo pelo repositório (`findById`) no `initState`, como o de empresa; o que faltar vira o enum `_Missing` (módulo, empresa, prazo) com a mensagem certa.

**Pendente / dúvidas**
- Durante esta etapa o verificador automático de comandos do ambiente ficou sem resposta várias vezes seguidas, então `flutter analyze`/`flutter test` ainda não rodaram sobre os passos 3 a 6. Próximo: rodar, corrigir, escrever `module_screen_test.dart`, `deadline_form_screen_test.dart` e os casos novos de `company_detail_screen_test.dart`, depois commitar por passo.

## 2026-09-30 — Testes de tela, bug de stream e verificação no emulador

**Feito**
- Verificador de comandos voltou: `flutter analyze` limpo e suíte verde. Passos 3 e 4 commitados; testes de tela escritos (`module_screen_test`, `deadline_form_screen_test`, pendências em `company_detail_screen_test`) e passos 5 e 6 commitados.
- `SectionCard`: com legenda, o título fica no tamanho natural e a legenda quebra linha (antes estourava 48 px com "Alertas a partir de …" na fonte de teste; em tela estreita também poderia).
- Teste de descarte: faltava `pump()` entre `enterText` e o toque em "Fechar" (o quadro que marca o formulário como alterado não tinha rodado). O app estava certo.
- **Bug achado no emulador e corrigido:** depois de salvar um prazo, a tela do módulo e o detalhe da empresa não atualizavam. Causa: o drift identifica streams por SQL e variáveis (`StreamKey`), sem olhar `readsFrom`; os dois repositórios usavam `SELECT 1` como consulta-gatilho, e com a stream de empresas aberta a de prazos reaproveitava a dela e não via gravações em `deadlines`. Correção: SQL único por repositório (`SELECT 1 AS companies_changed`, `SELECT 1 AS deadlines_changed`), regra registrada em D008 e teste de regressão em `local_deadline_repository_test.dart` (falha sem a correção). Reproduzido antes num teste de widget com drift em memória.
- Emulador (Medium_Phone, APK debug): Painel e módulo vazio com `EmptyState` em card (tonal visível); empresa → Ambiental → Novo prazo; categoria na faixa; lembretes padrão com datas (31/10/2026 → alertas a partir de 03/06/2026); sheet com atalhos sem os existentes e "Aviso em 01/09/2026" para 60 dias; salvar volta ao módulo com o card; seções Licenças → Laudos → Manutenções com "Vence hoje/em n dias"; editar pelo card; detalhe da empresa com "3 a vencer". Sem erros no log.

**Decidido**
- Ao iniciar a verificação limpei os dados do app no emulador (`pm clear`), o que apagou a empresa de teste que estava lá. Cadastrei outra ("Alfa").

**Pendente / dúvidas**
- Acessibilidade: no card de lembretes, os títulos das linhas sem ação (`NavRow` sem `onTap`) aparecem juntos num nó só para o leitor de tela; os botões de remover ficam separados. Vale revisar `NavRow`/`SectionCard` numa task de acessibilidade.

## 2026-09-30 — Task concluída

**Feito**
- Critérios de aceite marcados. `dart format .`, `flutter analyze` sem issues, `flutter test` com 246 testes verdes.
- `docs/07-design-system.md`: `DeadlineCard` ✅ com as regras de texto e ano, `BandSegmentedButton`, `FieldErrorText`, `EmptyState` em card, `helperText`, `noneLabel`, cor `onBandSegment`, telas Módulo, Novo prazo e Lembrete. `docs/05-roadmap.md`: item de prazos atualizado. `docs/decisoes.md`: D008 com a regra do SQL-gatilho.
- Status → `concluída` aqui e no índice.

**Como verificar**
```bash
dart format . && flutter analyze && flutter test
flutter build apk --debug   # e no emulador: empresa → módulo → Novo prazo → salvar → editar
```

**Próximo:** task 008 (detalhe, histórico e renovação). Antes, levar à cliente C21 e o "Nº do documento" (C5/C13).

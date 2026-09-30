# 007 — Prazos: tela do módulo e cadastro

| | |
|---|---|
| **Status** | em andamento |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-01, RF-PRZ-02 · RF-AMB-01, RF-AMB-05, RF-AMB-06, RF-PCT-01 · RF-EMP-03 (pendências por módulo) |
| **Depende de** | 006 (concluída) |
| **Wireframe** | [ModuloAmbiental](../../docs/design/wireframes/ModuloAmbiental.dc.html) · [PrazoForm](../../docs/design/wireframes/PrazoForm.dc.html) (atualizado com a lista de lembretes) · [PrazoLembrete](../../docs/design/wireframes/PrazoLembrete.dc.html) |

## Objetivo

A usuária abre um módulo habilitado a partir do detalhe da empresa, vê os prazos em aberto daquele módulo agrupados por categoria e cadastra ou edita um prazo com categoria, título, órgão, vencimento e lembretes.

## Escopo

- **Tela do módulo** (qualquer um dos três módulos), aberta pela linha do módulo no detalhe da empresa:
  - Faixa de cabeçalho com o nome do módulo e a empresa. **Sem abas**: só prazos (Lançamentos e Relatórios entram nas fases 2 e 3).
  - Prazos em aberto agrupados **por categoria** (Licenças, Laudos, Manutenções), cada seção por vencimento; seção vazia não aparece.
  - Cada prazo num `DeadlineCard`; tocar **abre a edição** (na task 008 passa a abrir o detalhe).
  - Ação "Novo prazo". Sem prazos: `EmptyState` com a ação de cadastrar.
- **Formulário de novo prazo e edição**: categoria, título, órgão (opcional), vencimento e **lista livre de lembretes**.
  - A lista vem com o padrão da categoria; cada lembrete pode ser removido; "Adicionar lembrete" abre um **bottom sheet** com campo de dias e atalhos (60, 30, 15, 7, 1, No dia).
  - Mostra a data calculada do primeiro alerta ("Alertas a partir de …").
  - Trocar a categoria num prazo novo repõe os lembretes padrão, se a usuária ainda não mexeu neles.
- **Componente `DeadlineCard`** em `lib/app/widgets/` (genérico, com teste): bloco de data na cor forte da situação, título, linha de contexto e texto relativo.
- **`EmptyState` dentro de card** (resolve a pendência da task 005: o botão tonal some sobre o fundo tingido). Vale para todas as telas que usam o componente.
- **Pendências no detalhe da empresa** (RF-EMP-03): a linha de cada módulo mostra a pior situação dos prazos em aberto com a contagem (ex.: "1 vencido") em `StatusText`; nada quando tudo está vigente.
- Componentes novos ou estendidos: `BandSegmentedButton` (categoria na faixa), `FieldErrorText`, `AppTextField.helperText`, `AppDropdownField.noneLabel`.

## Fora de escopo

- Detalhe do prazo, histórico e ações de renovar, concluir, cancelar e excluir (task 008).
- Prazos concluídos, cancelados e renovados na tela do módulo (entram com o detalhe/histórico, task 008).
- Painel (task 009) e notificações (task 010).
- Abas de Lançamentos e Relatórios; agrupamento por estação ETE/ETA (Fase 2).

## Critérios de aceite

- [ ] No detalhe da empresa, cada módulo abre a tela do módulo e mostra a pior situação dos prazos em aberto ("1 vencido", "2 a vencer"); nada quando só há vigentes.
- [ ] A tela do módulo lista os prazos em aberto em seções Licenças → Laudos → Manutenções (sem seção vazia), por vencimento, com `DeadlineCard` (bloco de data na cor da situação, título, categoria · órgão e texto relativo). Estados: vazio com "Cadastrar prazo", módulo desligado, empresa ou módulo inexistente.
- [ ] "Novo prazo" (FAB) e o toque num prazo abrem o formulário de criação e de edição.
- [ ] O formulário tem a categoria na faixa, título*, órgão (opcional), vencimento* e a lista de lembretes com a data de cada um e "Alertas a partir de …". A lista vem do padrão da categoria e é reposta ao trocar de categoria enquanto não foi editada.
- [ ] O sheet "Adicionar lembrete" tem atalhos (sem os que já estão na lista), campo de dias com a data do aviso, 0 = no dia, e recusa repetido ou vazio.
- [ ] Salvar valida (título, vencimento, ao menos um lembrete), rola até o erro, grava pelo repositório e volta com "Prazo salvo"; fechar com alterações pede confirmação.
- [ ] `DeadlineCard`, `BandSegmentedButton` e `FieldErrorText` em `lib/app/widgets/` com teste; `EmptyState` dentro de card; `docs/07-design-system.md` atualizado.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Para quem vai implementar

Comece pelo [plano](plan.md): ele é autocontido (rotas, componentes, regras de texto, estados, testes e como verificar). Depois leia o fim do [journal](journal.md).

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

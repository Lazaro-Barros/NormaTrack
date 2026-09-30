# 007 — Prazos: tela do módulo e cadastro

| | |
|---|---|
| **Status** | rascunho |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-01, RF-PRZ-02 · RF-AMB-01, RF-AMB-05, RF-AMB-06, RF-PCT-01 · RF-EMP-03 (pendências por módulo) |
| **Depende de** | 006 (concluída) |
| **Wireframe** | [ModuloAmbiental](../../docs/design/wireframes/ModuloAmbiental.dc.html) · [PrazoForm](../../docs/design/wireframes/PrazoForm.dc.html) (a lista de lembretes muda o formulário: ver [protótipo](prototypes/)) |

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
- Protótipo do formulário aprovado vira o wireframe oficial (`docs/design/wireframes/PrazoForm.dc.html`).

## Fora de escopo

- Detalhe do prazo, histórico e ações de renovar, concluir, cancelar e excluir (task 008).
- Prazos concluídos, cancelados e renovados na tela do módulo (entram com o detalhe/histórico, task 008).
- Painel (task 009) e notificações (task 010).
- Abas de Lançamentos e Relatórios; agrupamento por estação ETE/ETA (Fase 2).

## Critérios de aceite

- [ ] A definir no plano, depois da aprovação do protótipo.
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

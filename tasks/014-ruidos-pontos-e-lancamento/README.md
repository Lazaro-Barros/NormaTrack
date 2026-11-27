# 014 — Ruídos: pontos de medição e lançamento semanal

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 2 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-AMB-02 |
| **Depende de** | 013 (parâmetros e medições) |
| **Wireframe** | [Lancamento.dc.html](../../docs/design/wireframes/Lancamento.dc.html) (a atualizar nesta task) e [ModuloAmbiental.dc.html](../../docs/design/wireframes/ModuloAmbiental.dc.html) |

## Objetivo

O usuário cadastra os pontos de medição de ruído de uma empresa e lança, semana a semana, o valor medido em cada ponto (dB(A)), vendo o valor anterior, o aviso "Acima do limite" e a situação da semana. Pode marcar "sem medição" na semana inteira ou num ponto, com motivo. No módulo Ambiental, a linha "Ruídos" mostra se está em dia, a lançar ou atrasado.

## Escopo

- Módulo Ambiental (aberto): seção "Automonitoramento" no topo da lista, com a linha "Ruídos" e a situação à direita.
- Tela "Ruídos" (lançamento semanal): navegação entre semanas na faixa, um campo por ponto com o valor anterior, limite, "sem medição" por ponto e para a semana, e "Salvar".
- Tela "Pontos de medição": lista dos pontos ativos e desativados; sheet para cadastrar e editar (nome, limite máximo), desativar, reativar e excluir.
- Componentes novos em `lib/app/widgets/`: `PeriodNavigator` e `MeasurementInputRow`; formatador `DecimalInputFormatter`.
- Wireframes atualizados (`Lancamento`, novo `PontosMedicao`) e `docs/07-design-system.md`.

## Fora de escopo

- Pendências no Painel e `PendingRow` (task 015).
- Reordenar pontos pela tela (a ordem é a de cadastro; o repositório já aceita `reorderParameters`).
- Observação livre junto de um valor (o banco aceita; a tela preserva a que existir).
- Data de início editável do ponto (é o dia do cadastro).
- ETE/ETA (017) e relatório (018).

## Critérios de aceite

- [ ] Módulo Ambiental mostra "Automonitoramento › Ruídos" com subtítulo (pontos) e situação ("Em dia", "A lançar", "n semanas atrasadas" ou "Nenhum ponto cadastrado"); tocar abre a semana pendente mais antiga, ou a atual.
- [ ] Pontos: cadastrar (nome obrigatório, sem repetir; limite máximo opcional), editar, desativar/reativar e excluir com confirmação; desativado não aparece no lançamento nem cobra.
- [ ] Lançamento: semana ISO na faixa ("Semana 48", "23 a 29/11/2026"), anterior/próxima, sem avançar além da semana atual; valor anterior por ponto; contador "n de m".
- [ ] Valor com vírgula e uma casa decimal; acima do limite mostra ícone e "Acima do limite (70,0)" enquanto digita.
- [ ] "Sem medição" por ponto e "Sem medição nesta semana" (só nos pontos vazios), com motivo obrigatório e "Desfazer" antes de salvar.
- [ ] "Salvar" grava o que mudou (parcial permitido; campo apagado remove a medição); trocar de semana ou sair com alterações pede confirmação.
- [ ] Componentes novos com teste e no design system; sem cor, fonte ou espaço solto.
- [ ] Conferido no emulador (sem perder os dados de teste); `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Links

- [Plano técnico](plan.md) (ponto de partida para implementar) · [Journal](journal.md) · [Protótipos](prototypes/)

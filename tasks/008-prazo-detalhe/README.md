# 008 — Prazos: detalhe, histórico e renovação

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-01, RF-PRZ-04 · RF-AMB-06 |
| **Depende de** | 006, 007 (concluídas) |
| **Wireframe** | [PrazoDetalhe](../../docs/design/wireframes/PrazoDetalhe.dc.html) (ajustado nesta refinação: sem "Nº do documento"; lembretes no lugar de "Alerta"; ciclo mais antigo sem data de início) |

## Objetivo

A usuária abre um prazo, vê a situação em destaque, os dados e o histórico de ciclos, e registra a renovação, a conclusão (laudo e manutenção), o cancelamento ou a exclusão. Também chega aos prazos encerrados (concluídos e cancelados) para reabri-los.

## Escopo

- **Tela de detalhe do prazo** (rota nova, aberta ao tocar num prazo da tela do módulo):
  - Faixa de cabeçalho com o título do prazo, "Empresa · Módulo", menu ⋮ e, abaixo, o `StatusBanner` (bloco de data na cor da situação, texto da situação e "Alertas desde …").
  - Card de dados: categoria, órgão (só se houver) e uma linha por lembrete com a data do aviso.
  - Seção "Histórico": ciclos do mais novo para o mais antigo, cada um com intervalo e `StatusChip`.
- **Ações** (cada uma chama o `DeadlineRepository`, que já as implementa):
  - Em aberto, licença: botão primário **Registrar renovação** (sheet com data sugerida).
  - Em aberto, laudo ou manutenção: primário **Concluir** (sheet com a data de conclusão); **Registrar renovação** passa para o menu.
  - Em aberto: **Cancelar prazo** no menu, com confirmação.
  - Concluído ou cancelado: primário **Reabrir** (sem confirmação, é desfazer).
  - **Excluir prazo** no menu (em aberto, concluído ou cancelado), com confirmação destrutiva que avisa quando isso reabre o ciclo anterior.
  - **Editar** (já existe o formulário) no rodapé, ao lado do primário.
  - Renovado: somente leitura (sem barra de ações e sem menu).
- **Tela do módulo:** segmentado "Em aberto | Encerrados" na faixa. Encerrados lista concluídos e cancelados; tocar em qualquer prazo abre o detalhe (o toque deixa de abrir a edição).
- **Componentes** em `lib/app/widgets/`: `StatusBanner` e `DateBlock` (extraído do `DeadlineCard`); `StatusChip` ganha ícone opcional; `showConfirmDialog` ganha `dismissLabel`.

## Fora de escopo

- Cadastro e lista (task 007) e painel (task 009).
- "Nº do documento" no prazo (C5/C13): não entra no modelo nem na tela.
- Data de emissão/início própria do ciclo (C21): o início de um ciclo é o vencimento do anterior; o mais antigo não tem início.
- Anexos (C13), notificações (task 010).
- Desfazer pelo SnackBar, filtros e busca nos encerrados.

## Critérios de aceite

- [ ] Tocar num prazo na tela do módulo abre o detalhe: faixa com `StatusBanner` (data, "Venceu há 3 dias" / "Vence em 10 dias" / "Em 120 dias" / "Concluído em …", "Alertas desde …" ou "a partir de …"), card com categoria, órgão e lembretes, e o histórico de ciclos com `StatusChip` em cada um. Estados: carregando, erro e prazo, empresa ou módulo inexistente.
- [ ] **Registrar renovação** abre o sheet com a data sugerida (mesmo intervalo do ciclo anterior em meses; sem anterior, +1 ano) editável, sem aceitar data até o vencimento atual; confirmar encerra o ciclo, abre o próximo, mostra "Prazo renovado" e navega para o detalhe do novo ciclo, em que o histórico traz o anterior como "Renovado".
- [ ] **Concluir** (só laudo e manutenção, primário nesses casos) pede "Concluído em" (padrão hoje, nunca no futuro); o prazo vira "Concluído" e a barra passa a mostrar **Reabrir**.
- [ ] **Cancelar prazo** pede confirmação (botões "Voltar" e "Cancelar prazo"); **Reabrir** volta o prazo a em aberto sem confirmação.
- [ ] **Excluir prazo** pede confirmação destrutiva; avisa "O ciclo anterior volta a ficar em aberto" quando for o caso; depois volta ao módulo com "Prazo excluído".
- [ ] A tela do módulo tem "Em aberto | Encerrados"; Encerrados lista concluídos e cancelados (mais recente primeiro) com o estado vazio "Nenhum prazo encerrado", e tocar abre o detalhe.
- [ ] `StatusBanner` e `DateBlock` com teste e documentados em `docs/07-design-system.md` (tela Detalhe do prazo, ícones de concluído e cancelado, regra do "Nº do documento").
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Para quem vai implementar

Comece pelo [plano técnico](plan.md): ele traz contexto do repositório, ordem de implementação, rotas, textos exatos, regras e testes por arquivo.

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

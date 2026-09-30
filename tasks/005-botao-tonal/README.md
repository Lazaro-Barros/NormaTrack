# 005 — Botão tonal com as cores do design system

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RNF-06 |
| **Depende de** | [001](../001-design-system-e-tema/), [004](../004-refinamento-visual/) |
| **Wireframe** | [DS-Componentes](../../docs/design/wireframes/DS-Componentes.dc.html) (botão tonal "Gerar relatório"/"Lançar") |

> **Para implementar, comece pelo [plano técnico](plan.md).**

## Objetivo

O `FilledButton.tonal` (ação secundária de destaque) aparece com fundo petróleo claro e texto petróleo, como nos wireframes, e não mais igual ao botão primário. Hoje a ação do `EmptyState` ("Ver empresas", "Cadastrar empresa") parece um segundo botão primário na tela.

## Escopo

- `AppTheme`: `filledButtonTheme` sem cores fixas, para cada variante usar a cor do `ColorScheme`; `onSecondaryContainer` passa a `primary`.
- Testes das cores das duas variantes e do contraste do tonal.
- `docs/07-design-system.md`: cores do botão tonal.

## Fora de escopo

- Outros componentes e telas. O único uso de `FilledButton.tonal` hoje é o `EmptyState`.
- O botão "Gerar relatório" do detalhe da empresa (`TODO(RF-REL-01)`).

## Critérios de aceite

- [x] `FilledButton` continua petróleo (`primary`) com texto branco
- [x] `FilledButton.tonal` tem fundo `primarySoft` e texto `primary`, com contraste de pelo menos 4,5:1 (teste)
- [x] Botões desabilitados continuam com a aparência padrão de desabilitado
- [x] `docs/07-design-system.md` descreve as cores do tonal
- [x] Conferido no emulador (ação do `EmptyState` no Painel; ver journal)
- [x] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

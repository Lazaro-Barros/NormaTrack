# Plano técnico — 005

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código.

## Abordagem

O `FilledButtonThemeData` tem um único `style`, aplicado às duas variantes (`FilledButton` e `FilledButton.tonal`). Hoje ele fixa `backgroundColor: AppColors.primary` e `foregroundColor: AppColors.onPrimary`, então o tonal sai igual ao primário. A correção tira as cores desse `style` e deixa cada variante usar os padrões do Material 3, que já leem o `ColorScheme`:

| Variante | Fundo (padrão M3) | Texto (padrão M3) | Valor no app |
|---|---|---|---|
| `FilledButton` | `colorScheme.primary` | `colorScheme.onPrimary` | `#0E5A63` / `#FFFFFF` (igual a hoje) |
| `FilledButton.tonal` | `colorScheme.secondaryContainer` | `colorScheme.onSecondaryContainer` | `#DCEBEA` (`primarySoft`) / `#0E5A63` (`primary`) |

`secondaryContainer` já é `primarySoft`, o mesmo valor de `primaryContainer`. `onSecondaryContainer` muda de `primaryStrong` (`#0A434A`) para `primary` (`#0E5A63`), que é a cor do texto do botão tonal nos wireframes (`DS-Componentes`, `EmpresaDetalhe`, `Main`: fundo `#DCEBEA`, texto `#0E5A63`).

## Contexto do repositório (em 2026-09-30)

- Flutter 3.47.5. Conferido em `packages/flutter/lib/src/material/filled_button.dart`: `defaultStyleOf` escolhe `_FilledButtonDefaultsM3` ou `_FilledTonalButtonDefaultsM3` pela variante; `themeStyleOf` devolve `FilledButtonTheme.of(context).style` para as duas. O tonal usa `secondaryContainer`/`onSecondaryContainer` (desabilitado: `onSurface` com 12% e 38%).
- `onSecondaryContainer` só é lido, no app, pelo tonal. `NavigationBar` (ícone selecionado) e `SegmentedButton` (texto selecionado) também o usariam por padrão, mas o `AppTheme` já sobrescreve os dois com `AppColors.primary`/`onPrimary`. Não há `Chip` selecionável, `IconButton.filledTonal` nem `NavigationRail` no app.
- Único uso de `FilledButton.tonal`: `lib/app/widgets/empty_state.dart`.

## Ordem de implementação

Branch `task/005-botao-tonal`, a partir da `main`.

1. `docs(design)`: task criada (README, plan, journal, índice) com status `planejada`.
2. `fix(design)`: status `em andamento`; tema, testes e `docs/07-design-system.md`; conferir no emulador; critérios, journal final, status `concluída` no README e no índice. Commit `fix(design): botão tonal com primarySoft e texto primary [task 005, RNF-06]`.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| theme | `lib/app/theme/app_theme.dart` | `onSecondaryContainer: AppColors.primary`; `filledButtonTheme` sem `backgroundColor`/`foregroundColor` (mantém `minimumSize`, `padding`, `shape`, `textStyle`) |
| test | `test/app/theme/app_theme_test.dart` | testes abaixo |
| docs | `docs/07-design-system.md` | tabela de cores e linha "Botões" |

## Testes

Em `test/app/theme/app_theme_test.dart`:

- Contraste `AppColors.primary` sobre `AppColors.primarySoft` ≥ 4,5:1.
- Widget: `FilledButton` e `FilledButton.tonal` habilitados, dentro de `MaterialApp(theme: AppTheme.light)`. A `Material` descendente de cada um tem `color` `primary` e `primarySoft`; o `Text` usa `onPrimary` e `primary` (via `DefaultTextStyle`/`IconTheme` do botão: ler `tester.widget<Material>(...).textStyle?.color`).
- Widget: `FilledButton.tonal(onPressed: null)` não usa `primarySoft` (fica com a cor padrão de desabilitado).

## Docs a atualizar

`docs/07-design-system.md`:
- Tabela de cores: `primarySoft` também é `secondaryContainer` (fundo do botão tonal); `primary` também é `onSecondaryContainer` (texto do tonal).
- Linha "Botões": `FilledButton.tonal` com fundo `primarySoft` e texto `primary`.

## Como verificar

```bash
dart format . && flutter analyze && flutter test
grep -n "backgroundColor\|foregroundColor" lib/app/theme/app_theme.dart   # o bloco filledButtonTheme não aparece
flutter run   # Painel: "Ver empresas" em petróleo claro; Empresas vazia: "Cadastrar empresa" idem
```

## Riscos e alternativas

- *Descartado:* estilo local (`style:`) no `EmptyState`. Cada novo tonal teria que repetir e esquecer; o problema está no tema.
- *Descartado:* manter `onSecondaryContainer = primaryStrong`. Contraste até maior, mas diverge da cor do texto nos wireframes, e `primaryStrong` é documentado como estado pressionado.
- Se um componente futuro usar `onSecondaryContainer` (chip selecionável, `IconButton.filledTonal`), ele herda `primary`, coerente com o resto do app.

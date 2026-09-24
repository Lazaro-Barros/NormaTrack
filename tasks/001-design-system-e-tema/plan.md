# Plano técnico — 001

## Abordagem

Tokens definidos uma vez em `lib/app/theme/` e aplicados via `ThemeData` do Material 3, para que as telas usem os widgets Material padrão sem sobrescrever estilo. A situação de prazo, que não existe no `ColorScheme`, vira uma `ThemeExtension`.

## Arquivos e camadas

| Camada | Arquivo | Mudança |
|---|---|---|
| app | `lib/app/theme/app_colors.dart` | Paleta (marca, neutros, situação) |
| app | `lib/app/theme/app_typography.dart` | `TextTheme`, `overline`, `number`, `tabular()` |
| app | `lib/app/theme/app_spacing.dart` | `AppSpacing`, `AppRadius` |
| app | `lib/app/theme/status_colors.dart` | `StatusTone`, `StatusColors` (`ThemeExtension`) |
| app | `lib/app/theme/app_theme.dart` | `AppTheme.light` com temas de todos os componentes Material usados |
| app | `lib/app/widgets/status_chip.dart` | `StatusChip` |
| — | `lib/main.dart` | `NormaTrackApp` com o tema; tela provisória |

## Interface

Fonte da verdade: [`docs/07-design-system.md`](../../docs/07-design-system.md). Wireframes: [`docs/design/wireframes/`](../../docs/design/wireframes/).

## Testes

- `test/app/theme/app_theme_test.dart`: cores do tema, extensão registrada, contraste ≥ 4,5:1, `StatusChip` com ícone e cor.
- `test/widget_test.dart`: app abre com o tema.

## Riscos e alternativas

- Fontes via pacote `google_fonts` descartado: baixa em tempo de execução, e o app é offline (RNF-01). Fontes serão embarcadas como asset.
- `StatusTone` fica na camada de apresentação para não acoplar o domínio ao tema; o domínio calcula a situação e a UI converte.

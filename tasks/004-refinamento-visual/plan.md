# Plano técnico — 004

## Abordagem

Aplicar a proposta A em três lugares, nesta ordem: wireframes (canvas + `docs/design/wireframes/`), documento do design system (v0.2) e tema Flutter. Nenhuma tela de feature existe ainda, então a mudança no código fica restrita a `lib/app/theme/`.

## Arquivos

| Camada | Arquivo | Mudança |
|---|---|---|
| app | `lib/app/theme/app_colors.dart` | `ground` #E6EFEE, `surface2` #EDF2F1, `border` → `divider` #E1E8E7, `borderStrong` #7F8B8A, `ink3` #5E666B; novos `onBandMuted`, `placeholder`, `switchOff`; `closedBg` #E9ECEB |
| app | `lib/app/theme/app_spacing.dart` | `AppRadius.xl` (24), `xlAll`, `band` (só cantos inferiores) |
| app | `lib/app/theme/app_typography.dart` | `titleLarge` 22/28 w800 (faixa), `titleMedium` 16/22 (seção); remove `overline` |
| app | `lib/app/theme/app_theme.dart` | `AppBar` = faixa petróleo; cards sem borda; segmentado pill com selecionado em `primary`; sheet/diálogo raio 24 |
| test | `test/app/theme/app_theme_test.dart` | contraste: `onBandMuted` na faixa, branco sobre cores fortes de situação, borda de campo ≥ 3:1, placeholder; faixa e card da v0.2 |
| docs | `docs/07-design-system.md`, `docs/design/wireframes/*`, `CLAUDE.md` | v0.2 |

## Riscos e alternativas

- `NavigationBar` do Material não aceita cantos arredondados pelo tema; a barra branca com cantos superiores de 20 do wireframe exige um wrapper (`ClipRRect`) quando a navegação for implementada (task 003).
- Faixa com bloco extra (números, busca, abas) não cabe no `AppBar` padrão; criar `AppHeaderBand` quando a primeira tela precisar.
- *Descartado:* proposta B (cor por módulo) — mais cor, mas mais um código de cor para aprender; pode voltar depois sem conflito, porque não usa as cores de situação.

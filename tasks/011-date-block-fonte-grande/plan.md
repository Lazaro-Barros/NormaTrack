# Plano técnico — 011

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Não há regra de negócio nova; nenhuma suposição **[suposição]**.

## Abordagem

A mesma solução do `StatTile` (task 009, commit 4c16838): dentro do componente, a escala do texto do sistema é limitada (`MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5)`) e o tamanho do componente é calculado pela escala, linha a linha: `scaler.scale(fontSize) * height`, arredondado para cima com `ceilToDouble()`. Escala-se o `fontSize`, não a altura da linha, porque no Android 14+ a escala não é linear (fontes pequenas crescem proporcionalmente mais), e arredonda-se cada linha porque o `TextPainter` arredonda a altura do parágrafo para cima.

## Contexto do repositório (em 2026-11-26)

- Flutter em `/opt/homebrew/bin/flutter`; `adb` em `~/Library/Android/sdk/platform-tools/adb` (fora do PATH). Emulador `Medium_Phone_API_37.0` (`emulator-5554`), `font_scale` original **1.0**.
- Commits direto na `main`, com push, sem branch nem PR ([D012](../../docs/decisoes.md#d012--commits-direto-na-main-sem-pr)). A task começou numa branch `task/011-date-block-fonte-grande`, trazida para a `main` por fast-forward (ver journal).
- `DateBlock` (task 001): `Container` 48 × 52 com `Column` centralizada: dia em `titleLarge` (22/28) tabular e mês (com ano de 2 dígitos se `showYear`) em `labelSmall` (12/16) tabular. Na escala 1: 28 + 16 = 44 de texto, 8 de folga. O dia não tem `maxLines`: com a fonte de teste (cada glifo é um quadrado do tamanho da fonte), "05" a 1,3× mede 57 > 48 e quebra em duas linhas.
- Medido no emulador (task 009): estouro de 1 px em 1,3× e 25 px em 2× (o mês some).
- `StatusBanner`: `Container` de altura fixa 76 (`StatusBanner.height`), padding `md` (12), `DateBlock` + coluna com título (`titleLarge`) e mensagem (`bodyMedium`, 13/18). Usado só em `deadline_detail_screen.dart`, no `AppBar.bottom` com `StatusBanner.height + AppSpacing.lg`.
- `DeadlineCard`: `ConstrainedBox(minHeight: 68)`; a altura acompanha o conteúdo, então só precisa do `DateBlock` correto.
- `StatTile` (task 009) já tem `maxTextScale = 1.5`, `heightOf(context)` e um teste com `_NonLinearScaler` (`test/app/widgets/stat_tile_test.dart`) que soma 4 a todo tamanho de fonte.
- Armadilha: `TextScaler.clamp` do `_NonLinearScaler` devolve ele mesmo (sem limite); os valores esperados no teste não linear não passam pelo limite.

## Ordem de implementação

1. Docs da task (este plano, README, journal, índice). Commit `docs(design-system): task 011 …`.
2. `AppTypography.lineHeight` + refatorar `StatTile` para usá-lo; `DateBlock`, `StatusBanner`, detalhe do prazo; testes. Commit `fix(design-system): DateBlock e StatusBanner crescem com a fonte do sistema [task 011, RNF-06]`.
3. Conferir no emulador em 1,3× e 2×; voltar `font_scale` para 1.0.
4. `docs/07-design-system.md`, journal, status `concluída` no README e no índice. Commit `docs(design-system): fechamento da task 011 [task 011, RNF-06]`. `git push origin main`.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| tema | `lib/app/theme/app_typography.dart` | `static double lineHeight(TextStyle? style, TextScaler scaler)` |
| widget | `lib/app/widgets/date_block.dart` | `width`, `height`, `maxTextScale`, `scalerOf`, `sizeOf`; build com escala limitada |
| widget | `lib/app/widgets/status_banner.dart` | `heightOf(context)`; build com escala limitada |
| widget | `lib/app/widgets/stat_tile.dart` | usa `AppTypography.lineHeight` (sem mudança de comportamento) |
| presentation | `lib/features/deadlines/presentation/deadline_detail_screen.dart` | `AppBar.bottom` com `StatusBanner.heightOf(context)` |

## Domínio e contratos

```dart
// AppTypography
/// Altura de uma linha de [style] na escala [scaler], arredondada para cima
/// como o TextPainter faz. Sem tamanho/altura no estilo: 14 e 1,2.
static double lineHeight(TextStyle? style, TextScaler scaler) =>
    (scaler.scale(style?.fontSize ?? 14) * (style?.height ?? 1.2)).ceilToDouble();

// DateBlock
static const double width = AppSpacing.minTouch;   // 48 na escala 1
static const double height = 52;                    // na escala 1
static const double maxTextScale = 1.5;
static TextScaler scalerOf(BuildContext context);   // escala do sistema limitada
static Size sizeOf(BuildContext context);           // tamanho na escala de context

// StatusBanner
static const double height = 76;                     // na escala 1
static double heightOf(BuildContext context);        // para o AppBar.bottom
```

## Regras de implementação

- **Altura do `DateBlock`:** `(height − 28 − 16)` (folga 8, constante) `+ lineHeight(titleLarge) + lineHeight(labelSmall)`. Na escala 1 dá 52.
- **Largura do `DateBlock`:** cresce na proporção do mês (o texto mais largo e o que mais cresce na escala não linear): `max(48, (48 × scale(12) / 12).ceil())`, com 12 = `labelSmall.fontSize`. Na escala 1 dá 48; em 1,5× dá 72.
- Dia e mês com `maxLines: 1` e `softWrap: false`: nunca quebram linha.
- **`StatusBanner.heightOf`:** `2 × md + max(DateBlock.sizeOf(context).height, lineHeight(titleLarge) + lineHeight(bodyMedium))`, com a escala do `DateBlock.scalerOf`. Conta sempre a linha da mensagem (altura igual com e sem mensagem, como hoje). Na escala 1: 24 + max(52, 46) = 76.
- O `StatusBanner` aplica a escala limitada à sua subárvore (`MediaQuery(... textScaler: scaler)`), como o `StatTile`. O `DateBlock` dentro dele limita de novo (idempotente).
- O `DeadlineCard` não muda: título, contexto e texto relativo seguem a escala do sistema sem limite (a altura do card acompanha).

## Interface

Sem tela nova. Na escala 1 nada muda visualmente. Com fonte grande, o bloco de data e o banner crescem até 1,5×.

## Testes

Valores conferidos com a fórmula acima (linhas arredondadas para cima).

| Arquivo | Cobre |
|---|---|
| `test/app/widgets/date_block_test.dart` | 48 × 52 na escala 1; 1,3× → 63 × 66 (dia 28,6 × 28/22 = 36,4 → 37; mês 15,6 × 16/12 = 20,8 → 21); 2× limitado a 1,5× → 72 × 74 (42 + 24); não linear (+4) → 64 × 64 (dia 26 × 28/22 = 33,1 → 34; mês 16 × 16/12 = 21,3 → 22); sem exceção em todos; dia não quebra linha |
| `test/app/widgets/status_banner_test.dart` | 76 na escala 1; `heightOf` igual à altura renderizada; 1,3× → 90; 2× → 98; não linear → 88; sem exceção |
| `test/app/widgets/deadline_card_test.dart` | 1,3×, 2× e não linear, com `showYear`, em largura de celular (411 − 32), sem exceção |
| `test/app/widgets/stat_tile_test.dart` | inalterado (garante a refatoração) |

O `_NonLinearScaler` é duplicado em cada teste que precisa (classe privada, 15 linhas) ou movido para `test/helpers/`. Decisão: mover para `test/helpers/text_scalers.dart` como `NonLinearScaler`, usado pelos quatro testes.

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` e `flutter test` sem erros.
- Emulador: `adb shell settings put system font_scale 1.3`, depois `2.0`; abrir Painel, módulo Ambiental e detalhe de um prazo vencido e de um com ano diferente (`showYear`) com `flutter run -d emulator-5554 -t tasks/009-painel-vencimentos/prototypes/seed_main.dart`. Sem faixa de overflow nem erro "RenderFlex overflowed" no log. Voltar com `adb shell settings put system font_scale 1.0`.

## Riscos e alternativas

- *Descartado:* `FittedBox(fit: BoxFit.scaleDown)` no texto do bloco. Encolheria o texto que o usuário pediu maior, sem o bloco crescer.
- *Descartado:* largura fixa 48 com escala limitada. "SET 28" em 1,3× já não cabe em 48 com a fonte padrão.
- *Descartado:* deixar o bloco sem altura (só padding). Os blocos de uma lista ficariam com tamanhos diferentes conforme o texto e o banner precisa de altura conhecida no `AppBar.bottom`.

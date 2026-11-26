# Journal — 011

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-26 — Task criada e planejada

**Feito**
- Task criada a partir da pendência registrada no journal da 009 (entrada "Emulador, fonte grande e fechamento"): o `DateBlock` estoura 1 px em 1,3× e 25 px em 2× com a fonte do sistema no `Medium_Phone_API_37.0`.
- Branch `task/011-date-block-fonte-grande` a partir de `task/009-painel-vencimentos` (a 009 ainda não está na `main`).
- `font_scale` original do emulador: 1.0.

**Decidido**
- Mesma solução do `StatTile`: escala limitada a 1,5× e tamanho calculado por linha (`ceil`). O `StatusBanner` ganha `heightOf(context)` para o `AppBar.bottom` do detalhe do prazo.
- O bloco também cresce em largura, na proporção do mês — "SET 28" não cabe em 48 com fonte grande. Alternativa descartada: `FittedBox` (encolheria o texto).
- Helper `AppTypography.lineHeight` para não repetir a conta nos três componentes; o `_NonLinearScaler` do teste do `StatTile` vai para `test/helpers/`.

## 2026-11-26 — Implementação, emulador e fechamento

**Feito**
- `AppTypography.lineHeight(style, scaler)`: altura de uma linha escalada (`scale(fontSize) × height`, `ceil`). O `StatTile` passou a usá-lo (mesmo resultado; testes dele inalterados).
- `DateBlock`: `width` 48, `height` 52, `maxTextScale` 1,5, `scalerOf(context)`, `sizeOf(context)`. A subárvore usa a escala limitada; dia e mês com `maxLines: 1` e `softWrap: false`.
- `StatusBanner.heightOf(context)` = 24 + max(altura do bloco, título + mensagem), com a escala limitada também no título e na mensagem. O detalhe do prazo usa `heightOf` no `AppBar.bottom`.
- `NonLinearScaler` movido para `test/helpers/text_scalers.dart` (com `withTextScaler`), usado por `StatTile`, `DateBlock`, `StatusBanner` e `DeadlineCard`.
- Testes: `DateBlock` (48 × 52; 1,3× → 63 × 66; 2× → 72 × 74; não linear → 64 × 64; `sizeOf` = renderizado), `StatusBanner` (76; 90; 98; 88; `heightOf` = renderizado) e `DeadlineCard` (1,3×, 2× e não linear numa largura de 379), todos sem exceção.
- Emulador `Medium_Phone_API_37.0` com o seed da 009, em `font_scale` 1,3 e 2,0: Painel, módulo Ambiental e detalhe de prazo com ano diferente ("JAN 27"). Sem faixa de overflow e nenhum "overflowed" no log do `flutter run`. Em 2× o bloco fica em 72 de largura e "MAI 27" cabe. `font_scale` de volta a 1.0.
- `docs/07-design-system.md`: DateBlock, DeadlineCard, StatusBanner e um parágrafo "Fonte do sistema grande" na tipografia, com a regra geral.

**Decidido**
- Na fonte de teste o `TextPainter` não arredonda a altura da linha (o dia mede 36 em 1,3×, não 37). O teste de "não quebra linha" compara com uma linha (`closeTo`), não com o valor arredondado; o tamanho do bloco continua exato.

**Pendente / dúvidas** (fora do escopo; vistos no emulador em 2×, sem estouro)
- `DeadlineCard`: a coluna do texto relativo não encolhe, então o título vira "Licença …" e o contexto "Beta Ali…". Vale estudar quebrar o texto relativo ou empilhar em escala alta.
- `NavRow` do módulo na empresa: "Ambiental" quebra no meio da palavra ("Ambienta / l") porque o resumo "1 a vencer" ocupa a largura.
- Barra de ações do detalhe: "Registrar renovação" quebra em duas linhas (cabe, mas fica apertado).

**Refs:** commits 3397cd0 (docs) · 93145ce (correção) · branch `task/011-date-block-fonte-grande`

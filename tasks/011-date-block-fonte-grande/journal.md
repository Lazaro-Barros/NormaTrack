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

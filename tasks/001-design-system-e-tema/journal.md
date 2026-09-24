# Journal — 001

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-24 — Wireframes e design system

**Feito**
- Wireframes de 10 telas e 2 pranchas de design system publicados no canvas [NormaTrack — Wireframes e Design System](https://claude.ai/artifact/LGB1NY3JgjKgPWPLf7Sw7z).
- Criado `docs/07-design-system.md` e link no README.

**Decidido**
- Cor de marca azul-petróleo `#0E5A63` com neutros quentes; quatro cores de situação (vencido, a vencer, vigente, renovado) — motivo: situação é a informação principal do app.
- Situação sempre com ícone + texto, nunca só cor — legibilidade ao sol, daltonismo, impressão.
- Manrope (títulos e números) + IBM Plex Sans (texto); números com algarismos tabulares.
- Navegação inferior com 3 destinos: Painel, Empresas, Ajustes. Telas internas usam barra de ações no rodapé.

**Pendente / dúvidas**
- Unidade dos ruídos em dB(A) assumida (C6); CNPJ opcional (C5); campo "Nº do documento" no prazo não está no modelo (C5/C13).

## 2026-09-24 — Tema Flutter

**Feito**
- `lib/app/theme/` (cores, tipografia, espaçamento, raios, `StatusColors`) e `AppTheme.light`.
- `StatusChip` em `lib/app/widgets/`.
- `main.dart` sem o contador de exemplo; usa o tema.
- Testes de tema e contraste. `flutter analyze` e `flutter test` sem erros.
- Seção "Design system" no `CLAUDE.md`; fontes dos wireframes copiadas para `docs/design/wireframes/`.

**Decidido**
- Fontes embarcadas como asset, não `google_fonts` — o app é offline.
- `StatusTone` na apresentação; o domínio não conhece cores.

**Pendente / dúvidas**
- Baixar e declarar os arquivos de fonte em `assets/fonts/` (até lá usa a fonte padrão).

## 2026-09-24 — Estrutura de tasks

**Feito**
- Criada a pasta `tasks/` com índice e template, e a skill `.claude/skills/task/`. Esta task foi registrada retroativamente como exemplo do formato.

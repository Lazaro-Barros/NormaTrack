# Journal — 004

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-29 — Task criada e propostas desenhadas

**Feito**
- Task criada a partir do feedback do usuário: telas "muito brancas" e com excesso de informação.
- Desenhadas duas propostas (Painel, Empresa, Módulo) no canvas [NormaTrack — Wireframes e Design System](https://claude.ai/artifact/LGB1NY3JgjKgPWPLf7Sw7z) e copiadas para `prototypes/`.

**Decidido**
- Situação continua com ícone ou texto além da cor: o bloco de data colorido vem junto com "Venceu há 3 dias" / "Vence em 12 dias".
- Cores de módulo evitam verde, vermelho e âmbar para não competir com as cores de situação.

**Pendente / dúvidas**
- Usuário escolher A ou B (ou combinação).

## 2026-09-29 — Proposta A escolhida

**Decidido**
- Usuário escolheu a **proposta A** (fundo tingido, cards sem borda, cabeçalho em faixa petróleo, números do Painel como filtro, bloco de data na cor da situação, menos rótulos). Proposta B (cor por módulo) descartada por ora.

**Pendente / dúvidas**
- Refazer todos os wireframes e as pranchas do design system na direção A; atualizar docs, tema e testes; revisar a task 003.

## 2026-09-29 — Design system v0.2 aplicado

**Feito**
- Canvas: as 10 telas e as 2 pranchas refeitas na direção A; nova tela `EmpresaOrgao` (bottom sheet); propostas A/B removidas do canvas (continuam em `prototypes/`).
- `docs/design/wireframes/` substituído pela v0.2.
- `docs/07-design-system.md` → v0.2: 5 princípios, tokens novos, superfícies sem borda, componentes (faixa de cabeçalho, `DeadlineCard`, `StatTile`, `PendingRow`) e telas de empresa conforme a task 003.
- `lib/app/theme/` atualizado; testes de contraste novos. `flutter analyze` e `flutter test` (75) sem erros.
- `CLAUDE.md`: regras da faixa de cabeçalho, cards sem borda e onde usar `StatusChip`.
- Task 003 revisada (dependência da 004, wireframes, journal).

**Decidido**
- Situação em listas: bloco de data na cor forte + texto relativo na mesma cor; `StatusChip` só em histórico e tabelas.
- Títulos de seção em frase normal; `AppTypography.overline` removido.
- Formulário de empresa: rolável em seções; órgãos em bottom sheet (ver journal da 003).
- `border` renomeado para `divider`: na v0.2 ele só separa itens dentro de um card.

**Pendente / dúvidas**
- Aprovação do usuário para os wireframes v0.2; depois, status → `concluída`.

## 2026-09-29 — Wireframes aprovados, task concluída

**Feito**
- Usuário aprovou os wireframes e as pranchas v0.2. Status → `concluída`.
- Decisão registrada em `docs/decisoes.md` (D009).

**Refs:** docs/decisoes.md#d009--design-system-v02

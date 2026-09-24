# CLAUDE.md

Contexto para agentes de código trabalhando neste repositório.

## Projeto

NormaTrack é um app Flutter (Android) de conformidade regulatória para indústrias: prazos com alerta, lançamentos periódicos e relatórios exportáveis. Leia `docs/` antes de implementar qualquer coisa. `docs/02-requisitos.md` e `docs/03-dominio.md` são a fonte da verdade do escopo.

## Regras de arquitetura

- `features/*/domain` é Dart puro: sem imports de Flutter, drift ou HTTP.
- A UI acessa dados **apenas** por interfaces de repositório injetadas via Riverpod. Nunca use o `AppDatabase` diretamente em widgets.
- Toda tabela tem `id` UUID (gerado no app), `createdAt`, `updatedAt` e `deletedAt`. Exclusão é lógica.
- Valores derivados (estoque por lote, situação de prazo) são calculados, não persistidos.
- Toda alteração de schema vem acompanhada de migração drift versionada e teste.

## Tasks (obrigatório para qualquer implementação)

Todo trabalho acontece dentro de uma task em `tasks/NNN-slug/`, seguindo a skill `.claude/skills/task/SKILL.md`: escopo no `README.md`, plano técnico no `plan.md`, protótipos em `prototypes/` e diário no `journal.md`, atualizado durante o trabalho com o que foi feito e decidido. O índice fica em `tasks/README.md`. Ao retomar uma task, leia o README dela e o fim do journal antes de mexer no código.

## Design system (obrigatório em toda tela ou widget)

Toda funcionalidade nova com interface parte do design system. Antes de criar uma tela, leia:

1. `docs/07-design-system.md`: princípios, tokens, componentes e inventário de telas (fonte da verdade).
2. `docs/design/wireframes/<Tela>.dc.html`: wireframe da tela, se existir (layout, hierarquia e textos). `DS-Fundamentos` e `DS-Componentes` mostram os tokens e componentes desenhados.
3. `lib/app/theme/`: implementação dos tokens (`AppTheme`, `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`, `StatusColors`).

Regras:

- Cores só via `Theme.of(context).colorScheme` ou `StatusColors.of(context)`. Nada de `Color(0x…)`, `Colors.*` ou hex solto em widgets de feature. `AppColors` é usado apenas dentro de `lib/app/theme/`.
- Texto só via `Theme.of(context).textTheme` (ou `AppTypography.overline` / `.number` / `.tabular`). Não defina `fontSize`/`fontWeight` avulsos. Datas, quantidades e CNPJ usam algarismos tabulares.
- Espaço e cantos só com `AppSpacing` e `AppRadius`. Margem lateral das telas: `AppSpacing.screen`. Área de toque mínima: 48.
- Situação de prazo é sempre `StatusChip` (ícone + texto), nunca só cor. O domínio calcula a situação; a UI converte para `StatusTone`.
- Reutilize os widgets de `lib/app/widgets/`. Se a tela precisa de um componente listado em `docs/07-design-system.md` que ainda não existe, crie-o lá (genérico, com teste) antes de usar, em vez de desenhá-lo dentro da feature.
- Um botão primário (`FilledButton`) por tela, no rodapé. Ações destrutivas usam contorno e pedem confirmação.
- Navegação: barra inferior com Painel, Empresas e Ajustes; telas internas trocam a barra por uma barra de ações.
- Se a funcionalidade exigir algo que o design system não cobre (nova cor, novo componente, padrão diferente), não invente localmente: estenda o tema/componente, atualize `docs/07-design-system.md` no mesmo PR e explique a mudança na descrição.

## Convenções

- Interface do usuário em pt-BR; nomes em código conforme o glossário de `docs/03-dominio.md`.
- Referencie o número da task e o ID do requisito (ex.: `[task 003, RF-PRZ-03]`) no commit ou PR.
- Antes de concluir: `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift / codegen
flutter test
flutter run
```

## Ao encontrar ambiguidade

Não invente regra de negócio. Registre a dúvida em `docs/06-perguntas-em-aberto.md` e siga com a suposição mais simples, marcada com `// TODO(RF-XXX):`.

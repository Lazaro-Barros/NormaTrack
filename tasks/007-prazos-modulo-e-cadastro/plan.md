# Plano técnico — 007

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Três telas novas na camada de apresentação de `lib/features/deadlines/`, sobre o `DeadlineRepository` da task 006: tela do módulo (prazos em aberto agrupados por categoria), formulário de prazo (novo e edição) e bottom sheet de lembrete. Dois componentes genéricos novos em `lib/app/widgets/` (`DeadlineCard` e `BandSegmentedButton`), um ajuste no `EmptyState` (passa a ficar dentro de card) e no `AppDropdownField` (rótulo do "nenhum"). O detalhe da empresa passa a navegar para o módulo e a mostrar a pior situação dos prazos de cada módulo.

## Contexto do repositório (em 2026-09-30)

- Flutter 3.47.5, `flutter_riverpod` 3.4.3, `go_router` 17.5.0 (D010). Nenhum pacote novo nesta task.
- **Domínio e dados de prazos prontos (task 006):** `lib/features/deadlines/domain/` (`Deadline`, `DeadlineInput`, `DeadlineCategory` com `defaultReminderDays` e `canBeCompleted`, `DeadlineStatus`, `DeadlineSituation`, `normalizeDeadlineInput`, `validateDeadline`, `DeadlineFieldError`, `DeadlineRepository` e exceções) e `lib/features/deadlines/data/local_deadline_repository.dart` (`deadlineRepositoryProvider`). Ainda **não existe** `lib/features/deadlines/presentation/`.
- **Padrões de apresentação a copiar** (empresas, task 003):
  - `company_form_screen.dart`: `ConsumerStatefulWidget`, `PopScope` com diálogo "Descartar alterações?", `_unfocus()` antes de abrir sheet/diálogo/seletor de data, erros por campo com `GlobalKey` e `Scrollable.ensureVisible`, `AppActionBar` com "Cancelar" (`OutlinedButton`) e o primário (`FilledButton`) expandido, `SnackBar` "… salva" e `context.pop()`.
  - `registration_sheet.dart`: `showModalBottomSheet(isScrollControlled: true, useSafeArea: true, showDragHandle: true)`, cabeçalho com título + fechar, padding inferior com `MediaQuery.viewInsetsOf(context).bottom`, `showDatePicker(firstDate: DateTime(2000), lastDate: DateTime(2100))`, campo de data `AppTextField(readOnly: true, onTap: …, tabular: true)`.
  - `company_detail_screen.dart`: `today = ref.read(clockProvider)().toLocal()`; `SectionCard` + `NavRow` + `StatusText`; `switch` sobre `AsyncValue` para carregando/erro/ausente.
  - `company_list_screen.dart`: `FloatingActionButton.extended` para "Nova empresa"; lista com `ListView.separated` e `padding: EdgeInsets.only(bottom: 88)` para não esconder o último item atrás do FAB.
  - `company_labels.dart`: `ModuleTypeUi` (`icon`, `description`) e `registrationDisplay` → `({String label, StatusTone? tone})`.
- **Tema:** `StatusTone { overdue, dueSoon, ok, closed }` e `StatusColors.of(context).resolve(tone)` (`.foreground` forte, `.background` suave); `StatusChip.iconFor(tone)`; `BandColors` (`ThemeExtension` com `muted`); `AppColors` só dentro de `lib/app/theme/`. `SegmentedButton` do tema é para fundo claro (trilho `surface2`, selecionado `primary`); **não há** variante para a faixa.
- **Rotas** (`lib/app/router.dart`): `AppRoutes` com `companies`, `company(id)`, `editCompany(id)`; telas internas usam `parentNavigatorKey: rootKey`.
- **Testes de widget:** `test/helpers/pump_app.dart` monta o app inteiro (390 × 844) com `FakeCompanyRepository`, relógio fixo `testNow = DateTime.utc(2026, 9, 29, 12)` e `initialLocation`. `test/helpers/pump_widget.dart` tem `pumpComponent` para widgets isolados. **Armadilha:** assim que o detalhe da empresa observar prazos, todo teste que usa `pumpApp` passa a ler `deadlineRepositoryProvider`; sem override ele tenta abrir o banco real (`driftDatabase`) e falha. O `pumpApp` precisa sobrescrever o provider com um fake por padrão (passo 1).
- Wireframes oficiais atualizados nesta task (protótipo aprovado em 2026-09-30): `docs/design/wireframes/PrazoForm.dc.html` (lista de lembretes) e `docs/design/wireframes/PrazoLembrete.dc.html` (sheet). `ModuloAmbiental.dc.html` continua com abas e grupos "ETE e ETA"; **nesta task não há abas e o agrupamento é por categoria** (decisão da usuária).

## Ordem de implementação

Branch: `task/007-prazos-modulo-e-cadastro` (já existe, com os commits de docs). Um commit por passo, `feat(<escopo>): <o quê> [task 007, RF-…]`, com a linha de coautoria do harness. Journal a cada passo. Status → `em andamento` no primeiro commit de código.

1. Helpers de teste: `FakeDeadlineRepository` e `pumpApp` com override de `deadlineRepositoryProvider` (roda a suíte atual para garantir que nada quebrou).
2. `core/utils/date_format.dart`: `formatMonthAbbr`. Domínio: `reminderDate` (função pura) usada por `Deadline`.
3. Componentes: `DeadlineCard`, `BandSegmentedButton` (+ cor `BandColors.segment`), `EmptyState` em card, `AppDropdownField.noneLabel`, `AppTextField.helperText`, `FieldErrorText`. Testes. `docs/07-design-system.md`.
4. Apresentação de prazos: `deadline_labels.dart` e `deadline_providers.dart`, com testes.
5. Rotas e tela do módulo; detalhe da empresa navega e mostra pendências.
6. Sheet de lembrete e formulário de prazo.
7. `dart format .`, `flutter analyze`, `flutter test`; conferir no emulador (se houver) o fluxo empresa → módulo → novo prazo → editar. Fechamento: critérios, journal, status, roadmap, docs.

## Arquivos

```
lib/app/router.dart                                   # rotas do módulo e do prazo
lib/app/theme/app_colors.dart                         # + onBandSegment
lib/app/theme/band_colors.dart                        # + segment
lib/app/widgets/deadline_card.dart                    # novo
lib/app/widgets/band_segmented_button.dart            # novo
lib/app/widgets/empty_state.dart                      # conteúdo dentro de Card
lib/app/widgets/app_dropdown_field.dart               # + noneLabel
lib/app/widgets/app_text_field.dart                   # + helperText
lib/app/widgets/field_error_text.dart                 # novo
lib/core/utils/date_format.dart                       # + formatMonthAbbr
lib/features/deadlines/domain/deadline.dart           # + reminderDate()
lib/features/deadlines/presentation/
├── deadline_labels.dart          # tom, texto relativo, rótulos, slug do módulo, pendências
├── deadline_providers.dart
├── module_screen.dart            # ModuleScreen
├── deadline_form_screen.dart     # DeadlineFormScreen
└── reminder_sheet.dart           # showReminderSheet
lib/features/companies/presentation/company_detail_screen.dart   # linha do módulo

test/helpers/fake_deadline_repository.dart            # novo
test/helpers/pump_app.dart                            # + deadlineRepository
test/app/widgets/deadline_card_test.dart
test/app/widgets/band_segmented_button_test.dart
test/app/widgets/empty_state_test.dart                # + dentro de Card
test/app/widgets/app_dropdown_field_test.dart         # + noneLabel
test/app/widgets/app_text_field_test.dart             # + helperText
test/app/widgets/field_error_text_test.dart
test/app/theme/app_theme_test.dart                    # + contraste do segmentado na faixa
test/core/utils/date_format_test.dart                 # + formatMonthAbbr
test/features/deadlines/presentation/deadline_labels_test.dart
test/features/deadlines/presentation/module_screen_test.dart
test/features/deadlines/presentation/deadline_form_screen_test.dart
test/features/companies/presentation/company_detail_screen_test.dart   # + módulos
```

`ModuleScreen` fica em `features/deadlines` porque hoje só mostra prazos. Quando lançamentos (Fase 2) entrarem, avaliar mover para `features/modules/`.

## Rotas

Em `AppRoutes`:

```dart
static String module(String companyId, ModuleType m) =>
    '/empresas/$companyId/modulos/${m.slug}';
static String newDeadline(String companyId, ModuleType m) =>
    '${module(companyId, m)}/prazos/novo';
static String editDeadline(String companyId, ModuleType m, String id) =>
    '${module(companyId, m)}/prazos/$id/editar';
```

No `router.dart`, dentro de `':id'` (empresa), ao lado de `'editar'`, todas com `parentNavigatorKey: rootKey`:

```
modulos/:modulo                      → ModuleScreen(companyId, slug)
modulos/:modulo/prazos/novo          → DeadlineFormScreen(companyId, slug)
modulos/:modulo/prazos/:prazo/editar → DeadlineFormScreen(companyId, slug, deadlineId)
```

`prazos/novo` antes de `prazos/:prazo` (mesma regra de `nova` antes de `:id`). Na task 008, `prazos/:prazo` vira o detalhe. `AppRoutes` importa `ModuleType` e `ModuleTypeUi` (para `slug`); `ModuleTypeUi` fica em `company_labels.dart`, onde já está.

**Slug** (`ModuleTypeUi.slug`, e `ModuleType? moduleFromSlug(String)` em `company_labels.dart`):

| `ModuleType` | slug |
|---|---|
| `environmental` | `ambiental` |
| `controlledProducts` | `produtos-controlados` |
| `qualityControl` | `controle-de-qualidade` |

Slug desconhecido → a tela mostra "Módulo não encontrado" (ver estados abaixo).

## Componentes (`lib/app/widgets/`)

### `DeadlineCard`

Genérico: não conhece `Deadline`.

```dart
class DeadlineCard extends StatelessWidget {
  const DeadlineCard({
    super.key,
    required this.date,          // vencimento
    this.showYear = false,       // ano no bloco quando não é o ano corrente
    required this.title,
    this.subtitle,               // linha de contexto (categoria · órgão, ou empresa)
    required this.tone,          // StatusTone
    this.statusLead,             // 1ª linha do texto relativo ("Venceu"); null = uma linha só
    required this.statusText,    // "há 3 dias"
    this.onTap,
  });
}
```

Layout (wireframe `ModuloAmbiental`): `Card` com `InkWell`, `Row` com padding `EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm)` e `AppSpacing.md` entre as partes:
- **Bloco de data** 48 × 52 (`minTouch` × 52), `AppRadius.mdAll`, fundo `resolve(tone).foreground`, texto `colorScheme.onPrimary` (branco). Dia com `AppTypography.number` (tamanho do `titleLarge`); mês (`formatMonthAbbr`) em `labelSmall`; com `showYear`, o mês vira `"SET 28"` (dois dígitos do ano).
- **Centro** (`Expanded`): título em `bodyLarge` com o peso de `labelLarge` (igual ao `RowLayout`), 1 linha com reticências; subtítulo em `bodyMedium`, 1 linha.
- **Direita:** `Column(crossAxisAlignment: end)` com `statusLead` e `statusText` em `AppTypography.tabular(labelMedium)` na cor `resolve(tone).foreground`, peso forte (o `labelMedium` do tema já é 600; não definir `fontWeight` avulso).
- **Semântica:** `Semantics(button: onTap != null, label: '$title, vence em ${formatDate(date)}, ${[statusLead, statusText].join(' ')}', excludeSemantics: true)`. Situação nunca só por cor: o texto relativo carrega a situação.
- Altura mínima 68 (maior que 48 de toque).

### `BandSegmentedButton<T>`

Segmentado claro para a faixa de cabeçalho (usado no `AppBar.bottom`). Envolve `SegmentedButton<T>` com `style` montado a partir do tema (sem cor solta): fundo dos segmentos `BandColors.of(context).segment`, texto `colorScheme.onPrimary`; selecionado com fundo `colorScheme.surface` e texto `colorScheme.primary`; `side: BorderSide.none`, forma `pill`, `showSelectedIcon: false`, `expandedInsets: EdgeInsets.zero`.

```dart
class BandSegmentedButton<T> extends StatelessWidget {
  const BandSegmentedButton({super.key, required this.segments, required this.selected, required this.onChanged});
  final List<(T value, String label)> segments;
  final T selected;
  final ValueChanged<T> onChanged;
}
```

Cor nova: `AppColors.onBandSegment = Color(0xFF307179)` (branco a 14 % sobre `primary` `#0E5A63`, opaco; conta: 0,14·255 + 0,86·c por canal → `30 71 79`). `BandColors` ganha `segment` (com `copyWith`/`lerp`). Teste de contraste novo em `app_theme_test.dart`: `onPrimary` sobre `onBandSegment` ≥ 4,5:1 e `primary` sobre `surface` (já coberto).

### `EmptyState`

O conteúdo (ícone, título, mensagem, ação) passa para dentro de um `Card` (branco, sem borda), com padding interno `AppSpacing.xl`; o `Center` + `SingleChildScrollView` continuam por fora, com padding `AppSpacing.lg`. API não muda. Vale para todas as telas (lista de empresas, placeholders, estados de erro). Atualizar `empty_state_test.dart`: `find.ancestor(of: find.text(title), matching: find.byType(Card))` existe.

### `AppTextField` e `FieldErrorText`

- `AppTextField` ganha `helperText` (`String?`), passado para `InputDecoration.helperText` (o estilo vem do tema; some quando há erro, comportamento padrão do Flutter). Usado no sheet de lembrete.
- `FieldErrorText` (novo, `lib/app/widgets/field_error_text.dart`): mensagem de erro com ícone fora de um campo, reusando `FieldParts.error` (que é interno aos widgets). Usado abaixo do card de lembretes. Teste: mostra o texto e o ícone de erro.

### `AppDropdownField`

Parâmetro novo `noneLabel` (padrão `'Nenhuma'`, mantém o comportamento). O formulário de prazo usa `'Nenhum'` para Órgão.

## Apresentação de prazos

### `deadline_labels.dart`

```dart
/// Tom da situação.
StatusTone deadlineTone(DeadlineSituation s) => switch (s) {
  DeadlineSituation.overdue => StatusTone.overdue,
  DeadlineSituation.dueSoon => StatusTone.dueSoon,
  DeadlineSituation.current => StatusTone.ok,
  DeadlineSituation.renewed || DeadlineSituation.completed || DeadlineSituation.cancelled => StatusTone.closed,
};

/// Texto relativo do DeadlineCard, a partir de daysUntilDue.
({StatusTone tone, String? lead, String text}) deadlineDisplay(Deadline d, DateTime today);
```

Regras do texto (`n = d.daysUntilDue(today)`), só para prazo em aberto:

| Situação | Condição | `lead` | `text` |
|---|---|---|---|
| vencido | `n == -1` | Venceu | ontem |
| vencido | `n < -1` | Venceu | há `-n` dias |
| a vencer | `n == 0` | Vence | hoje |
| a vencer | `n == 1` | Vence | amanhã |
| a vencer | `n > 1` | Vence | em `n` dias |
| vigente | `n <= 365` | — | Em `n` dias (`Em 1 dia` no singular) |
| vigente | `n > 365` | — | Em `n ~/ 365` anos (`Em 1 ano` no singular) |

Fechados (renovado, concluído, cancelado): `lead` null, `text` = `DeadlineStatus.label` ("Renovado"…). Não aparecem nesta task, mas a função é total.

Outros rótulos:
- `String reminderLabel(int days)`: `0` → "No dia do vencimento"; `1` → "1 dia antes"; `n` → "`n` dias antes".
- `String categoryPluralLabel(DeadlineCategory c)`: Licenças, Laudos, Manutenções (títulos de seção).
- `String deadlineSubtitle(Deadline d)`: `[d.category.label, ?d.authority?.shortLabel].join(' · ')` → "Licença · SEMACE".
- `String deadlineFieldMessage(DeadlineFieldError e)`: título `required` → "Informe o título"; lembretes `required` → "Adicione ao menos um lembrete"; lembretes `invalid` → "Lembrete inválido"; `dueDate` `notAfterPrevious` → "A nova data deve ser depois do vencimento atual" (usado na 008).
- `({String label, StatusTone tone})? modulePending(Iterable<Deadline> open, DateTime today)`: conta as situações dos prazos em aberto. Se há vencidos → "`n` vencido(s)" com `overdue`; senão, se há a vencer → "`n` a vencer" com `dueSoon`; senão `null`. Plural: "1 vencido", "2 vencidos".

### `deadline_providers.dart`

```dart
final companyDeadlinesProvider = StreamProvider.autoDispose.family<List<Deadline>, String>(
  (ref, companyId) => ref.watch(deadlineRepositoryProvider).watchByCompany(companyId));

final moduleDeadlinesProvider = StreamProvider.autoDispose
    .family<List<Deadline>, ({String companyId, ModuleType module})>(
  (ref, key) => ref.watch(deadlineRepositoryProvider).watchByCompany(key.companyId, module: key.module));
```

(Registro como chave: igualdade estrutural, funciona com `family`.)

## Detalhe da empresa

Em `_modules`: para cada módulo habilitado, `NavRow(leadingIcon, title, trailing: pending == null ? null : StatusText(label, tone), onTap: () => context.go(AppRoutes.module(company.id, module)))`. `pending = modulePending(deadlines.where((d) => d.module == module), today)`, com `deadlines` de `ref.watch(companyDeadlinesProvider(company.id)).value ?? const []` (carregando ou erro: sem trailing). Remove o `TODO(RF-EMP-03)`. O `TODO(RF-PRZ-05)` da faixa (pílulas) continua para a task 009.

## Tela do módulo (`ModuleScreen`)

`ConsumerWidget` com `companyId` e `slug`.

**Estados**, nesta ordem (cada um é `Scaffold` com `AppBar()` e `EmptyState`):
1. `moduleFromSlug(slug) == null` → ícone `Icons.help_outline`, "Módulo não encontrado", "Volte e escolha o módulo de novo.", ação "Voltar" → `context.go(AppRoutes.company(companyId))`.
2. Empresa carregando (`companyProvider`) → `CircularProgressIndicator`. Empresa `null` → "Empresa não encontrada" / "Ela pode ter sido excluída." / "Voltar" → `AppRoutes.companies`.
3. Módulo desligado (`!company.hasModule(module)`) → ícone do módulo, "Módulo desligado", "Ligue o módulo no cadastro da empresa para ver os prazos.", ação "Editar empresa" → `AppRoutes.editCompany`.

**Conteúdo:**
- `AppBar(title: BandTitle(title: module.label, subtitle: company.displayName))`, com a seta de voltar padrão.
- Corpo com `moduleDeadlinesProvider`: carregando → indicador; erro → `EmptyState` "Não foi possível carregar os prazos"; lista vazia → `EmptyState(icon: module.icon, title: 'Nenhum prazo em aberto', message: 'Cadastre licenças, laudos e manutenções para receber os alertas.', actionLabel: 'Cadastrar prazo', onAction: novo)`.
- Com prazos: `ListView` com padding `AppSpacing.screen.copyWith(top: lg, bottom: 88)`. Para cada categoria **na ordem de `DeadlineCategory.values`** que tenha prazos: título de seção (`Text(categoryPluralLabel(c), style: titleMedium)`, padding horizontal `xs`, como no `SectionCard`) e os `DeadlineCard`s da categoria na ordem que o repositório já entrega (vencimento, título), separados por `sm`; `lg` entre seções.
- `DeadlineCard`: `date: d.dueDate`, `showYear: d.dueDate.year != today.year`, `title: d.title`, `subtitle: deadlineSubtitle(d)`, tom e texto de `deadlineDisplay`, `onTap: () => context.go(AppRoutes.editDeadline(companyId, module, d.id))`. // TODO(RF-PRZ-04): na task 008, abrir o detalhe.
- `FloatingActionButton.extended(icon: Icons.add, label: 'Novo prazo')` → `AppRoutes.newDeadline`. Sem FAB nos estados de erro/ausência. Empresa arquivada: tela normal.

## Formulário (`DeadlineFormScreen`)

`ConsumerStatefulWidget(companyId, slug, deadlineId?)`. Mesmos estados de erro da tela do módulo (slug inválido, empresa ausente) e, na edição, prazo ausente (`findById == null`) → "Prazo não encontrado" / "Ele pode ter sido excluído." / "Voltar" → módulo.

**Estado:** `_category` (padrão `license`), `_authority` (null), `_title` (controller), `_dueDate` (`DateTime?`), `_reminders` (`List<int>`, ordenada decrescente; começa com `_category.defaultReminderDays`), `_remindersEdited` (bool), `_errors` (`Map<_Field, String>`, com `_Field { title, dueDate, reminders }` e uma `GlobalKey` por campo), `_initial` (snapshot para "sujo"), `_loading`, `_notFound`, `_saving`, `_saved`. Na edição, `_load` preenche tudo a partir de `deadline.toInput()` e marca `_remindersEdited = true`; o módulo usado ao salvar é o do prazo carregado (não o do slug).

**Faixa:** `BandTitle(title: novo ? 'Novo prazo' : 'Editar prazo', subtitle: '${company.displayName} · ${module.label}')`, `leading` fechar (como no formulário de empresa) e `bottom: PreferredSize(height: minTouch + lg)` com `BandSegmentedButton<DeadlineCategory>` (Licença, Laudo, Manutenção).

**Trocar categoria:** se `!_remindersEdited`, `_reminders = category.defaultReminderDays`. Qualquer adição ou remoção de lembrete marca `_remindersEdited = true`.

**Corpo** (`SingleChildScrollView`, como o de empresa):
- `SectionCard('Dados do prazo')` com padding `lg` e `md` entre campos: `AppTextField('Título', required, hint: 'Ex.: Licença de Operação', capitalization sentences)`; `AppDropdownField<Authority>('Órgão', items: Authority.values, itemLabel: label, noneLabel: 'Nenhum')`; campo de data 'Vencimento' obrigatório (`readOnly`, `tabular`, ícone de calendário, `showDatePicker(initialDate: _dueDate ?? today, firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: 'Vencimento')`, com `_unfocus()` antes).
- `SectionCard('Lembretes', caption: 'Alertas a partir de dd/mm/aaaa')` — caption só com vencimento e ao menos um lembrete; a data é `reminderDate(_dueDate, _reminders.first)`. Uma `NavRow` por lembrete: `leadingIcon: Icons.notifications_none_outlined`, `title: reminderLabel(n)`, `subtitle: _dueDate == null ? null : formatDate(reminderDate(_dueDate, n))`, `trailing: Row(mainAxisSize: min, [if primeiro: Text('Primeiro alerta', labelMedium, cor primary), IconButton(Icons.close, tooltip: 'Remover lembrete')])`. Última linha: `NavRow(leadingIcon: Icons.add, title: 'Adicionar lembrete', onTap: _addReminder)`. Abaixo do card, `Text('O prazo fica "a vencer" a partir do primeiro alerta. Os outros lembretes são avisos no celular.', bodyMedium)`. Erro de lembretes: `FieldErrorText(message)` abaixo do card (componente novo, ver abaixo).
- `AppActionBar`: "Cancelar" + `FilledButton('Salvar prazo')` expandido.

**Salvar:**
1. Erros locais: título vazio (após `trim`) → "Informe o título"; sem vencimento → "Informe o vencimento"; lista vazia → "Adicione ao menos um lembrete". Com erro: mostra e rola até o primeiro (`title`, `dueDate`, `reminders`).
2. Monta `DeadlineInput(module, category, authority, title, dueDate, reminderDays: _reminders)` e chama `create(companyId, input)` ou `update(id, input)`.
3. Sucesso: `_saved = true`, `SnackBar('Prazo salvo')`, `context.canPop() ? context.pop() : context.go(AppRoutes.module(...))`.
4. `DeadlineValidationException` → mapeia com `deadlineFieldMessage`. `ModuleNotEnabledException` → SnackBar "O módulo foi desligado nesta empresa" e `go(AppRoutes.company(companyId))`. `CompanyNotFoundException` → SnackBar "Empresa não encontrada" e `go(AppRoutes.companies)`. `DeadlineNotFoundException` → SnackBar "Prazo não encontrado" e `go(AppRoutes.module(...))`.

**Sujo e descarte:** `_isDirty` compara `(category, authority, title.trim(), dueDate, reminders)` com `_initial`. `PopScope` + `showConfirmDialog('Descartar alterações?', …, destructive: true)`, igual ao formulário de empresa.

## Sheet de lembrete (`reminder_sheet.dart`)

```dart
/// Devolve os dias escolhidos, ou null se fechou sem adicionar.
Future<int?> showReminderSheet(BuildContext context, {required List<int> existing, DateTime? dueDate});
```

Mesmo esqueleto do `registration_sheet.dart`. Conteúdo (wireframe `PrazoLembrete`):
- Cabeçalho: "Adicionar lembrete"; subtítulo "Vencimento em dd/mm/aaaa" (se houver) e fechar.
- "Atalhos": `Wrap` de `ChoiceChip`s com `[60, 30, 15, 7, 1, 0]` **menos** os que já estão em `existing`; rótulo "`n` dias", "1 dia", "No dia". Selecionar um atalho preenche o campo. Sem atalhos restantes, a seção não aparece. Texto abaixo: "`<lista de existentes>` já estão na lista." só se algum atalho foi escondido — **simplificação aceita:** omitir esse texto se complicar; ele não é critério.
- Campo `AppTextField('Dias antes do vencimento', required, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)], suffixIcon: Padding(… Text('dias')), tabular: true, helperText: …)`. Ajuda: com vencimento, "Aviso em dd/mm/aaaa. Use 0 para avisar no dia."; sem, "Use 0 para avisar no dia." (`helperText` é parâmetro novo do `AppTextField`, ver abaixo).
- `FilledButton('Adicionar')`: vazio → erro "Informe os dias"; valor em `existing` → "Este lembrete já está na lista"; senão `pop(valor)`.
- O formulário insere o valor e reordena decrescente.

## Testes

Relógio `testNow` = 29/09/2026. Datas de exemplo (conferidas por script, `date(2026,9,29) + timedelta`): vencimento **31/10/2026** → `n = 32` → "Vence em 32 dias" com lembretes padrão de licença (150 ≥ 32 → a vencer); **15/03/2028** → `n = 533` → vigente, "Em 1 ano", bloco "15 / MAR 28"; **26/09/2026** → `n = -3` → "Venceu / há 3 dias"; **29/09/2026** → "Vence / hoje"; laudo com vencimento **08/11/2026** (`n = 40`, lembretes `[30, 10, 3, 0]`) → vigente "Em 40 dias"; alerta a partir de **09/10/2026**.

| Arquivo | Cobre |
|---|---|
| `test/helpers/fake_deadline_repository.dart` | (helper) em memória: `create`/`update` com `normalizeDeadlineInput`/`validateDeadline`, checagem de módulo se receber o `FakeCompanyRepository`, `watchByCompany` (módulo, estados, ordem vencimento→título), `watchById`, `findById`, `watchUpcoming` (só em aberto), `watchHistory` (`[d]`), `renew`/`complete`/`cancel`/`reopen`/`delete` simples; `seed(companyId, input)` |
| `deadline_card_test.dart` | dia e mês ("21", "SET"); `showYear` → "SET 28"; título, subtítulo, `lead` + `text` na cor forte do tom; bloco com fundo da cor forte; `onTap`; rótulo semântico |
| `band_segmented_button_test.dart` | mostra os rótulos, marca o selecionado, chama `onChanged` |
| `empty_state_test.dart` | + conteúdo dentro de `Card` |
| `app_dropdown_field_test.dart` | + `noneLabel: 'Nenhum'` aparece e limpa |
| `app_text_field_test.dart` | + `helperText` aparece; some com erro |
| `field_error_text_test.dart` | texto e ícone de erro |
| `app_theme_test.dart` | + contraste `onPrimary` × `onBandSegment` ≥ 4,5 |
| `date_format_test.dart` | `formatMonthAbbr` para os 12 meses (JAN … DEZ) |
| `deadline_labels_test.dart` | tabela de `deadlineDisplay` (todas as linhas, com os exemplos acima), `deadlineTone`, `reminderLabel` (0, 1, 150), `categoryPluralLabel`, `deadlineSubtitle` com e sem órgão, `modulePending` (vencidos ganham de a vencer; plural; `null` só vigentes/vazio), `moduleFromSlug(m.slug) == m` e desconhecido → `null` |
| `module_screen_test.dart` | seções na ordem Licenças → Laudos → Manutenções e sem seção vazia; card com "Venceu"/"há 3 dias"; vazio com "Cadastrar prazo" abrindo o formulário; FAB abre "Novo prazo"; tocar no card abre "Editar prazo"; slug inválido, empresa inexistente e módulo desligado mostram o estado certo |
| `deadline_form_screen_test.dart` | novo com lembretes padrão de licença (5 linhas) e "Alertas a partir de" depois de escolher a data; trocar para Laudo repõe `[30, 10, 3, 0]`; depois de remover um lembrete, trocar de categoria **não** repõe; adicionar pelo sheet (atalho e digitado; atalhos escondem os existentes; repetido mostra erro; 0 vira "No dia do vencimento"); salvar sem título/vencimento/lembretes mostra os três erros; salvar cria no fake e volta ao módulo com "Prazo salvo"; editar carrega os valores e salva; fechar sujo pede confirmação; prazo inexistente mostra "Prazo não encontrado" |
| `company_detail_screen_test.dart` | + módulo com prazo vencido mostra "1 vencido"; só a vencer mostra "2 a vencer"; só vigentes, nada; tocar no módulo abre a tela do módulo |

Os testes de widget usam `pumpApp(tester, repository: companies, deadlineRepository: deadlines, initialLocation: …)`. O seletor de data nos testes: preencher tocando no campo, `tester.tap(find.text('OK'))` depois de escolher o dia no `CalendarDatePicker`, ou — mais simples — trocar para o modo de digitação (`Icons.edit`) e digitar `31/10/2026`; conferir qual funciona com o `showDatePicker` do Flutter 3.47.5 e registrar no journal.

## Como verificar (definição de pronto)

```bash
dart format . && flutter analyze && flutter test
grep -rnE "Color\(0x|Colors\.|fontSize|fontWeight" lib/features/deadlines/presentation lib/app/widgets/deadline_card.dart lib/app/widgets/band_segmented_button.dart   # vazio
```

- No emulador (se disponível): Empresas → empresa com Ambiental → Ambiental (vazio, card do EmptyState) → Novo prazo → licença com vencimento → lembretes → salvar → card na seção Licenças → tocar → editar título → salvar. Detalhe da empresa mostra a pendência. Sem exceções no log.
- Critérios de aceite do `README.md` marcados, ou justificados no journal.

## Docs a atualizar

- `docs/07-design-system.md`: `DeadlineCard` ✅ (com a regra do ano e do texto relativo); `BandSegmentedButton` ✅ na tabela de componentes e a cor `onBandSegment` na tabela de cores; `EmptyState` "dentro de card"; `AppDropdownField` com `noneLabel`; telas "Módulo" (sem abas até a Fase 2; agrupado por categoria), "Novo prazo" (lista de lembretes e sheet) e uma linha nova "Lembrete (sheet)". Remover a nota "Aprovação" pendente, se houver.
- `docs/05-roadmap.md`: item "CRUD de prazos…" → "em parte: domínio e dados (006), telas de cadastro e edição (007); cancelar e excluir na 008".
- `tasks/005-botao-tonal/journal.md` não muda; a pendência do tonal discreto é fechada no journal desta task.

## Riscos e alternativas

- **Rotas longas** (`/empresas/:id/modulos/:modulo/prazos/:prazo/editar`): aceitas; espelham a hierarquia e facilitam a 008. *Descartado:* `/prazos/:id` na raiz, que perde o contexto de empresa e módulo para o botão voltar.
- **Segmentado na faixa** é um componente novo; a alternativa (segmentado claro no corpo) contraria o protótipo aprovado.
- **`EmptyState` em card** muda o visual de telas já prontas (lista de empresas vazia, placeholders); conferir no emulador.
- **Texto relativo acima de 365 dias em anos** é decisão de interface desta task, não regra de negócio.
- *Descartado:* guardar o estado do formulário num `Notifier` do Riverpod. O formulário de empresa usa estado local, e o de prazo segue o mesmo padrão.

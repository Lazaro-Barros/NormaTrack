# Plano técnico — 008

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Só apresentação: o `DeadlineRepository` da task 006 já implementa `renew`, `complete`, `cancel`, `reopen`, `delete`, `watchById` e `watchHistory`. Esta task adiciona a tela de detalhe do prazo (faixa com `StatusBanner`, dados, histórico de ciclos, ações), dois sheets de data (renovar e concluir), o segmentado "Em aberto | Encerrados" na tela do módulo e três ajustes em widgets genéricos. **Nenhuma mudança de schema, de domínio de dados ou pacote novo.** Há uma função pura nova de domínio (`suggestedRenewalDate`).

## Contexto do repositório (em 2026-11-16)

- Flutter 3.47.9 / Dart 3.13.7, `flutter_riverpod` 3.x, `go_router` 17.5 (D010). 246 testes verdes, `flutter analyze` limpo. Nenhum pacote novo.
- **Já existe** em `lib/features/deadlines/`: `domain/` (`Deadline` com `situationOn`, `daysUntilDue`, `alertStartDate`, `reminderDates`, `isOpen`, `toInput`; `DeadlineCategory.canBeCompleted`; `DeadlineStatus`; `DeadlineSituation`; `DeadlineRepository` e exceções), `data/local_deadline_repository.dart` (`deadlineRepositoryProvider`) e `presentation/` (`module_screen.dart`, `deadline_form_screen.dart`, `reminder_sheet.dart`, `deadline_labels.dart` com `deadlineTone`, `deadlineDisplay`, `reminderLabel`, `deadlineSubtitle`, `deadlineFieldMessage`; `deadline_providers.dart` com `companyDeadlinesProvider` e `moduleDeadlinesProvider`).
- **Semântica do repositório real** (não mudar): `watchByCompany(statuses:)` padrão só `active`; `watchHistory(id)` devolve a cadeia que contém `id`, **mais novo primeiro**, sem excluídos; `renew` exige `active` e data **posterior** ao vencimento (senão `DeadlineValidationException` com `notAfterPrevious`) e cria o próximo ciclo com os mesmos dados e lembretes; `complete` só `active` e `category.canBeCompleted`; `cancel` só `active`; `reopen` só `completed`/`cancelled`; `delete` é lógico e, se o prazo excluído está `active` e o anterior está `renewed`, reabre o anterior. Estado inválido lança `InvalidDeadlineTransitionException`; id inexistente ou excluído, `DeadlineNotFoundException`.
- **Widgets reaproveitáveis** (`lib/app/widgets/`): `AppActionBar`, `BandTitle`, `SectionCard`, `InfoRow`, `StatusChip`, `StatusText`, `DeadlineCard`, `EmptyState`, `BandSegmentedButton`, `FieldErrorText`, `AppTextField`, `DestructiveButton`, `showConfirmDialog`. Tema: `StatusColors.of(context).resolve(tone)` (`.foreground` forte, `.background` suave), `AppSpacing`, `AppRadius`, `AppTypography.tabular`.
- **Padrões a copiar:** faixa com bloco extra em `AppBar.bottom` como o `deadline_form_screen.dart` (linha ~330: `PreferredSize(preferredSize: Size.fromHeight(... + AppSpacing.lg))` com `Padding(fromLTRB(lg, 0, lg, lg))`); estados `AsyncValue` e mensagens como `module_screen.dart` (`_message`, `moduleFromSlug`); sheet como `reminder_sheet.dart` e `registration_sheet.dart` (`showModalBottomSheet(isScrollControlled: true, useSafeArea: true, showDragHandle: true)`, `showDatePicker`, `AppTextField(readOnly: true, onTap:, tabular: true)`); `SnackBar` capturando `ScaffoldMessenger.of(context)` **antes** do `await`.
- **Armadilhas:**
  - `test/helpers/fake_deadline_repository.dart` **simplifica demais**: `watchHistory` devolve só `[prazo]`; `renew` não valida; `complete`/`cancel`/`reopen` não checam estado; `delete` não reabre o anterior. O passo 1 corrige isso antes de qualquer tela.
  - `module_screen.dart` hoje abre `AppRoutes.editDeadline` ao tocar no card (`// TODO(RF-PRZ-04)`), e `module_screen_test.dart` ("FAB abre novo prazo e o card abre a edição") espera isso: ajustar.
  - `AppRoutes.editDeadline` é `prazos/:prazo/editar` irmã de `prazos/novo`. O detalhe passa a ser `prazos/:prazo` **com `editar` aninhada**, para que `pop()` do formulário volte ao detalhe (o go_router monta a pilha pelos pais).
  - O `ModuleScreen._Deadlines` é `ConsumerWidget`; vira `ConsumerStatefulWidget` para guardar o segmento.
  - Datas de prazo são `DateTime(y, m, d)` local, sem hora. "Hoje" vem de `ref.read(clockProvider)().toLocal()`.

## Ordem de implementação

Branch: `task/008-prazo-detalhe` a partir da `main`. Um commit por passo, `feat(prazos): <o quê> [task 008, RF-PRZ-04]` (ou `RF-AMB-06` no passo de concluir), com a linha de coautoria do harness. Journal a cada passo; status → `em andamento` no primeiro commit de código. Rodar `flutter test` ao fim de cada passo.

1. **Fake fiel ao real** (`test/helpers/fake_deadline_repository.dart`): `watchHistory` percorre a cadeia por `previousDeadlineId` (para cima) e pelo ciclo seguinte vivo (para baixo), mais novo primeiro; `renew` exige `active` e `due.isAfter(current.dueDate)`; `complete`/`cancel`/`reopen` validam como o real e lançam `InvalidDeadlineTransitionException`; `delete` reabre o anterior `renewed` se o excluído estava `active`. A suíte atual continua verde.
2. **Domínio:** `suggestedRenewalDate` (novo `domain/renewal.dart`) com teste.
3. **Widgets genéricos:** extrair `DateBlock` do `DeadlineCard` (visual idêntico); `StatusBanner`; `StatusChip.icon`; `showConfirmDialog(dismissLabel:)`. Testes e `docs/07-design-system.md`.
4. **Apresentação base:** providers novos e rótulos novos em `deadline_labels.dart`, com testes.
5. **Rotas e detalhe somente leitura:** `AppRoutes.deadline`, rotas, `DeadlineDetailScreen` com faixa, dados, histórico e barra/menu **sem ações**; o card do módulo passa a abrir o detalhe. Testes.
6. **Ações:** `deadline_action_sheets.dart` (renovar e concluir), cancelar, reabrir, excluir, SnackBars e navegação. Testes.
7. **Módulo:** segmentado "Em aberto | Encerrados". Testes.
8. **Fechamento:** `dart format .`, `flutter analyze`, `flutter test`; conferir no emulador (empresa → módulo → prazo → renovar → histórico → concluir/reabrir → cancelar → excluir → Encerrados); critérios de aceite, journal, status (README e `tasks/README.md`), roadmap (`docs/05-roadmap.md`), `docs/07-design-system.md`, `docs/06-perguntas-em-aberto.md`.

## Arquivos

```
lib/app/router.dart                                  # AppRoutes.deadline, rota prazos/:prazo com editar aninhada
lib/app/widgets/date_block.dart                      # novo (extraído do DeadlineCard)
lib/app/widgets/deadline_card.dart                   # usa DateBlock
lib/app/widgets/status_banner.dart                   # novo
lib/app/widgets/status_chip.dart                     # + icon opcional
lib/app/widgets/confirm_dialog.dart                  # + dismissLabel
lib/features/deadlines/domain/renewal.dart           # novo: suggestedRenewalDate
lib/features/deadlines/presentation/
├── deadline_providers.dart        # + deadlineProvider, deadlineHistoryProvider, moduleClosedDeadlinesProvider
├── deadline_labels.dart           # + situationLabel, situationIcon, deadlineBanner, alertCaption, cycleRangeLabel, cycleTitle
├── deadline_detail_screen.dart    # novo: DeadlineDetailScreen
├── deadline_action_sheets.dart    # novo: showRenewSheet, showCompleteSheet
└── module_screen.dart             # segmentado, card → detalhe, encerrados

test/helpers/fake_deadline_repository.dart           # passo 1
test/features/deadlines/domain/renewal_test.dart
test/app/widgets/date_block_test.dart
test/app/widgets/status_banner_test.dart
test/app/widgets/status_chip_test.dart               # novo (não existe hoje)
test/app/widgets/confirm_dialog_test.dart            # + dismissLabel
test/app/widgets/deadline_card_test.dart             # segue verde
test/features/deadlines/presentation/deadline_labels_test.dart   # + rótulos novos
test/features/deadlines/presentation/deadline_detail_screen_test.dart   # novo
test/features/deadlines/presentation/module_screen_test.dart     # ajustar + encerrados
```

## Rotas

```dart
// AppRoutes
static String deadline(String companyId, ModuleType m, String id) =>
    '${module(companyId, m)}/prazos/$id';
static String editDeadline(String companyId, ModuleType m, String id) =>
    '${deadline(companyId, m, id)}/editar';   // mesma URL de antes
```

No `router.dart`, em `modulos/:modulo`, depois de `prazos/novo`:

```
prazos/:prazo → DeadlineDetailScreen(companyId, slug, deadlineId), parentNavigatorKey: rootKey
  └─ editar   → DeadlineFormScreen(companyId, slug, deadlineId), parentNavigatorKey: rootKey
```

Remover a rota irmã `prazos/:prazo/editar`. Pilha ao abrir o detalhe com `go`: lista de empresas → empresa → módulo → detalhe; ao editar: … → detalhe → editar. O formulário já faz `context.pop()` ao salvar.

## Domínio: `suggestedRenewalDate` (`domain/renewal.dart`, Dart puro)

```dart
/// Sugestão de novo vencimento: o mesmo intervalo, em meses, entre o ciclo
/// anterior e o atual; sem ciclo anterior (ou intervalo < 1 mês), 12 meses.
/// O dia é o do vencimento, limitado ao último dia do mês de destino.
DateTime suggestedRenewalDate(DateTime dueDate, {DateTime? previousDueDate});
```

Regra: `months = (due.year - prev.year) * 12 + (due.month - prev.month)`; se `prev == null` ou `months < 1`, `months = 12`. `total = due.year * 12 + (due.month - 1) + months`; `y = total ~/ 12`, `m = total % 12 + 1`, `day = min(due.day, DateTime(y, m + 1, 0).day)`; retorna `DateTime(y, m, day)`. **[suposição]** (C22): a renovação repete o intervalo do ciclo anterior; sem anterior, um ano. Marcar com `// TODO(RF-PRZ-04):`.

Casos conferidos (teste): `(2026-09-21, prev 2022-09-21)` → `2030-09-21` (48 meses); `(2026-01-31, sem prev)` → `2027-01-31`; `(2026-02-28, prev 2025-02-28)` → `2027-02-28`; `(2026-03-31, prev 2026-02-28)` → `2026-04-30` (1 mês, dia limitado); `(2028-02-29, prev 2027-02-28)` → `2029-02-28`; `(2026-09-21, prev 2026-09-21)` e `prev` posterior → 12 meses → `2027-09-21`.

## Widgets genéricos

- **`DateBlock`** (`date_block.dart`): `DateBlock({required DateTime date, bool showYear = false, required StatusTone tone})`. É o `Container` 48 × 52 do `DeadlineCard` (fundo `resolve(tone).foreground`, `AppRadius.mdAll`, dia em `titleLarge` tabular e mês em `labelSmall` tabular, texto `colorScheme.onPrimary`; com `showYear`, mês + ano de 2 dígitos: `SET 28`). Sem `Semantics` própria (quem o usa descreve). `DeadlineCard` passa a usar `DateBlock`; seu teste não muda.
- **`StatusBanner`** (`status_banner.dart`): `StatusBanner({required StatusTone tone, required DateTime date, bool showYear = false, required String title, String? message})` e `static const double height = 76`. `Container` com fundo `resolve(tone).background`, `AppRadius.lgAll`, padding `AppSpacing.md`, `Row`: `DateBlock`, `SizedBox(width: AppSpacing.md)`, `Expanded(Column)` com `title` em `titleLarge` (cor `resolve(tone).foreground`, 1 linha, reticências) e `message` em `AppTypography.tabular(bodyMedium)` (cor `colorScheme.onSurface`, 1 linha, reticências). `Semantics(label: [title, ?message].join('. '), excludeSemantics: true)`. A situação nunca só por cor: o `title` descreve. **Diverge do wireframe**, que mostra o bloco 56 × 60: vale o 48 × 52 do card, para os dois blocos serem iguais.
- **`StatusChip`**: parâmetro novo `IconData? icon`; `icon ?? iconFor(tone)`. Sem mudar o comportamento atual.
- **`showConfirmDialog`**: parâmetro novo `String dismissLabel = 'Cancelar'` no botão de recusa.
- `docs/07-design-system.md`: linhas de `StatusBanner` ✅ e `DateBlock` ✅ na tabela de componentes (o banner serve a **todas** as situações do detalhe, não só vencido); ícones: concluído `Icons.task_alt`, cancelado `Icons.block` (tabela "Situação do prazo"); tela "Detalhe do prazo" e "Módulo" (segmentado); nota "Nº do documento" fora do detalhe.

## Apresentação

### `deadline_providers.dart` (novos)

```dart
final deadlineProvider = StreamProvider.autoDispose.family<Deadline?, String>(
  (ref, id) => ref.watch(deadlineRepositoryProvider).watchById(id));

final deadlineHistoryProvider = StreamProvider.autoDispose.family<List<Deadline>, String>(
  (ref, id) => ref.watch(deadlineRepositoryProvider).watchHistory(id));

final moduleClosedDeadlinesProvider = StreamProvider.autoDispose
    .family<List<Deadline>, ({String companyId, ModuleType module})>(
  (ref, key) => ref.watch(deadlineRepositoryProvider).watchByCompany(
    key.companyId, module: key.module,
    statuses: {DeadlineStatus.completed, DeadlineStatus.cancelled}));
```

### `deadline_labels.dart` (novos; os atuais não mudam)

```dart
/// Rótulo do chip: Vigente, A vencer, Vencido, Renovado, Concluído, Cancelado.
String situationLabel(DeadlineSituation s);

/// current/dueSoon/overdue: ícone do tom (ok, relógio, x). renewed: Icons.autorenew;
/// completed: Icons.task_alt; cancelled: Icons.block.
IconData situationIcon(DeadlineSituation s);

/// Conteúdo do StatusBanner.
({StatusTone tone, String title, String? message}) deadlineBanner(Deadline d, DateTime today);

/// "Alertas a partir de 29/04/2026" (início no futuro) ou "Alertas desde 29/04/2026".
String alertCaption(Deadline d, DateTime today);

/// Com início: "21/09/2022 → 21/09/2026". Sem: "Vencimento em 21/09/2018".
String cycleRangeLabel(Deadline cycle, DateTime? previousDueDate);

/// "Ciclo atual" para o primeiro da lista (mais novo); "Ciclo anterior" nos demais.
String cycleTitle(int index);
```

`deadlineBanner`:

| Situação | `title` | `message` |
|---|---|---|
| vencido, a vencer, vigente | `deadlineDisplay`: `[lead, text].join(' ')` ("Venceu há 3 dias", "Vence hoje", "Vence em 10 dias", "Em 120 dias") | `alertCaption` |
| concluído | `Concluído em ${formatDate(completedOn)}` | `Vencimento em ${formatDate(dueDate)}` |
| cancelado, renovado | `status.label` | `Vencimento em ${formatDate(dueDate)}` |

`alertCaption`: `d.alertStartDate.isAfter(today)` (comparando só datas) → "Alertas a partir de …", senão "Alertas desde …"; datas com `formatDate`.

## Tela de detalhe (`DeadlineDetailScreen`)

`ConsumerWidget(companyId, slug, deadlineId)`. Estados, em ordem: slug inválido → "Módulo não encontrado"; empresa (`companyProvider`) ausente → "Empresa não encontrada"; `deadlineProvider` com `null`, ou prazo cuja `companyId`/`module` não bate com a rota → "Prazo não encontrado" ("Ele pode ter sido excluído.", ação "Voltar" → `context.go(AppRoutes.module(...))`); erro → "Não foi possível carregar o prazo"; carregando → `CircularProgressIndicator` (todos com `Scaffold(appBar: AppBar())` e `EmptyState`, como `ModuleScreen._message`).

**Faixa:** `AppBar(title: BandTitle(title: d.title, subtitle: '${company.displayName} · ${module.label}'), actions: [menu], bottom: PreferredSize(height: StatusBanner.height + AppSpacing.lg, Padding(fromLTRB(lg, 0, lg, lg), StatusBanner(...))))`. `showYear: d.dueDate.year != today.year`. O botão voltar vem do `AppBar`.

**Menu** (`PopupMenuButton`, `icon: Icons.more_vert`, `tooltip: 'Mais opções'`; itens por estado, nesta ordem):

| Estado | Itens |
|---|---|
| em aberto, licença | Cancelar prazo · Excluir prazo |
| em aberto, laudo/manutenção | Registrar renovação · Cancelar prazo · Excluir prazo |
| concluído ou cancelado | Excluir prazo |
| renovado | sem menu |

**Corpo** (`ListView`, `padding: AppSpacing.screen.copyWith(top: lg, bottom: xl)`):
1. `Card` de dados (como o wireframe: card branco com `InfoRow`s separados por `Divider`, ver `company_detail_screen.dart`): `InfoRow('Categoria', [category.label])`; `InfoRow('Órgão', [authority.label])` só com órgão; `InfoRow('Lembretes', [...])` com **uma linha por lembrete**, na ordem de `reminderDays`: `'${formatDate(date)} · ${reminderLabel(days)}'` (ex.: `29/04/2026 · 150 dias antes`).
2. `SectionCard(title: 'Histórico', children: [for ciclo → _CycleTile])`, `ciclos = ref.watch(deadlineHistoryProvider(id))` (mais novo primeiro). `_CycleTile(index, cycle, previousDueDate = ciclos[index + 1]?.dueDate)`: `Row` com círculo 24 (fundo `resolve(tone).background`, `Icon(situationIcon(s), size: 16, color: foreground)`), `Expanded(Column)` com `cycleTitle(index)` (`bodyLarge` com peso de `labelLarge`) e `cycleRangeLabel` (`AppTypography.tabular(bodyMedium)`), e `StatusChip(compact: true, tone, label: situationLabel(s), icon: situationIcon(s))`. Linha vertical de 2 px (`outlineVariant`) ligando os círculos, exceto no último. Padding vertical `AppSpacing.md`, horizontal `AppSpacing.lg`. A situação de cada ciclo é `cycle.situationOn(today)`. Histórico carregando ou com erro: omitir a seção (o banner e os dados já bastam). `Semantics` do tile: `'${cycleTitle}, ${range}, ${situationLabel}'`.

**Barra** (`AppActionBar`, `bottomNavigationBar`; `null` se renovado):

| Estado | Esquerda (`OutlinedButton.icon`, ícone `Icons.edit_outlined`) | Direita (`FilledButton.icon`, `Expanded`) |
|---|---|---|
| em aberto, licença | Editar | Registrar renovação (`Icons.autorenew`) |
| em aberto, laudo/manutenção | Editar | Concluir (`Icons.task_alt`) |
| concluído ou cancelado | Editar | Reabrir (`Icons.undo`) |

Editar: `context.go(AppRoutes.editDeadline(companyId, module, id))`.

## Ações (`deadline_action_sheets.dart` e a tela)

Em todas: capturar `ScaffoldMessenger.of(context)` e o `GoRouter`/`context` antes do `await`; `try/catch` em `DeadlineException`; depois de um `await`, checar `context.mounted`.

- **Registrar renovação:** `final previous = history.length > 1 ? history[1].dueDate : null` (o ciclo anterior ao atual; se o prazo aberto não é o mais novo da lista, o que não ocorre, ignorar). `suggested = suggestedRenewalDate(d.dueDate, previousDueDate: previous)`. `showRenewSheet(context, deadline: d, suggested: suggested)` devolve `DateTime?`. `null` = fechou sem confirmar. Com data: `final next = await repo.renew(d.id, newDueDate: date)`; `messenger.showSnackBar('Prazo renovado')`; `context.go(AppRoutes.deadline(companyId, module, next.id))`.
- **Concluir:** `showCompleteSheet(context, today: today)` devolve `DateTime?`; `await repo.complete(d.id, completedOn: date)`; SnackBar "Prazo concluído". Fica na mesma tela (o stream atualiza: banner, barra e menu).
- **Cancelar:** `showConfirmDialog(title: 'Cancelar este prazo?', message: '“${d.title}” sai da lista de em aberto e deixa de gerar alertas. Dá para reabrir em Encerrados.', confirmLabel: 'Cancelar prazo', dismissLabel: 'Voltar')` (não destrutivo: é reversível); `await repo.cancel(d.id)`; SnackBar "Prazo cancelado".
- **Reabrir:** sem confirmação; `await repo.reopen(d.id)`; SnackBar "Prazo reaberto".
- **Excluir:** `reopensPrevious = d.isOpen && history.length > 1 && history[1].status == DeadlineStatus.renewed`. `showConfirmDialog(title: 'Excluir este prazo?', message: '“${d.title}” e os lembretes serão excluídos. Não dá para desfazer.${reopensPrevious ? ' O ciclo anterior volta a ficar em aberto.' : ''}', confirmLabel: 'Excluir', destructive: true)`; `await repo.delete(d.id)`; SnackBar "Prazo excluído"; `context.go(AppRoutes.module(companyId, module))`.
- **Erros:** `DeadlineValidationException` com `dueDate` → `deadlineFieldMessage(error)`; `DeadlineNotFoundException` → nada (o stream já mostra "Prazo não encontrado"); qualquer outra `DeadlineException` (ex.: `InvalidDeadlineTransitionException`) → SnackBar "Não foi possível concluir a ação. Tente de novo.".

### Sheets

Um widget privado `_DateSheet` (`StatefulWidget`) com: título (`titleLarge`) e descrição (`bodyMedium`), `AppTextField(readOnly: true, tabular: true, suffixIcon calendário, onTap: _pick)` mostrando `formatDate`, `helperText` opcional e um `FilledButton` de largura total que faz `Navigator.pop(date)`. `padding` com `MediaQuery.viewInsetsOf(context).bottom`, `showDragHandle: true`, `isScrollControlled: true`, `useSafeArea: true`. `_pick`: `_unfocus()` e `showDatePicker(initialDate: date, firstDate: …, lastDate: …)`.

| | `showRenewSheet` | `showCompleteSheet` |
|---|---|---|
| Título | Registrar renovação | Concluir prazo |
| Descrição | O ciclo atual será encerrado e um novo ciclo será aberto com os mesmos lembretes. | Registre quando foi feito. O prazo sai da lista de em aberto e pode ser reaberto. |
| Campo | Novo vencimento * | Concluído em * |
| Data inicial | `suggested` | `today` (só data) |
| `firstDate` | dia seguinte ao vencimento atual | `DateTime(2000)` |
| `lastDate` | `DateTime(2100)` | `today` |
| `helperText` | `Alertas a partir de ${formatDate(reminderDate(date, deadline.alertDaysBefore))}` (atualiza ao escolher) | — |
| Botão | Renovar | Concluir |

Como `firstDate` é o dia seguinte ao vencimento, o sheet nunca devolve data inválida; o erro `notAfterPrevious` do repositório fica só como defesa (corrida).

## Tela do módulo (`module_screen.dart`)

- `_Deadlines` vira `ConsumerStatefulWidget` com `bool _closed = false`.
- `AppBar.bottom`: `PreferredSize(height: AppSpacing.minTouch + AppSpacing.lg, ...)` com `BandSegmentedButton<bool>(segments: [(false, 'Em aberto'), (true, 'Encerrados')], selected: _closed, onChanged: …)` — mesmo molde do formulário.
- **Em aberto:** igual a hoje (seções por categoria, FAB "Novo prazo", vazio com "Cadastrar prazo").
- **Encerrados:** `ref.watch(moduleClosedDeadlinesProvider(...))`; lista **plana**, do vencimento mais recente para o mais antigo (inverter a ordem do repositório), de `DeadlineCard` (tom `closed`, texto "Concluído" ou "Cancelado" via `deadlineDisplay`). Sem FAB. Vazio: `EmptyState(icon: Icons.inventory_2_outlined, title: 'Nenhum prazo encerrado', message: 'Prazos concluídos ou cancelados aparecem aqui.')` (sem ação). Erro: mesmo `EmptyState` de erro de hoje.
- **Os dois segmentos:** `onTap` do card → `context.go(AppRoutes.deadline(company.id, module, d.id))` (remove o `TODO(RF-PRZ-04)`).
- **[suposição]** (C22): renovados não aparecem em Encerrados; só no histórico do ciclo atual. Evita listar cada ciclo antigo ao lado do seu sucessor.

## Wireframe

`docs/design/wireframes/PrazoDetalhe.dc.html` já foi ajustado na refinação: sem a linha "Nº do documento"; "Alerta" virou "Lembretes" com uma linha por aviso; o ciclo mais antigo mostra "Vencimento em 21/09/2022" (sem início). O bloco de data do banner no wireframe é 56 × 60; na implementação é o `DateBlock` de 48 × 52.

## Testes (casos obrigatórios)

Relógio fixo `testNow = 2026-09-29` (`pumpApp`). Dados de referência: licença "Licença de Operação" SEMACE, vencimento `2026-09-26`, lembretes padrão `[150, 30, 10, 3, 0]` → situação "vencido", `daysUntilDue = -3`, `alertStartDate = 2026-04-29`.

- **`renewal_test.dart`:** os seis casos da seção de domínio.
- **`date_block_test.dart`:** dia com dois dígitos e mês em maiúsculas; `showYear` mostra "SET 28"; fundo na cor forte do tom.
- **`status_banner_test.dart`:** título e mensagem aparecem; mensagem ausente não ocupa linha; `Semantics.label` junta título e mensagem; cada tom usa o fundo suave.
- **`status_chip_test.dart`:** ícone do tom por padrão; `icon` sobrepõe; `Semantics` "Situação: …".
- **`confirm_dialog_test.dart`:** `dismissLabel: 'Voltar'` troca o texto do botão de recusa e `Voltar` devolve `false`.
- **`deadline_labels_test.dart`:** `situationLabel` e `situationIcon` para as seis situações; `deadlineBanner` (vencido: "Venceu há 3 dias" / "Alertas desde 29/04/2026"; a vencer; vigente com alerta no futuro: "Alertas a partir de …"; concluído em 2026-09-20: "Concluído em 20/09/2026" / "Vencimento em 26/09/2026"; cancelado; renovado); `cycleRangeLabel` com e sem início; `cycleTitle(0)` = "Ciclo atual", `cycleTitle(2)` = "Ciclo anterior".
- **`deadline_detail_screen_test.dart`** (com `FakeDeadlineRepository` do passo 1 e `pumpApp(initialLocation: AppRoutes.deadline(...))`):
  - Leitura: título e "Indústria Alfa Ltda · Ambiental" na faixa; banner "Venceu há 3 dias"; categoria, "SEMACE" (e sem a linha Órgão quando não há), cinco linhas de lembrete; histórico com um ciclo ("Ciclo atual", "Vencimento em 26/09/2026", chip "Vencido").
  - Estados: prazo inexistente → "Prazo não encontrado"; prazo de outra empresa → idem; módulo desligado/slug inválido → mensagens.
  - Licença em aberto: barra com Editar e "Registrar renovação"; menu com "Cancelar prazo" e "Excluir prazo" e **sem** "Registrar renovação"; sem "Concluir".
  - Laudo em aberto: primário "Concluir"; menu com "Registrar renovação".
  - **Renovar:** sheet abre com `2027-09-26` no campo (sem anterior: +12 meses) e helper "Alertas a partir de 29/04/2027"; confirmar → "Prazo renovado", rota do novo ciclo, banner "Em 362 dias" ou equivalente conferido pelo teste (`2027-09-26` − `2026-09-29` = 362 dias), histórico com dois ciclos: "Ciclo atual" ("26/09/2026 → 26/09/2027", "Vigente") e "Ciclo anterior" ("Vencimento em 26/09/2026", "Renovado"). Segunda renovação: sugestão usa o intervalo (12 meses).
  - **Concluir:** sheet com a data de hoje (29/09/2026); confirmar → banner "Concluído em 29/09/2026", barra com "Reabrir", menu só com "Excluir prazo"; **Reabrir** → volta ao estado em aberto, SnackBar "Prazo reaberto".
  - **Cancelar:** diálogo com "Voltar" e "Cancelar prazo"; "Voltar" não muda nada; confirmar → banner "Cancelado" e "Reabrir".
  - **Excluir:** diálogo destrutivo; ciclo renovado como atual mostra o aviso "O ciclo anterior volta a ficar em aberto."; confirmar → volta à tela do módulo, SnackBar "Prazo excluído", o ciclo anterior aparece em aberto na lista.
  - Renovado aberto por URL: sem barra de ações e sem menu.
  - Editar: abre `Editar prazo`; salvar volta ao detalhe (não ao módulo).
- **`module_screen_test.dart`:** ajustar "o card abre a edição" para "o card abre o detalhe" (e `Editar` leva ao formulário); novo: segmentado "Encerrados" lista concluído e cancelado (mais recente primeiro) com "Concluído"/"Cancelado", esconde o FAB, não lista renovados, mostra o vazio "Nenhum prazo encerrado"; tocar abre o detalhe; voltar a "Em aberto" restaura a lista.
- **Regressão:** `company_detail_screen_test`, `deadline_form_screen_test` e `deadline_card_test` seguem verdes.

## Riscos e alternativas descartadas

- **`StatusBanner` com altura fixa** (`AppBar.bottom` exige `PreferredSize`): com fonte do sistema muito grande o texto é cortado com reticências. Aceito; revisar na task de acessibilidade (pendência já anotada no journal da 007).
- **Item de menu "Cancelar prazo" × botão "Cancelar" do diálogo:** resolvido com `dismissLabel: 'Voltar'`.
- **Descartado:** abrir a edição direto do card (substituído pelo detalhe); aba "Encerrados" separada (ficou segmentado); mostrar renovados em Encerrados; seletor de data direto na renovação (sem sugestão); botão "Excluir" no corpo da tela; campo "Nº do documento" (C5/C13); data de emissão por ciclo (C21).
- **Concluir só para laudo e manutenção** é regra do repositório (RF-AMB-06). Licença só se renova ou se cancela.

## Como verificar

```bash
dart format . && flutter analyze && flutter test
flutter run -d emulator-5554   # empresa → módulo → prazo → renovar → concluir/reabrir → cancelar → excluir → Encerrados
```

Checagens no emulador: banner e histórico legíveis em 390 dp; menu ⋮ visível sobre a faixa; sheet sobe com o teclado; voltar do formulário de edição leva ao detalhe; após excluir um ciclo renovado, o anterior reaparece em aberto.

## Perguntas e suposições (registradas em `docs/06-perguntas-em-aberto.md`)

- **C21** (data de início do ciclo): **[suposição]** o início é o vencimento do ciclo anterior; o primeiro ciclo mostra só "Vencimento em …".
- **C13** (anexos) e **C5** ("Nº do documento"): **[suposição]** fora desta task.
- **C22** (nova): **[suposição]** a data sugerida na renovação repete o intervalo do ciclo anterior em meses, ou um ano; renovados só aparecem no histórico, não em Encerrados; concluir pede uma data de conclusão que não pode ser futura.

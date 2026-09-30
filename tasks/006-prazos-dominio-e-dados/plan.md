# Plano técnico — 006

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Nova feature `lib/features/deadlines/` no mesmo formato de `lib/features/companies/`: domínio puro (entidade, enums, normalização, validação, interface e exceções), dados em drift (`deadlines` + tabela filha `deadline_reminders`, schema v2) e um `LocalDeadlineRepository` exposto por provider Riverpod. A situação do prazo é calculada no domínio a partir da data de hoje e nunca é gravada. Renovar fecha o ciclo atual e abre o próximo numa transação, encadeando os ciclos por `previousDeadlineId`.

## Contexto do repositório (em 2026-09-30)

- Flutter 3.47.5 (stable). `drift` 2.35.0, `drift_dev` 2.35.0, `drift_flutter` 0.3.1, `flutter_riverpod` 3.4.3, `uuid` 4.6.0, `collection`, `meta`. **Nenhum pacote novo** nesta task.
- `build.yaml` já configura o drift: datas-hora como texto ISO-8601 UTC, `schema_dir: drift_schemas/`, `test_dir: test/core/database/`. Só existe `drift_schemas/app/drift_schema_v1.json`.
- `AppDatabase` (`lib/core/database/app_database.dart`): tabelas `Companies`, `CompanyModules`, `CompanyAuthorities`; `schemaVersion => 1`; `beforeOpen` liga `PRAGMA foreign_keys = ON`. `converters.dart` tem `DateOnlyConverter` (data sem hora como `AAAA-MM-DD`) e o mixin `EntityColumns` (`id`, `createdAt`, `updatedAt`, `deletedAt`). Convenções em [D008](../../docs/decisoes.md#d008--convenções-de-tabela-drift).
- `core/providers.dart`: `clockProvider` (UTC) e `idGeneratorProvider` (UUID v7). `core/utils/clock.dart` define `typedef Clock`; `id_generator.dart` define `typedef IdGenerator`.
- Domínio de empresas reutilizado aqui: `ModuleType` e `Authority` (enums com `code`/`label`, `fromCode`), `Company.hasModule`, `CompanyNotFoundException` (em `company_repository.dart`). Modelo de referência para estilo: `local_company_repository.dart` (stream via `customSelect('SELECT 1', readsFrom: …).watch().asyncMap`, `distinct`, transações, upsert de filhos reaproveitando linha excluída).
- **Armadilha 1:** `drift_dev make-migrations` **não sobrescreve** `test/core/database/migration_test.dart` se ele já existir (confirmado em `drift_dev-2.35.0/lib/src/cli/commands/make_migrations.dart`, `writeTest`). O arquivo atual é escrito à mão para a v1. Renomeie-o para `schema_test.dart` **antes** de rodar `make-migrations` (passo 4).
- **Armadilha 2:** `LocalCompanyRepository.delete` faz exclusão lógica em cascata só de módulos e registros. Passa a precisar excluir também os prazos da empresa (passo 5).
- Testes de repositório usam `NativeDatabase.memory()`, relógio fixo e ids `'id-1'`, `'id-2'`… (ver `test/features/companies/data/local_company_repository_test.dart`). `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true` no `setUp`.
- `tasks/**` fica fora do `flutter analyze`.

## Ordem de implementação

Branch: `task/006-prazos-dominio-e-dados` (já criada). Um commit por passo, no formato `feat(prazos): <o quê> [task 006, RF-PRZ-01]` (use o RF principal do passo), terminando com a linha de coautoria que o harness indicar. Registre cada passo no `journal.md` enquanto avança. Status → `em andamento` no primeiro commit de código.

1. Domínio: enums, `Deadline`, `DeadlineInput`, normalização, validação, situação, interface e exceções, com testes (`test/features/deadlines/domain/`).
2. Tabelas `Deadlines` e `DeadlineReminders` e mapper.
3. `AppDatabase` v2 com migração: `git mv test/core/database/migration_test.dart test/core/database/schema_test.dart` (e troque o texto do comentário do topo para dizer que ele cobre o schema atual; o teste `'schema v1 bate com o dump'` continua valendo); `schemaVersion => 2`; `dart run build_runner build --delete-conflicting-outputs`; `dart run drift_dev make-migrations`; preencher `from1To2` em `migration`; completar o teste de dados gerado.
4. `LocalDeadlineRepository` e provider, com testes de banco em memória.
5. Cascata na exclusão de empresa (`LocalCompanyRepository.delete`), com teste.
6. Docs: `docs/03-dominio.md` (modelo e regras), `docs/06-perguntas-em-aberto.md` (C20, C21), `docs/decisoes.md` (D011).
7. `dart format .`, `flutter analyze` e `flutter test` sem erros. Marque os critérios no `README.md`, entrada final no journal, status `concluída` aqui e em `tasks/README.md`. Em `docs/05-roadmap.md`, anote no item "CRUD de prazos…" e no item "Renovação com histórico" que o domínio e os dados vieram na task 006 (sem marcar `[x]`: as telas ainda faltam).

## Setup

Sem pacotes novos. Comandos:

```bash
dart run build_runner build --delete-conflicting-outputs   # regenera app_database.g.dart
dart run drift_dev make-migrations                          # gera v2.json, steps e testes
```

`make-migrations` (drift_dev 2.35.0) com duas versões de schema gera:
- `drift_schemas/app/drift_schema_v2.json`;
- `lib/core/database/app_database.steps.dart` com `stepByStep({required Future<void> Function(Migrator m, Schema2 schema) from1To2})`;
- `test/core/database/generated/schema_v2.dart` e atualiza `generated/schema.dart`;
- `test/core/database/migration_test.dart` (só se não existir) com um teste de migração por par de versões e um modelo de teste de integridade de dados.

> **Correção (2026-09-30, na implementação):** com `databases: app:` no `build.yaml`, os arquivos de teste vão para `test/core/database/app/` (`migration_test.dart` e `generated/`). A pasta `test/core/database/generated/` da task 002 foi removida e `schema_test.dart` passou a não depender dela. Ver journal.

Commite todos os arquivos gerados (como na task 002).

## Arquivos

```
lib/features/deadlines/
├── domain/
│   ├── deadline_category.dart      # DeadlineCategory
│   ├── deadline_status.dart        # DeadlineStatus, DeadlineSituation
│   ├── deadline.dart               # Deadline, DeadlineInput
│   ├── deadline_validation.dart    # normalização, validação, DeadlineFieldError
│   └── deadline_repository.dart    # interface + exceções
└── data/
    ├── deadline_tables.dart        # Deadlines, DeadlineReminders
    ├── deadline_mapper.dart
    └── local_deadline_repository.dart   # + deadlineRepositoryProvider
lib/core/database/app_database.dart        # + tabelas, v2, migration
lib/core/database/app_database.steps.dart  # gerado
lib/features/companies/data/local_company_repository.dart   # cascata no delete

test/features/deadlines/domain/enums_test.dart
test/features/deadlines/domain/deadline_test.dart
test/features/deadlines/domain/deadline_validation_test.dart
test/features/deadlines/data/local_deadline_repository_test.dart
test/features/companies/data/local_company_repository_test.dart   # + caso de cascata
test/core/database/schema_test.dart        # renomeado do migration_test atual
test/core/database/migration_test.dart     # gerado + teste de dados
```

`domain/` só importa `package:meta`, `package:collection` e outros arquivos de domínio (inclusive `features/companies/domain/`). Nada de Flutter ou drift.

## Valores de referência

`code` é persistido e nunca muda (D007). A ordem das listas é a de exibição.

**`DeadlineCategory`** (`code`, rótulo pt-BR, lembretes padrão):

| Valor | `code` | Rótulo | `defaultReminderDays` |
|---|---|---|---|
| `license` | `license` | Licença | `[150, 30, 10, 3, 0]` |
| `labReport` | `lab_report` | Laudo | `[30, 10, 3, 0]` |
| `maintenance` | `maintenance` | Manutenção | `[30, 10, 3, 0]` |

Padrões decididos pela usuária em 2026-09-30 (journal); falta a cliente confirmar (C3). Marque com `// TODO(RF-PRZ-02): padrões por categoria a confirmar com a cliente (C3).`

**`DeadlineStatus`** (estado gravado):

| Valor | `code` | Rótulo |
|---|---|---|
| `active` | `active` | Em aberto |
| `renewed` | `renewed` | Renovado |
| `completed` | `completed` | Concluído |
| `cancelled` | `cancelled` | Cancelado |

**`DeadlineSituation`** (derivada, nunca gravada; sem `code`): `current` (Vigente), `dueSoon` (A vencer), `overdue` (Vencido), `renewed` (Renovado), `completed` (Concluído), `cancelled` (Cancelado). Os rótulos ficam na apresentação (task de telas), como em `company_labels.dart`; aqui o enum não tem `label`.

Os três enums com `code` têm `static fromCode(String)` que lança `ArgumentError.value(code, 'code', '<Enum>')` para código desconhecido, igual a `ModuleType`.

## Domínio

### `Deadline` (`deadline.dart`)

```dart
@immutable
class Deadline {
  Deadline({
    required this.id,
    required this.companyId,
    required this.module,               // ModuleType
    required this.category,             // DeadlineCategory
    this.authority,                     // Authority?
    required this.title,
    required this.dueDate,              // DateTime(y, m, d) local, sem hora
    required List<int> reminderDays,    // guardada ordenada decrescente, sem repetição
    this.status = DeadlineStatus.active,
    this.completedOn,                   // DateTime(y, m, d)? — só com status completed
    this.previousDeadlineId,
    required this.createdAt,            // UTC
    required this.updatedAt,            // UTC
  }) : reminderDays = List.unmodifiable(reminderDays);

  /// Maior valor de [reminderDays]: abre a janela "a vencer" (RF-PRZ-02).
  int get alertDaysBefore => reminderDays.first;

  /// `dueDate` menos [alertDaysBefore] dias, em calendário.
  DateTime get alertStartDate;

  /// Uma data por lembrete, na ordem de [reminderDays] (mais cedo primeiro).
  /// Usado pelas notificações (task futura).
  List<DateTime> get reminderDates;

  /// Dias de calendário de [today] até [dueDate]: 0 no dia, negativo depois.
  int daysUntilDue(DateTime today);

  DeadlineSituation situationOn(DateTime today);

  bool get isOpen => status == DeadlineStatus.active;

  DeadlineInput toInput();

  // == e hashCode sobre todos os campos (reminderDays com ListEquality);
  // toString => 'Deadline($id, $title, $dueDate, ${status.code})'.
}
```

Aritmética de datas (evita erro de horário de verão):
- `daysUntilDue`: `DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(today.year, today.month, today.day)).inDays`. A hora de `today` é ignorada.
- `alertStartDate` e `reminderDates`: `DateTime(due.year, due.month, due.day - n)` (o construtor normaliza o dia negativo).

`situationOn(today)`:
1. `renewed` → `renewed`; `completed` → `completed`; `cancelled` → `cancelled`.
2. `active`: `d = daysUntilDue(today)`. `d < 0` → `overdue`; `d <= alertDaysBefore` → `dueSoon`; senão `current`.

No dia do vencimento (`d == 0`) o prazo está **a vencer**; vencido a partir do dia seguinte (decisão da usuária, 2026-09-30). Com lembretes `[0]`, o prazo só fica "a vencer" no próprio dia.

### `DeadlineInput`

```dart
@immutable
class DeadlineInput {
  const DeadlineInput({
    required this.module,
    required this.category,
    this.authority,
    required this.title,
    required this.dueDate,
    this.reminderDays,   // null = category.defaultReminderDays
  });
  // campos finais, == e hashCode (ListEquality para reminderDays)
}
```

Não tem `companyId` (a empresa é fixa: vai em `create(companyId, input)`), `status`, `completedOn` nem `previousDeadlineId`: esses só mudam pelas ações do repositório.

### Normalização (`normalizeDeadlineInput`)

- `title`: `trim()`; espaços internos repetidos viram um só (`replaceAll(RegExp(r'\s+'), ' ')`).
- `dueDate`: truncado para `DateTime(y, m, d)`.
- `reminderDays`: `null` → `category.defaultReminderDays`; senão remove repetidos e ordena decrescente. Lista vazia continua vazia (a validação acusa).

### Validação (`validateDeadline(DeadlineInput) → List<DeadlineFieldError>`)

Sobre o input já normalizado. `DeadlineField { title, dueDate, reminderDays }`, `DeadlineFieldErrorType { required, invalid, notAfterPrevious }`, `DeadlineFieldError(field, type)` com `==`/`hashCode`/`toString` como `CompanyFieldError`.

| Campo | Regra | Erro |
|---|---|---|
| `title` | vazio depois de normalizar | `required` |
| `reminderDays` | lista vazia | `required` |
| `reminderDays` | algum valor `< 0` | `invalid` |

Órgão é opcional em qualquer categoria (decisão da usuária). Não há limite superior de lembretes nem restrição de data no passado (um prazo já vencido pode ser cadastrado). `notAfterPrevious` só é usado em `renew` (ver abaixo).

**[suposição]** Qualquer categoria em qualquer módulo (ex.: laudo em Produtos controlados). `// TODO(RF-PRZ-01): categorias permitidas por módulo (C20).`

### `DeadlineRepository` (`deadline_repository.dart`)

```dart
abstract interface class DeadlineRepository {
  /// Não excluídos da empresa, com [statuses] (padrão: só em aberto), do
  /// módulo se informado. Ordem: dueDate, depois título normalizado
  /// (`normalizeForSearch`), depois id.
  Stream<List<Deadline>> watchByCompany(
    String companyId, {
    ModuleType? module,
    Set<DeadlineStatus> statuses = const {DeadlineStatus.active},
  });

  /// Próximos vencimentos de todas as empresas (RF-PRZ-05): prazos em aberto,
  /// não excluídos, de empresas não excluídas e não arquivadas, cujo módulo
  /// está habilitado na empresa. Mesma ordem de [watchByCompany].
  Stream<List<Deadline>> watchUpcoming();

  /// `null` se não existe ou está excluído.
  Stream<Deadline?> watchById(String id);
  Future<Deadline?> findById(String id);

  /// Ciclos da cadeia que contém [id] (anteriores e posteriores), sem os
  /// excluídos, do mais novo para o mais antigo. Vazio se [id] não existe ou
  /// está excluído.
  Stream<List<Deadline>> watchHistory(String id);

  /// Lança [DeadlineValidationException], [CompanyNotFoundException] ou
  /// [ModuleNotEnabledException].
  Future<Deadline> create(String companyId, DeadlineInput input);

  /// Qualquer status. Lança [DeadlineValidationException],
  /// [DeadlineNotFoundException] ou [ModuleNotEnabledException].
  Future<Deadline> update(String id, DeadlineInput input);

  /// Fecha o ciclo e abre o próximo (RF-PRZ-04). Só `active`. Lança
  /// [DeadlineNotFoundException], [InvalidDeadlineTransitionException] ou
  /// [DeadlineValidationException] (`dueDate`, `notAfterPrevious`).
  Future<Deadline> renew(String id, {required DateTime newDueDate});

  /// Só `active` e categoria laudo ou manutenção. Lança
  /// [DeadlineNotFoundException] ou [InvalidDeadlineTransitionException].
  Future<void> complete(String id, {required DateTime completedOn});

  /// Só `active`. Lança [DeadlineNotFoundException] ou
  /// [InvalidDeadlineTransitionException].
  Future<void> cancel(String id);

  /// `completed` ou `cancelled` → `active` (desfazer). Lança
  /// [DeadlineNotFoundException] ou [InvalidDeadlineTransitionException].
  Future<void> reopen(String id);

  /// Exclusão lógica do prazo e dos lembretes. Lança [DeadlineNotFoundException].
  Future<void> delete(String id);
}

enum DeadlineAction { renew, complete, cancel, reopen }

sealed class DeadlineException implements Exception { const DeadlineException(); }
final class DeadlineValidationException extends DeadlineException { final List<DeadlineFieldError> errors; }
final class DeadlineNotFoundException extends DeadlineException { final String id; }
final class ModuleNotEnabledException extends DeadlineException { final String companyId; final ModuleType module; }
final class InvalidDeadlineTransitionException extends DeadlineException {
  final String id; final DeadlineStatus status; final DeadlineAction action;
}
```

Todas com construtor `const` e `toString` no formato `'Nome(campos)'`, como as exceções de empresa. `CompanyNotFoundException` é a de `features/companies/domain/company_repository.dart`.

## Regras

Todas as escritas rodam em `_db.transaction`. `now = clock()` (UTC) uma vez por operação; toda linha alterada recebe `updatedAt = now`.

- **Empresa viva:** `create` exige empresa não excluída (arquivada é aceita). Senão `CompanyNotFoundException(companyId)`.
- **Módulo habilitado:** `create` e `update` exigem que `input.module` esteja habilitado na empresa (linha viva em `company_modules` com `enabled = true`). Senão `ModuleNotEnabledException`. Ordem das checagens em `create`: validação → empresa → módulo. Em `update`: existência do prazo → validação → módulo.
- **`update`:** grava título, módulo, categoria, órgão, vencimento e lembretes; não muda status, `completedOn` nem a cadeia. Se nada mudou (compare `deadline.toInput()` com o input normalizado), não escreve e não muda `updatedAt`. Se só os lembretes mudaram, o `updatedAt` do prazo **também** é atualizado (evita o problema anotado na task 002, em que mudar só filhos não tocava a empresa).
- **Sincronizar lembretes:** para cada valor desejado, reaproveite a linha `(deadline_id, days_before)` se existir (mesmo excluída: `deletedAt = null`); senão insira. Linhas vivas com valor que saiu da lista recebem `deletedAt = now`. Mesmo padrão de `_syncRegistrations`.
- **`renew(id, newDueDate)`:** exige `active` (senão `InvalidDeadlineTransitionException(id, status, DeadlineAction.renew)`). `newDueDate` truncado para data; se não for **posterior** ao `dueDate` atual → `DeadlineValidationException([DeadlineFieldError(DeadlineField.dueDate, DeadlineFieldErrorType.notAfterPrevious)])`. **[suposição]** `// TODO(RF-PRZ-04): nova data sempre posterior à anterior (C20).` Efeito: o atual vira `renewed`; um novo prazo é inserido com novo id, mesma empresa, módulo, categoria, órgão, título e lembretes, `dueDate = newDueDate`, `status = active`, `previousDeadlineId = id`. Retorna o novo. Renovar um prazo vencido é permitido. Não precisa checar módulo habilitado (é continuação).
- **`complete(id, completedOn)`:** exige `active` e categoria `labReport` ou `maintenance` (licença → `InvalidDeadlineTransitionException(..., DeadlineAction.complete)`). Grava `status = completed` e `completedOn` truncado para data. Sem validação da data (pode ser passada ou futura).
- **`cancel(id)`:** exige `active`. Grava `status = cancelled`.
- **`reopen(id)`:** exige `completed` ou `cancelled` (um `renewed` não reabre: teria dois ciclos abertos). Grava `status = active` e `completedOn = null`.
- **Idempotência:** as ações não são idempotentes; repetir `cancel` num cancelado lança `InvalidDeadlineTransitionException`. A UI só oferece a ação válida.
- **`delete(id)`:** exclusão lógica do prazo e dos lembretes vivos. Se o prazo excluído está **em aberto** (é o ciclo atual), tem `previousDeadlineId` e o anterior está vivo e `renewed`, o anterior volta a `active` (excluir o ciclo novo desfaz a renovação). **[suposição]** `// TODO(RF-PRZ-04): excluir o ciclo atual reabre o anterior (C20).` Excluir um ciclo antigo não muda os outros.
- **Exclusão da empresa:** `LocalCompanyRepository.delete` passa a excluir logicamente, na mesma transação, os prazos vivos da empresa e os lembretes vivos desses prazos (`deadline_id IN (SELECT id FROM deadlines WHERE company_id = ?)`). Arquivar a empresa não mexe nos prazos: eles só somem de `watchUpcoming`.
- **Módulo desabilitado:** os prazos continuam gravados e aparecem em `watchByCompany`, mas saem de `watchUpcoming`. Reabilitar o módulo traz de volta. **[suposição]** `// TODO(RF-EMP-02): prazos de módulo desabilitado somem do painel (C20).`
- **`watchHistory(id)`:** a partir da linha `id` (viva), sobe por `previousDeadlineId` e desce procurando a linha viva com `previous_deadline_id = atual`, passando **por dentro** de linhas excluídas (não as retorna, mas continua a cadeia). Limite de 1000 passos por direção como proteção contra ciclo.
- **Streams:** `_watch` observa `deadlines`, `deadline_reminders`, `companies` e `company_modules` (a última importa para `watchUpcoming`), com `.distinct(ListEquality().equals)` nas listas e `.distinct()` no item.

## Dados

Arquivo `lib/features/deadlines/data/deadline_tables.dart`, no estilo de `company_tables.dart`:

```dart
@TableIndex.sql(
  'CREATE INDEX deadlines_company_due ON deadlines (company_id, due_date) '
  'WHERE deleted_at IS NULL',
)
@TableIndex.sql(
  'CREATE INDEX deadlines_status_due ON deadlines (status, due_date) '
  'WHERE deleted_at IS NULL',
)
@TableIndex.sql(
  'CREATE UNIQUE INDEX deadlines_previous_live ON deadlines (previous_deadline_id) '
  'WHERE previous_deadline_id IS NOT NULL AND deleted_at IS NULL',
)
@DataClassName('DeadlineRow')
class Deadlines extends Table with EntityColumns {
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get module => text()();            // ModuleType.code
  TextColumn get category => text()();          // DeadlineCategory.code
  TextColumn get authority => text().nullable()();   // Authority.code
  TextColumn get title => text()();
  TextColumn get dueDate => text().map(const DateOnlyConverter())();
  TextColumn get status => text()();            // DeadlineStatus.code
  TextColumn get completedOn => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get previousDeadlineId =>
      text().nullable().references(Deadlines, #id)();
}

@DataClassName('DeadlineReminderRow')
class DeadlineReminders extends Table with EntityColumns {
  TextColumn get deadlineId => text().references(Deadlines, #id)();
  IntColumn get daysBefore => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {deadlineId, daysBefore},
  ];
}
```

- `due_date` é `AAAA-MM-DD`, então a ordem textual é a cronológica; ordenar e filtrar por ela direto no SQL.
- O índice único `deadlines_previous_live` impede duas renovações vivas do mesmo ciclo (proteção de banco para a regra de `renew`).
- O mapper (`deadline_mapper.dart`) segue `company_mapper.dart`: `deadlineFromRows(DeadlineRow, Iterable<DeadlineReminderRow>)` (só lembretes vivos), `deadlineDataCompanion(DeadlineInput)` e `deadlineInputFromRow`. Código desconhecido vindo do banco lança `ArgumentError`.
- Carregar os lembretes em lote (`deadlineId.isIn(ids)` + `groupListsBy`), como `_assemble` em empresas.

### `AppDatabase` v2

```dart
@DriftDatabase(tables: [
  Companies, CompanyModules, CompanyAuthorities, Deadlines, DeadlineReminders,
])
// ...
int get schemaVersion => 2;

MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: stepByStep(
    from1To2: (m, schema) async {
      await m.createTable(schema.deadlines);
      await m.createTable(schema.deadlineReminders);
      await m.createIndex(schema.deadlinesCompanyDue);
      await m.createIndex(schema.deadlinesStatusDue);
      await m.createIndex(schema.deadlinesPreviousLive);
    },
  ),
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

Importe `app_database.steps.dart`. Os getters de índice em `Schema2` são o nome do índice em camelCase; confira no arquivo gerado. `onCreate` fica o padrão (`createAll`).

## Providers

Em `local_deadline_repository.dart`, como em empresas:

```dart
final deadlineRepositoryProvider = Provider<DeadlineRepository>(
  (ref) => LocalDeadlineRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
```

Providers de apresentação (`StreamProvider`) ficam para a task de telas.

## Interface

Nenhuma nesta task.

## Testes

Datas de exemplo conferidas com script (`python3`, `datetime.date - timedelta`): vencimento **2026-10-31** com lembretes `[150, 30, 10, 3, 0]` → `alertStartDate` **2026-06-03**; `reminderDates` **2026-06-03, 2026-10-01, 2026-10-21, 2026-10-28, 2026-10-31**. Com lembretes `[30, 10, 3, 0]` → `alertStartDate` **2026-10-01**.

| Arquivo | Cobre |
|---|---|
| `test/features/deadlines/domain/enums_test.dart` | `fromCode(x.code) == x` para `DeadlineCategory` e `DeadlineStatus`; `code` únicos; desconhecido lança; padrões por categoria (tabela acima) |
| `test/features/deadlines/domain/deadline_test.dart` | com vencimento 2026-10-31 e `[150, 30, 10, 3, 0]`: `situationOn` em 2026-06-02 → `current`, 2026-06-03 → `dueSoon`, 2026-10-31 → `dueSoon`, 2026-11-01 → `overdue`; `daysUntilDue` (151, 150, 0, −1) e ignorando a hora de `today`; lembretes `[0]` → `current` na véspera e `dueSoon` no dia; `renewed`/`completed`/`cancelled` retornam a situação própria mesmo vencidos; `alertDaysBefore`, `alertStartDate`, `reminderDates`; `reminderDays` imutável; igualdade e `toInput()` |
| `test/features/deadlines/domain/deadline_validation_test.dart` | normalização (trim, espaços internos, data truncada, `null` → padrão da categoria, repetidos removidos e ordem decrescente); título vazio → `required`; lista vazia → `required`; valor negativo → `invalid`; input mínimo válido; sem órgão é válido |
| `test/features/deadlines/data/local_deadline_repository_test.dart` | create → findById igual, com lembretes padrão; empresa inexistente/excluída → `CompanyNotFoundException`; módulo desabilitado → `ModuleNotEnabledException`; update troca campos e mantém `createdAt`; update sem mudança não toca `updatedAt`; mudar só lembretes atualiza `updatedAt` e reaproveita linha excluída (remover 10 e readicionar não cria linha nova); `renew` fecha o atual, cria o próximo com `previousDeadlineId` e mesmos dados; `renew` com data igual/anterior → `notAfterPrevious`; `renew` de não-ativo → `InvalidDeadlineTransitionException`; `complete` de manutenção grava data; `complete` de licença lança; `cancel` e `reopen` (e `reopen` de `renewed` lança); `delete` some de `findById`/listas e exclui lembretes; `delete` do ciclo novo reabre o anterior; `watchHistory` com 3 ciclos (a partir do primeiro e do último; com o do meio excluído a cadeia continua); `watchByCompany` com filtro de módulo e de status e ordenação; `watchUpcoming` exclui empresa arquivada, empresa excluída, módulo desabilitado, cancelado, concluído e renovado; `watchUpcoming` emite de novo depois de `renew` |
| `test/features/companies/data/local_company_repository_test.dart` | + excluir empresa exclui logicamente os prazos e lembretes dela e não mexe nos de outra empresa |
| `test/core/database/schema_test.dart` | o atual `migration_test.dart` renomeado (dump v1, banco novo bate com o código, índice de CNPJ e FKs) |
| `test/core/database/migration_test.dart` | gerado: migração v1 → v2 valida o schema; completar o teste de dados: uma empresa com módulo gravada na v1 continua igual na v2 |

No teste de repositório, crie as empresas com `LocalCompanyRepository` no mesmo banco (com `enabledModules`) em vez de inserir linhas à mão.

## Como verificar (definição de pronto)

```bash
dart run build_runner build --delete-conflicting-outputs   # sem diff nos .g.dart
dart run drift_dev make-migrations                          # sem diff (schema v2 já gerado)
dart format . && flutter analyze && flutter test
grep -rE "package:(flutter|drift)" lib/features/deadlines/domain   # deve sair vazio
```

- `test/widget_test.dart` e todos os testes existentes continuam passando.
- Todos os critérios de aceite do `README.md` marcados, ou justificados no journal.

## Docs a atualizar (passo 6)

- `docs/03-dominio.md`: no diagrama, `Deadline` com `companyId`, `module`, `category`, `authority`, `title`, `dueDate`, `status "active | renewed | completed | cancelled"`, `completedOn`, `previousDeadlineId`; remova `alertDaysBefore` e adicione `Deadline ||--o{ DeadlineReminder : lembra` com `DeadlineReminder { int daysBefore }`. Nas regras: situação derivada do maior lembrete, "a vencer" no próprio dia do vencimento, concluir e reabrir, e excluir o ciclo atual reabre o anterior.
- `docs/06-perguntas-em-aberto.md`: **C20** (confirmar as suposições desta task: qualquer categoria em qualquer módulo; nova data de renovação sempre posterior; excluir o ciclo atual reabre o anterior; prazos de módulo desabilitado somem do painel) e **C21** (o ciclo tem data de início ou emissão própria? Hoje o início de um ciclo é o vencimento do anterior e o primeiro ciclo não tem início).
- `docs/decisoes.md`: **D011 — Lembretes de prazo em tabela filha**: lista de dias por prazo em `deadline_reminders`; o maior valor abre a janela "a vencer". Alternativa descartada: coluna de texto com a lista (não indexa e não segue a convenção de tabelas com id e exclusão lógica).
- `docs/07-design-system.md`: na tabela "Situação do prazo", nota de que `completed` e `cancelled` usam `statusClosed`, como renovado (a UI é da próxima task; só registre).

## Riscos e alternativas

- **Nº do documento** (wireframe `PrazoDetalhe`) continua fora do modelo, esperando C5/C13. Acrescentar depois é uma coluna nullable numa migração nova.
- **Agrupamento "ETE e ETA"** no wireframe `ModuloAmbiental` (e "Manutenção · ETE") depende de `TreatmentStation`, da Fase 2. Por ora a UI pode agrupar por categoria.
- **Situação calculada no Dart:** `watchUpcoming` devolve todos os prazos em aberto e a UI calcula a situação com a data de hoje. Com o volume esperado (dezenas a centenas de prazos) isso não pesa; se crescer, filtrar por `due_date` no SQL.
- *Descartado:* lembretes numa coluna de texto (`"150,30,10,3,0"`). A usuária escolheu tabela filha (2026-09-30).
- *Descartado:* `alertDaysBefore` separado dos lembretes. Seriam duas fontes para a mesma janela.
- *Descartado:* gravar a situação. Viola a regra do `CLAUDE.md` (valores derivados são calculados).
- *Descartado:* renovar editando o próprio prazo. Perde o histórico exigido por RF-PRZ-04.

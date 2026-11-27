# Plano técnico — 013

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Uma estrutura genérica **parâmetro + medição por período** (D005, `docs/03-dominio.md`). Um parâmetro é um ponto de ruído ou um parâmetro de estação (pH, insumo…) de uma empresa, com contexto, unidade, frequência, data de início e limites opcionais. Uma medição é o valor (ou a justificativa de "sem medição") de um parâmetro num período, identificado pela data de início do período (o próprio dia, a segunda-feira da semana ISO, o dia 1 ou 16 da quinzena, ou o dia 1 do mês). Pendências são **calculadas** no domínio a partir dos parâmetros e das medições; nada derivado vai para o banco. Banco v2 → v3 com duas tabelas novas.

## Contexto do repositório (em 2026-11-26)

- Flutter com Dart `^3.13.4`; `drift` 2.35.0 e `drift_dev` 2.35.0 (pub cache); `flutter_riverpod` 3.4; `collection`, `meta`, `uuid` já no `pubspec.yaml`. **Nenhum pacote novo** nesta task.
- `AppDatabase` (`lib/core/database/app_database.dart`) está na v2 (`currentSchemaVersion = 2`), com `stepByStep(from1To2: …)` vindo de `app_database.steps.dart` (gerado). Tabelas: `companies`, `company_modules`, `company_authorities` (v1), `deadlines`, `deadline_reminders` (v2).
- `build.yaml`: `databases: app: lib/core/database/app_database.dart`, `schema_dir: drift_schemas/`, `test_dir: test/core/database/`. O `make-migrations` escreve `drift_schemas/app/drift_schema_vN.json`, `lib/core/database/app_database.steps.dart` e `test/core/database/app/generated/schema_vN.dart` + `schema.dart`; **não sobrescreve** `test/core/database/app/migration_test.dart` (o teste com dados da v3 é escrito à mão, journal da task 006).
- Convenções D008: mixin `EntityColumns` (`id` UUID v7, `createdAt`, `updatedAt`, `deletedAt`), `@DataClassName('XRow')`, datas sem hora com `DateOnlyConverter` (`AAAA-MM-DD`), enums pelo `code` (D007), consulta-gatilho com SQL **único por repositório** (`SELECT 1 AS measurements_changed`).
- Padrões a copiar: `lib/features/deadlines/` (domínio, validação, exceções seladas, mapper, `LocalDeadlineRepository`, provider) e `test/features/deadlines/data/local_deadline_repository_test.dart`.
- `LocalCompanyRepository.delete` (`lib/features/companies/data/local_company_repository.dart`) já exclui logicamente módulos, registros, prazos e lembretes numa transação (`_deleteDeadlines`).
- Backup (D014): `_tablesByVersion` em `lib/features/backup/data/local_backup_service.dart`; testes em `test/features/backup/data/local_backup_service_test.dart` com `schemaVersion: 2` e "backup v1 migrado" esperando `user_version` 2 — passam a usar a versão atual.
- `test/core/database/schema_test.dart` lista os índices parciais esperados.
- Armadilha: `Clock` devolve UTC; "hoje" local = `DateTime.now()` sem hora. O domínio recebe `today` sempre como parâmetro.

## Ordem de implementação

Um commit por passo, direto na `main`, com `dart format .`, `flutter analyze` e `flutter test` verdes e `git push origin main` em seguida. Formato: `tipo(medicoes): … [task 013, RF-AMB-02]`. Journal atualizado a cada passo.

1. **Domínio** (`feat(medicoes): domínio de parâmetros, medições e pendências`): enums, período, entidades, validação, pendências, exceções, interface do repositório + testes de domínio. Status → `em andamento`.
2. **Tabelas e migração v3** (`feat(medicoes): tabelas e migração v2 → v3`): tabelas, `AppDatabase` v3, `build_runner`, `make-migrations`, `from2To3`, teste de migração com dados, `schema_test.dart`.
3. **Repositório** (`feat(medicoes): repositório local de medições`): mapper, `LocalMeasurementRepository`, provider, cascata na exclusão da empresa + testes.
4. **Backup** (`feat(backup): tabelas de medições no backup v3 [task 013, RNF-04]`): `_tablesByVersion`, última alteração, testes v2 → v3 e ida e volta.
5. **Emulador**: verificação de migração e backup (sem commit de código; entrada no journal).
6. **Fechamento** (`docs(medicoes): fechamento da task 013 e D015`): critérios, journal, status, docs, roadmap, índice.

## Setup

```bash
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev make-migrations
```

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| domain | `lib/features/measurements/domain/measurement_context.dart` | `MeasurementContext` |
| domain | `lib/features/measurements/domain/measurement_frequency.dart` | `MeasurementFrequency` |
| domain | `lib/features/measurements/domain/measurement_period.dart` | `MeasurementPeriod` |
| domain | `lib/features/measurements/domain/measurement_parameter.dart` | `MeasurementParameterInput`, `MeasurementParameter`, `LimitStatus` |
| domain | `lib/features/measurements/domain/measurement.dart` | `MeasurementEntry`, `Measurement` |
| domain | `lib/features/measurements/domain/measurement_validation.dart` | normalização e validação |
| domain | `lib/features/measurements/domain/pending_launch.dart` | `PendingLaunch`, `PendingKind`, `pendingLaunches()` |
| domain | `lib/features/measurements/domain/measurement_repository.dart` | interface + exceções |
| data | `lib/features/measurements/data/measurement_tables.dart` | `MeasurementParameters`, `Measurements` |
| data | `lib/features/measurements/data/measurement_mapper.dart` | linhas ↔ entidades |
| data | `lib/features/measurements/data/local_measurement_repository.dart` | implementação + `measurementRepositoryProvider` |
| core | `lib/core/database/app_database.dart` | tabelas novas, v3, `from2To3` |
| data | `lib/features/companies/data/local_company_repository.dart` | cascata na exclusão |
| data | `lib/features/backup/data/local_backup_service.dart` | `_tablesByVersion[3]`, última alteração |

## Valores de referência

`MeasurementContext` (ordem de exibição; `code` persistido, nunca muda):

| Valor | `code` | Rótulo | `module` | `defaultUnit` |
|---|---|---|---|---|
| `noise` | `noise` | Ruídos | `ModuleType.environmental` | `dB(A)` |
| `effluent` | `effluent` | Controle da ETE | `ModuleType.environmental` | `null` |
| `water` | `water` | Controle da ETA | `ModuleType.environmental` | `null` |

`MeasurementFrequency` (C8, cliente em 2026-11-27: ETA diária; ETE semanal, quinzenal ou mensal; ruídos semanal):

| Valor | `code` | Rótulo | Período |
|---|---|---|---|
| `daily` | `daily` | Diária | o dia |
| `weekly` | `weekly` | Semanal | semana ISO, segunda a domingo |
| `biweekly` | `biweekly` | Quinzenal | dias 1 a 15 e 16 ao último dia do mês **[suposição]** (`// TODO(RF-AMB-07):`, C8) |
| `monthly` | `monthly` | Mensal | dia 1 ao último dia do mês |

`fromCode` lança `ArgumentError` para código desconhecido (como `DeadlineCategory`).

`PendingKind`: `toLaunch` ("A lançar", período corrente) e `overdue` ("Atrasado", período passado). Rótulos ficam na apresentação (task 015); aqui só o enum.

`LimitStatus`: `withinLimits`, `belowMin`, `aboveMax`, `noLimits`.

## Domínio e contratos

Tudo `@immutable`, com `==`/`hashCode`/`toString` como em `Deadline`. Datas "só a data" são `DateTime(y, m, d)` locais.

```dart
/// Período de lançamento. Só se cria por [containing], então [start] é
/// sempre o início do período da frequência (tabela acima).
class MeasurementPeriod implements Comparable<MeasurementPeriod> {
  factory MeasurementPeriod.containing(MeasurementFrequency f, DateTime date);
  final MeasurementFrequency frequency;
  final DateTime start;          // inclusivo
  DateTime get end;              // inclusivo: o dia / domingo / dia 15 ou último / último dia do mês
  MeasurementPeriod get next;
  MeasurementPeriod get previous;
  bool contains(DateTime date);  // ignora a hora
  int get isoWeek;               // só semanal; StateError se mensal
  int get isoWeekYear;           // ano da semana ISO (2026-12-28 → 2026, semana 53)
  int compareTo(other);          // por start; frequências diferentes → ArgumentError
}
```

- Semana ISO: começa na segunda (`date.weekday == 1`). `isoWeek`: quinta da semana = `start + 3 dias`; ano = ano da quinta; semana = `(diaDoAnoDaQuinta - 1) ~/ 7 + 1`. Aritmética de dias com o construtor `DateTime(y, m, d + n)` (sem `Duration`, por causa do horário de verão); diferença de dias com `DateTime.utc`.

```dart
class MeasurementParameterInput {
  const MeasurementParameterInput({
    required this.name, this.unit, required this.frequency,
    required this.startDate, this.limitMin, this.limitMax});
  final String name;
  final String? unit;
  final MeasurementFrequency frequency;
  final DateTime startDate;      // a partir de quando cobra lançamento
  final double? limitMin;
  final double? limitMax;
}

class MeasurementParameter {
  // id, companyId, context, name, unit, frequency, position, startDate,
  // limitMin, limitMax, archivedAt (UTC, null = ativo), createdAt, updatedAt
  bool get isArchived;
  MeasurementPeriod get firstPeriod;      // containing(frequency, startDate)
  LimitStatus check(double value);        // < min → belowMin; > max → aboveMax (estritos)
  MeasurementParameterInput toInput();
}

class MeasurementEntry {                  // o que se digita para um parâmetro num período
  const MeasurementEntry({this.value, this.note});
  final double? value;
  final String? note;                     // com valor: observação; sem valor: justificativa
}

class Measurement {
  // id, parameterId, periodStart, value, note, createdAt, updatedAt
  bool get isSkipped => value == null;    // "sem medição" com justificativa
}
```

Validação (`measurement_validation.dart`, estilo `deadline_validation.dart`):

- `normalizeParameterInput`: nome `trim` + espaços internos colapsados; unidade idem, vazia → `null`; `startDate` sem hora.
- `validateParameter(input) → List<ParameterFieldError>` com `ParameterField { name, limitMin, limitMax }` e `ParameterFieldErrorType { required, invalid, duplicate, limitsInverted }`: nome vazio → `name/required`; limite não finito (`NaN`, `∞`) → `invalid` no campo; `limitMin > limitMax` → `limitMax/limitsInverted` (iguais é válido). `duplicate` é verificado no repositório: outro parâmetro vivo (arquivado conta) da mesma empresa e contexto com o mesmo `normalizeForSearch(name)` → `name/duplicate`. `normalizeForSearch` está em `lib/core/utils/search_text.dart` (Dart puro; o domínio pode importar `core/utils`).
- `normalizeEntry`: `note` `trim` + colapsar espaços, vazia → `null`.
- `validateEntry(entry) → List<EntryFieldError>` com `EntryField { value, note }`, `EntryFieldErrorType { required, invalid }`: sem valor e sem nota → `note/required` (justificativa obrigatória); valor não finito → `value/invalid`.

Pendências (`pending_launch.dart`):

```dart
class PendingLaunch {
  final String companyId;
  final MeasurementContext context;
  final MeasurementPeriod period;
  final PendingKind kind;
  final int expected;   // parâmetros que cobram no período
  final int filled;     // desses, quantos têm medição (valor ou justificativa)
}

List<PendingLaunch> pendingLaunches({
  required Iterable<MeasurementParameter> parameters,
  required Iterable<Measurement> measurements,
  required DateTime today,
});
```

Regras:

- Só parâmetros **não arquivados** cobram. **[suposição]** arquivar para de cobrar inclusive os períodos passados (`// TODO(RF-AMB-02):`, C26).
- Agrupa por `(companyId, context, frequency)`. Para cada grupo, percorre os períodos do menor `firstPeriod` até o período que contém `today`. Parâmetro com `startDate` futura não cobra nada.
- Num período, `expected` = parâmetros do grupo com `firstPeriod.start <= period.start`; `filled` = desses, os que têm `Measurement` viva com `periodStart == period.start`. Pendente se `expected > 0 && filled < expected` (parcial continua pendente).
- `kind` = `toLaunch` se o período contém `today`, senão `overdue`.
- Ordem: `period.start`, depois índice do contexto, depois `companyId`.
- Medições de parâmetros que não estão em `parameters` são ignoradas.

Repositório (`measurement_repository.dart`):

```dart
abstract interface class MeasurementRepository {
  /// Da empresa e contexto, não excluídos; arquivados só com includeArchived.
  /// Ordem: position, nome sem acento/caixa, id.
  Stream<List<MeasurementParameter>> watchParameters(String companyId,
      MeasurementContext context, {bool includeArchived = false});

  Future<MeasurementParameter?> findParameter(String id); // null se excluído

  /// Vai para o fim da lista (position = maior + 1). Lança
  /// MeasurementValidationException, CompanyNotFoundException ou
  /// MeasurementModuleNotEnabledException.
  Future<MeasurementParameter> createParameter(
      String companyId, MeasurementContext context, MeasurementParameterInput input);

  /// Arquivado também. Mudar a frequência com medições vivas →
  /// MeasurementValidationException(frequency/locked). Lança também
  /// MeasurementParameterNotFoundException.
  Future<MeasurementParameter> updateParameter(String id, MeasurementParameterInput input);

  /// orderedIds = exatamente os parâmetros vivos (arquivados incluídos) da
  /// empresa e contexto; senão ArgumentError. Grava position 0..n-1.
  Future<void> reorderParameters(String companyId, MeasurementContext context, List<String> orderedIds);

  Future<void> archiveParameter(String id);    // idempotente
  Future<void> unarchiveParameter(String id);  // idempotente
  /// Exclusão lógica do parâmetro e das medições dele.
  Future<void> deleteParameter(String id);

  /// Medições vivas de parâmetros vivos (arquivados incluídos) da empresa e
  /// contexto, com periodStart entre from e to (inclusivos, opcionais).
  /// Ordem: periodStart, position do parâmetro, id.
  Stream<List<Measurement>> watchMeasurements(String companyId,
      MeasurementContext context, {DateTime? from, DateTime? to});

  /// Grava o período de uma vez, numa transação. entries: parameterId →
  /// entrada; null apaga a medição do período. Parâmetros fora do mapa não
  /// mudam. Lança MeasurementParameterNotFoundException (id inexistente ou
  /// excluído), ArgumentError (parâmetro de outra frequência que a do
  /// período), FuturePeriodException (period.start > início do período que
  /// contém `today`) ou MeasurementValidationException.
  Future<void> savePeriod(MeasurementPeriod period,
      Map<String, MeasurementEntry?> entries, {required DateTime today});

  /// Pendências (RF-AMB-02/07) de empresas não excluídas e não arquivadas
  /// com o módulo do contexto habilitado; de uma empresa só com companyId.
  Stream<List<PendingLaunch>> watchPendingLaunches({required DateTime today, String? companyId});
}
```

Exceções (seladas, `sealed class MeasurementException implements Exception`): `MeasurementValidationException(List<ParameterFieldError> parameterErrors, Map<String, List<EntryFieldError>> entryErrors)`, `MeasurementParameterNotFoundException(id)`, `MeasurementModuleNotEnabledException(companyId, module)`, `FuturePeriodException(period)`. `ParameterField` ganha `frequency` e `ParameterFieldErrorType` ganha `locked`. `CompanyNotFoundException` vem de `companies/domain/company_repository.dart`.

## Regras de implementação

- Timestamps: `createdAt`/`updatedAt` do `clock` (UTC). `updatedAt` só muda quando algo muda (editar com os mesmos dados não grava; `savePeriod` com a mesma entrada não grava).
- `createParameter`: empresa viva (arquivada pode) senão `CompanyNotFoundException`; módulo do contexto habilitado (`company_modules` vivo e `enabled`) senão `MeasurementModuleNotEnabledException`; normaliza, valida, checa duplicado.
- `updateParameter`: inexistente/excluído → not found; normaliza, valida, duplicado ignorando o próprio; frequência diferente com medição viva → `frequency/locked`. Não muda `position`, contexto, empresa nem `archivedAt`.
- `savePeriod`: valida todas as entradas antes de gravar (erro em uma → nada grava); por parâmetro: existe viva → atualiza se mudou; não existe → insere linha nova (`id` novo); `null` → exclusão lógica da viva (sem viva, nada). Período passado e de parâmetro arquivado podem ser gravados. `today` é a data local.
- Unicidade da medição viva por `(parameter_id, period_start)` garantida pelo índice parcial; reaproveitar linha excluída **não** é necessário (diferente de D011), porque o histórico é por período.
- `deleteParameter`: transação, parâmetro e medições com `deletedAt = updatedAt = now`. Excluir empresa (`LocalCompanyRepository.delete`) faz o mesmo para todos os parâmetros dela, na mesma transação.
- `watchPendingLaunches`: carrega parâmetros não arquivados de empresas vivas e não arquivadas com módulo habilitado (join como `watchUpcoming` em `LocalDeadlineRepository`), as medições vivas desses parâmetros e chama `pendingLaunches`. `today` fixo por assinatura (a tela assina de novo na virada do dia, task 015).
- Todos os `watch*` usam `_db.customSelect('SELECT 1 AS measurements_changed', readsFrom: {measurementParameters, measurements, companies, companyModules})` + `asyncMap` + `distinct` (D008).
- `value` é `double` (REAL). Formatação pt-BR fica na apresentação (014).

## Dados

Migração **v2 → v3** (`from2To3`: `createTable` das duas e `createIndex` dos dois índices).

`measurement_parameters` (`@DataClassName('MeasurementParameterRow')`, `EntityColumns`):

| Coluna | Tipo | Nulo | Observação |
|---|---|---|---|
| `company_id` | TEXT | não | FK `companies(id)` |
| `context` | TEXT | não | `MeasurementContext.code` |
| `name` | TEXT | não | |
| `unit` | TEXT | sim | |
| `frequency` | TEXT | não | `MeasurementFrequency.code` |
| `position` | INTEGER | não | ordem na lista |
| `start_date` | TEXT | não | `AAAA-MM-DD` (`DateOnlyConverter`) |
| `limit_min` | REAL | sim | |
| `limit_max` | REAL | sim | |
| `archived_at` | TEXT (datetime) | sim | UTC ISO-8601 |

Índice `measurement_parameters_company_context ON measurement_parameters (company_id, context, position) WHERE deleted_at IS NULL`.

`measurements` (`@DataClassName('MeasurementRow')`, `EntityColumns`):

| Coluna | Tipo | Nulo | Observação |
|---|---|---|---|
| `parameter_id` | TEXT | não | FK `measurement_parameters(id)` |
| `period_start` | TEXT | não | `AAAA-MM-DD`, início do período |
| `value` | REAL | sim | `null` = sem medição (justificada) |
| `note` | TEXT | sim | obrigatória quando `value` é `null` (regra no domínio) |

Índice `CREATE UNIQUE INDEX measurements_parameter_period_live ON measurements (parameter_id, period_start) WHERE deleted_at IS NULL`.

Backup: `_tablesByVersion` ganha `3: ['measurement_parameters', 'measurements']`; `lastChangeAt` inclui `MAX(updated_at)` das duas tabelas quando `version >= 3`. `BackupSummary` não muda (a confirmação segue com empresas e prazos).

## Interface

Nenhuma nesta task.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/features/measurements/domain/enums_test.dart` | `code` únicos e estáveis, `fromCode` ida e volta e erro |
| `test/features/measurements/domain/measurement_period_test.dart` | diária: `start == end`, hora ignorada, `next` de 2026-12-31 → 2027-01-01. Quinzenal: 2026-11-15 → 01 a 15/11; 2026-11-16 → 16 a 30/11; 2028-02-20 → 16 a 29/02; `next` de 16/12/2026 → 01/01/2027; `previous` de 01/03/2026 → 16 a 28/02. `containing` semanal: 2026-09-23 → 21/09 a 27/09, semana 39; 2026-12-28 e 2027-01-03 → semana 53 de 2026; 2027-01-04 → semana 1 de 2027; 2024-12-30 → semana 1 de 2025. Mensal: 2028-02-10 → 01/02 a 29/02; 2026-02-10 → até 28/02; `next`/`previous` na virada de ano; `contains` ignora hora; `isoWeek` em mensal → `StateError` |
| `test/features/measurements/domain/measurement_parameter_test.dart` | `check`: sem limites, só máximo 70 (70 dentro, 70,1 acima), mín/máx 6–9 (5,9 abaixo); `firstPeriod` |
| `test/features/measurements/domain/measurement_validation_test.dart` | normalização (espaços, unidade vazia → null, hora removida); nome vazio; limites invertidos e iguais; `NaN`/`∞`; entrada sem valor e sem nota → `note/required`; com nota só de espaços → `required`; valor 0 válido |
| `test/features/measurements/domain/pending_launch_test.dart` | `today` = 2026-11-26 (qui, semana 48, início 23/11). P1 e P2 de ruído com início 2026-11-04 (semana 45, 02/11). Medições: semana 45 P1+P2; 46 só P1; 47 P1 justificada + P2 valor. Esperado: 46 `overdue` 1/2 e 48 `toLaunch` 0/2. P3 com início 2026-11-18 → semana 47 vira `overdue` 2/3. Arquivado não cobra. Início futuro não cobra. Mensal com início 2026-09-15 e medição de outubro → setembro `overdue`, novembro `toLaunch`. Diária com início 2026-11-24 e medição em 25/11 → 24/11 `overdue`, 26/11 `toLaunch`. Quinzenal com início 2026-11-03 → 01–15/11 `overdue`, 16–30/11 `toLaunch`. Duas empresas e dois contextos ordenados. Medição de parâmetro desconhecido ignorada |
| `test/features/measurements/data/local_measurement_repository_test.dart` | banco em memória: criar (posição no fim, normalização, duplicado com acento/caixa diferente, empresa inexistente/excluída, módulo desabilitado); editar (sem mudança não toca `updatedAt`; frequência travada com medição; liberada sem); ordenar (ok e ids errados → `ArgumentError`); arquivar/desarquivar idempotentes e `includeArchived`; excluir em cascata; `savePeriod` (insere, parcial, edita, `null` apaga, justificativa, futuro → `FuturePeriodException`, período atual aceito, inválido não grava nada, id excluído → not found, frequência errada → `ArgumentError`); `watchMeasurements` com `from`/`to`; `watchPendingLaunches` (empresa arquivada e módulo desabilitado somem; stream emite de novo depois de `savePeriod`) |
| `test/features/companies/data/local_company_repository_test.dart` | novo caso: excluir empresa exclui parâmetros e medições |
| `test/core/database/app/migration_test.dart` | migrações simples (geradas) + "v2 → v3 não corrompe dados": empresa, módulo, registro, prazo e lembrete da v2 iguais na v3; tabelas novas vazias |
| `test/core/database/schema_test.dart` | índices parciais novos na lista |
| `test/features/backup/data/local_backup_service_test.dart` | `schemaVersion` atual nos casos existentes; "backup v1 migrado" espera `user_version` 3; novo "backup v2 com prazo é migrado para v3" (via `SchemaVerifier.schemaAt(2)`, `validateDatabaseSchema`, prazo intacto); novo "backup v3 com medições faz ida e volta" (restaurar outro e desfazer traz a medição); `lastChangeAt` considera medição mais recente |

## Como verificar (definição de pronto)

```bash
dart run build_runner build --delete-conflicting-outputs   # sem diff depois do passo 2
dart run drift_dev make-migrations                          # sem diff
dart format . && flutter analyze && flutter test
grep -rE "package:(flutter|drift)" lib/features/measurements/domain   # vazio
```

Emulador `Medium_Phone_API_37.0` (adb em `~/Library/Android/sdk/platform-tools/adb`), **sem `pm clear`, sem desinstalar, sem `flutter install`**:

1. Antes de instalar: `adb exec-out run-as br.com.normatrack.app cat app_flutter/normatrack.sqlite > <scratchpad>/antes.sqlite` (conferir `user_version` 2 e `quick_check`), e um backup pelo app (Ajustes → Fazer backup, escolhendo um app na folha) copiado para `/sdcard/Download/` se preciso.
2. `flutter build apk --debug` e `adb install -r build/app/outputs/flutter-apk/app-debug.apk`; abrir o app.
3. Copiar o banco de novo (`depois.sqlite`): `user_version` 3, `quick_check` ok, tabelas novas vazias, as 5 tabelas antigas iguais linha a linha às de `antes.sqlite` (script `sqlite3`/Python no scratchpad).
4. Restaurar pelo app o backup v2 do passo 1: confirmação com as mesmas contagens, Painel com os mesmos prazos, banco continua v3.

## Riscos e alternativas

- **[suposição]** C26: pendência a partir do período de início, parcial continua pendente, justificativa tira da pendência, futuro recusado, passado editável, semana ISO. Respostas do usuário em 2026-11-26; falta a cliente.
- **[suposição]** C6: limite máximo opcional por ponto de ruído (a base aceita mínimo e máximo para servir ao pH da ETE/ETA).
- **[suposição]** arquivar um parâmetro tira as pendências dele inclusive do passado.
- Várias ETE/ETA por empresa (C8, cliente em 2026-11-27): esta task **não** cria a tabela de estações. Os contextos `effluent`/`water` ficam, e a 017 acrescenta `treatment_stations` e `station_id` em `measurement_parameters` (migração própria), com as pendências agrupadas também por estação. *Descartado agora:* criar estações já na 013, que passaria a ter três tabelas com regras próprias (critério de quebra da skill) sem tela para usá-las.
- **[suposição]** quinzena = 1–15 e 16–fim do mês (C8). Frequência é por parâmetro, então "ETE por tratamento: mensal, quinzenal ou semanal" se resolve escolhendo a frequência de cada parâmetro.
- Resíduos (C7, cliente em 2026-11-27): tipos por classe, kg, semanal. A 016 decide se usa esta base (tipo = parâmetro com a classe) ou tabela própria por causa da quantidade armazenada.
- `REAL` pode guardar 0,1 como 0,1000000000000000055…; a apresentação formata com casas fixas. *Descartado:* decimal em texto ou inteiro escalado (mais código para um ganho que só aparece em somas longas).
- *Descartado:* gravar a situação "pendente" (valor derivado, regra do `CLAUDE.md`); período como `AAAA-Www`/`AAAA-MM` em texto (uma coluna de data serve às duas frequências e ordena bem); reaproveitar a linha excluída da medição (D011 não se aplica: não há lista editável).

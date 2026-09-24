# Plano técnico — 002

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Quando algo não estiver aqui, **não invente**: registre a dúvida no `journal.md` e siga a regra de ambiguidade do `CLAUDE.md`. Suposições de negócio já tomadas estão marcadas com **[suposição]** e devem virar `// TODO(RF-EMP-0X):` no código.

## Abordagem

`Company` é um agregado: os dados cadastrais, os módulos habilitados e os registros em órgãos são carregados e salvos juntos. Quem consome (tela condicional, relatório, prazo) recebe um `Company` completo e pergunta direto a ele (`hasModule`, `registrationFor`), sem montar consulta própria. Os valores fixos (módulos, órgãos, UF) são enums do domínio com um `code` estável em texto, que é o que vai para o banco e, no futuro, para a API ([D007](../../docs/decisoes.md#d007--órgãos-e-módulos-como-enums-de-domínio)).

## Contexto do repositório (em 2026-09-24)

- Flutter 3.47.5, Dart SDK `^3.13.4`, pacote `normatrack`. Só existem `lib/main.dart`, `lib/app/theme/*` e `lib/app/widgets/status_chip.dart`. **Ainda não há** drift, Riverpod, go_router nem `build.yaml`.
- `test/widget_test.dart` monta `const NormaTrackApp()` **sem** `ProviderScope`. Coloque o `ProviderScope` em `main()`, não dentro de `NormaTrackApp`, para esse teste continuar passando.
- `analysis_options.yaml` usa `flutter_lints` e exclui `tasks/**`.
- A pergunta T3 (freezed) está sem resposta: **entidades escritas à mão**, sem code generation no domínio.

## Ordem de implementação

Branch: `task/002-empresas-dominio-e-dados`. Um commit por passo, no formato `feat(empresas): <o quê> [task 002, RF-EMP-04]`, terminando com a linha de coautoria que o harness indicar. Registre cada passo no `journal.md` à medida que avança.

1. Dependências e `build.yaml` ([Setup](#setup)).
2. `core/utils`: clock, id, documentos brasileiros e normalização de busca, com testes.
3. Domínio: enums, entidades, normalização, validação, interface e exceções, com testes.
4. Tabelas, `AppDatabase` v1, `dart run build_runner build --delete-conflicting-outputs` e schema dump.
5. `LocalCompanyRepository` com testes de banco em memória e de migração.
6. Providers e `ProviderScope` em `main.dart`.
7. `dart format .`, `flutter analyze` e `flutter test` sem erros. Marque os critérios no `README.md`, faça a entrada final no journal e mude o status para `concluída` (aqui e em `tasks/README.md`). Marque os itens de Fase 0 entregues em `docs/05-roadmap.md` ("AppDatabase (drift)…" em parte e "Riverpod" em parte).

## Setup

Versões resolvidas em 2026-09-24 (`flutter pub add --dry-run`):

```bash
flutter pub add drift:^2.35.0 drift_flutter:^0.3.1 uuid:^4.6.0 flutter_riverpod:^3.4.3 collection meta
flutter pub add dev:drift_dev:^2.35.0 dev:build_runner:^2.16.1
```

- `drift_flutter` já traz o SQLite nativo e o caminho do arquivo. **Não** adicione `sqlite3_flutter_libs` (EOL).
- `collection` e `meta` são Dart puro e podem ser usados no domínio (`SetEquality`/`MapEquality`, `@immutable`).
- Nada de `riverpod_generator`: os providers são escritos à mão.

`build.yaml` na raiz:

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          store_date_time_values_as_text: true   # ISO-8601, legível e seguro para sync
          databases:
            app: lib/core/database/app_database.dart
          test_dir: test/core/database/
          schema_dir: drift_schemas/
```

Schema e testes de migração (rodar depois do passo 4 e commitar `drift_schemas/` e os arquivos gerados em `test/core/database/generated/`):

```bash
dart run drift_dev make-migrations
```

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| core | `lib/core/utils/clock.dart` | `typedef Clock = DateTime Function();` `DateTime systemClock() => DateTime.now().toUtc();` |
| core | `lib/core/utils/id_generator.dart` | `typedef IdGenerator = String Function();` `String uuidV7() => const Uuid().v7();` |
| core | `lib/core/utils/br_documents.dart` | `normalizeCnpj`, `isValidCnpj`, `formatCnpj`; o mesmo para CPF, CEP e telefone |
| core | `lib/core/utils/search_text.dart` | `String normalizeForSearch(String)`: minúsculas e sem acentos |
| core | `lib/core/providers.dart` | `clockProvider`, `idGeneratorProvider` |
| core | `lib/core/database/app_database.dart` | `AppDatabase` v1 + `appDatabaseProvider` |
| core | `lib/core/database/converters.dart` | `DateOnlyConverter` (`DateTime` ↔ `'AAAA-MM-DD'`) |
| domain | `lib/features/companies/domain/module_type.dart` | `ModuleType` |
| domain | `lib/features/companies/domain/authority.dart` | `Authority`, `RegistrationStatus`, `AuthorityRegistration` |
| domain | `lib/features/companies/domain/brazilian_state.dart` | `BrazilianState` |
| domain | `lib/features/companies/domain/company.dart` | `Company`, `CompanyInput`, `Address`, `LegalRepresentative` |
| domain | `lib/features/companies/domain/company_validation.dart` | `normalizeCompanyInput`, `validateCompany`, `CompanyField`, `CompanyFieldError` |
| domain | `lib/features/companies/domain/company_repository.dart` | `CompanyRepository`, `CompanyFilter`, exceções |
| data | `lib/features/companies/data/company_tables.dart` | Tabelas drift |
| data | `lib/features/companies/data/company_mapper.dart` | Linhas ↔ entidades, `code` ↔ enum |
| data | `lib/features/companies/data/local_company_repository.dart` | Implementação + `companyRepositoryProvider` |

`lib/core/utils` e `features/*/domain` não importam Flutter nem drift (`uuid` é Dart puro e pode). `Authority` e `ModuleType` nascem em `features/companies/domain`, e outras features importam desse caminho.

## Valores de referência

A ordem dos enums é a ordem de exibição. `code` nunca muda depois de publicado.

**ModuleType**

| valor | code | label |
|---|---|---|
| `environmental` | `environmental` | Ambiental |
| `controlledProducts` | `controlled_products` | Produtos controlados |
| `qualityControl` | `quality_control` | Controle de qualidade |

**Authority**

| valor | code | label | shortLabel |
|---|---|---|---|
| `cityHall` | `city_hall` | Prefeitura | Prefeitura |
| `agricultureMinistry` | `agriculture_ministry` | Ministério da Agricultura | MAPA |
| `anvisa` | `anvisa` | ANVISA | ANVISA |
| `semace` | `semace` | SEMACE | SEMACE |
| `ibama` | `ibama` | IBAMA | IBAMA |
| `environmentSecretariat` | `environment_secretariat` | Secretaria de Meio Ambiente | Sec. Meio Ambiente |
| `professionalCouncil` | `professional_council` | Conselho de Classe | Conselho de Classe |
| `federalPolice` | `federal_police` | Polícia Federal | PF |
| `army` | `army` | Exército Brasileiro | Exército |

**RegistrationStatus**

| valor | code | label |
|---|---|---|
| `registered` | `registered` | Possui registro |
| `required` | `required` | Precisa obter |

**BrazilianState**: as 27 UFs, `code` = sigla (`AC`, `AL`, `AP`, `AM`, `BA`, `CE`, `DF`, `ES`, `GO`, `MA`, `MT`, `MS`, `MG`, `PA`, `PB`, `PR`, `PE`, `PI`, `RJ`, `RN`, `RS`, `RO`, `RR`, `SC`, `SP`, `SE`, `TO`), `label` = nome por extenso ("Ceará"). Enum em ordem alfabética da sigla.

Todo enum expõe `code`, `label` e `static X fromCode(String code)`, que lança `ArgumentError` para código desconhecido.

## Domínio

```dart
@immutable
class Address {
  const Address({this.street, this.number, this.complement, this.district,
      this.city, this.state, this.postalCode});
  final String? street, number, complement, district, city;
  final BrazilianState? state;
  final String? postalCode;          // 8 dígitos
  static const empty = Address();
  bool get isEmpty;                  // todos nulos
}

@immutable
class LegalRepresentative {
  const LegalRepresentative({this.name, this.cpf, this.phone, this.email});
  final String? name, cpf, phone, email;   // cpf: 11 dígitos; phone: só dígitos
  static const empty = LegalRepresentative();
}

@immutable
class AuthorityRegistration {
  const AuthorityRegistration({required this.authority, required this.status,
      this.registrationNumber, this.validUntil, this.notes});
  final Authority authority;
  final RegistrationStatus status;
  final String? registrationNumber;
  final DateTime? validUntil;  // só a data: DateTime(y, m, d), sem hora, local
  final String? notes;         // TODO(RF-EMP-05): qual conselho/secretaria (C17)
  /// Vale até o fim do dia `validUntil`, inclusive. Sem validade → false.
  bool isExpiredOn(DateTime today);  // compara só y/m/d: validUntil < data(today)
}

/// Dados editáveis. Usado para criar e para editar.
@immutable
class CompanyInput {
  const CompanyInput({required this.legalName, this.tradeName, this.cnpj,
      this.stateRegistration, this.address = Address.empty, this.phone, this.email,
      this.legalRepresentative = LegalRepresentative.empty,
      this.enabledModules = const {}, this.registrations = const {}});
  final String legalName;
  final String? tradeName, cnpj, stateRegistration, phone, email;
  final Address address;
  final LegalRepresentative legalRepresentative;
  final Set<ModuleType> enabledModules;
  final Map<Authority, AuthorityRegistration> registrations; // ausente = não se aplica
}

@immutable
class Company {
  // mesmos campos de CompanyInput, mais:
  final String id;
  final DateTime? archivedAt;
  final DateTime createdAt, updatedAt;   // UTC

  String get displayName => tradeName ?? legalName;
  bool get isArchived => archivedAt != null;
  bool hasModule(ModuleType m) => enabledModules.contains(m);
  AuthorityRegistration? registrationFor(Authority a) => registrations[a];
  CompanyInput toInput();                // para editar: toInput() → alterar → update()
}
```

- `==` e `hashCode` escritos à mão em todas as classes acima (`Object.hash`; `SetEquality`/`MapEquality` para as coleções). Não é preciso `copyWith`: a edição passa por `CompanyInput`, e a UI monta um novo.
- `enabledModules` e `registrations` são expostos como coleções não modificáveis (`Set.unmodifiable`, `Map.unmodifiable`).
- Empresa nova: **nenhum módulo habilitado** por padrão **[suposição]**.

### Normalização (`normalizeCompanyInput`)

Aplicada pelo repositório antes de validar e gravar. A UI pode chamá-la para pré-visualizar.

- Todo texto: `trim()`. Texto vazio vira `null` (exceto `legalName`, que fica `''` e falha na validação).
- `cnpj`: remove `.`, `/`, `-` e espaços, e passa para maiúsculas.
- `cpf`, `postalCode`, `phone`: mantém só os dígitos.
- `email`: minúsculas.
- `stateRegistration`: só `trim` e maiúsculas (aceita "ISENTO").
- `registrationNumber`, `notes`: só `trim`. `validUntil` truncada para a data.

### Validação (`validateCompany(CompanyInput) → List<CompanyFieldError>`)

Recebe o input já normalizado. Lista vazia = válido.

```dart
enum CompanyField { legalName, cnpj, phone, email, postalCode,
  legalRepCpf, legalRepPhone, legalRepEmail }
enum CompanyFieldErrorType { required, invalid }
class CompanyFieldError { final CompanyField field; final CompanyFieldErrorType type; }
```

| Campo | Regra |
|---|---|
| `legalName` | obrigatório (não vazio depois do `trim`) |
| `cnpj` | se presente: formato **alfanumérico** (abaixo) e DV válido |
| `legalRepCpf` | se presente: 11 dígitos, DV válido, não todos iguais |
| `postalCode` | se presente: exatamente 8 dígitos |
| `phone`, `legalRepPhone` | se presente: 10 ou 11 dígitos (DDD + número) **[suposição]** |
| `email`, `legalRepEmail` | se presente: `^[^\s@]+@[^\s@]+\.[^\s@]+$` |
| registros | `registrations[k].authority == k` (é `assert`, não erro de campo). Nº, validade e observação são livres para as duas situações |

**CNPJ alfanumérico** (IN RFB nº 2.229/2024, em vigor desde julho de 2026; os CNPJs numéricos continuam válidos):
- 14 caracteres: os 12 primeiros em `[0-9A-Z]` e os 2 últimos (DV) em `[0-9]`. Inválido se os 14 forem o mesmo caractere.
- Valor de cada caractere = `codeUnit − 48` ('0'→0 … '9'→9, 'A'→17 … 'Z'→42).
- DV1: pesos `5,4,3,2,9,8,7,6,5,4,3,2` sobre os 12 primeiros. DV2: pesos `6,5,4,3,2,9,8,7,6,5,4,3,2` sobre os 12 + DV1. Em cada um, `r = soma % 11`, e o DV é `0` se `r < 2`, senão `11 − r`.
- Casos de teste obrigatórios: `11.222.333/0001-81` (numérico válido), `11.222.333/0001-82` (inválido), `12.ABC.345/01DE-35` (alfanumérico válido, exemplo da Receita), `00000000000000` (inválido).

**Formatação** (`br_documents.dart`, usada por telas e relatórios): CNPJ `XX.XXX.XXX/XXXX-XX`; CPF `XXX.XXX.XXX-XX`; CEP `XXXXX-XXX`; telefone `(XX) XXXX-XXXX` (10 dígitos) ou `(XX) XXXXX-XXXX` (11). Entrada fora do formato esperado volta sem alteração.

## Repositório

```dart
abstract interface class CompanyRepository {
  /// Não excluídas, filtradas e ordenadas por normalizeForSearch(displayName).
  Stream<List<Company>> watchAll([CompanyFilter filter = const CompanyFilter()]);
  Stream<Company?> watchById(String id);   // null se não existe ou está excluída
  Future<Company?> findById(String id);
  Future<Company> create(CompanyInput input);
  Future<Company> update(String id, CompanyInput input);
  Future<void> archive(String id);          // idempotente
  Future<void> unarchive(String id);        // idempotente
  Future<void> delete(String id);           // lógico, em cascata nos filhos
}

@immutable
class CompanyFilter {
  const CompanyFilter({this.archived = false, this.query, this.module,
      this.authority, this.status});
  final bool archived;               // false = só ativas; true = só arquivadas
  final String? query;
  final ModuleType? module;          // empresas com o módulo habilitado
  final Authority? authority;        // empresas com registro (qualquer situação) no órgão
  final RegistrationStatus? status;  // com authority: situação naquele órgão; sem authority: em qualquer órgão
}

sealed class CompanyException implements Exception {}
final class CompanyValidationException extends CompanyException { final List<CompanyFieldError> errors; }
final class DuplicateCnpjException extends CompanyException { final String cnpj; }
final class CompanyNotFoundException extends CompanyException { final String id; }
```

Regras da implementação (`LocalCompanyRepository(AppDatabase db, {required Clock clock, required IdGenerator newId})`):

- **create/update**: `normalizeCompanyInput` → `validateCompany` (lista não vazia lança `CompanyValidationException`) → checagem de CNPJ duplicado → gravação, tudo em **uma transação**. Retorna a entidade lida de volta do banco.
- **CNPJ duplicado**: é duplicado se outra empresa **não excluída** (ativa ou arquivada) tem o mesmo CNPJ normalizado. Na edição, a própria empresa não conta. Depois de excluída, o CNPJ fica livre.
- **update/archive/unarchive/delete** de `id` inexistente ou excluído lança `CompanyNotFoundException`.
- **Timestamps**: `createdAt = updatedAt = clock()` no create. Toda alteração grava `updatedAt = clock()` só nas linhas que mudaram de fato. `createdAt` nunca muda.
- **Módulos**: o create insere uma linha por módulo habilitado. O update faz upsert por `(company_id, module_type)`, com `enabled = input.enabledModules.contains(m)`, só para os módulos que já têm linha ou que estão habilitados.
- **Registros**: para cada `Authority`, se está presente no input, faz upsert (reaproveita a linha e zera `deleted_at` se estava excluída). Se está ausente e existe linha viva, preenche `deleted_at`.
- **delete**: preenche `deleted_at` da empresa e das linhas vivas de módulos e registros, com o mesmo timestamp.
- **Filtros**: `deleted_at IS NULL` e `archived` em SQL. `query`, `module`, `authority` e `status` em Dart sobre o resultado (poucas dezenas de empresas; evita `LIKE` sem suporte a acento). `query` casa se `normalizeForSearch(q)` está contido em `normalizeForSearch` de `legalName` ou `tradeName`, ou se `normalizeCnpj(q)` (não vazio) está contido no `cnpj`.
- **watchAll/watchById**: combinam as três tabelas (`select` com `watch()` em cada uma, ou uma query com joins). Precisam emitir de novo quando qualquer uma delas muda.

## Dados

Nomes de tabela e coluna em snake_case (padrão do drift). Todas as tabelas: `id TEXT PRIMARY KEY` (UUID v7 gerado no app), `created_at`, `updated_at` (`DateTime` NOT NULL), `deleted_at` (`DateTime` nulo). Com `store_date_time_values_as_text`, as datas ficam em ISO-8601.

**companies**: `legal_name` (NOT NULL), `trade_name`, `cnpj`, `state_registration`, `address_street`, `address_number`, `address_complement`, `address_district`, `address_city`, `address_state` (code da UF), `address_postal_code`, `phone`, `email`, `legal_rep_name`, `legal_rep_cpf`, `legal_rep_phone`, `legal_rep_email`, `archived_at` (`DateTime` nulo). Tudo texto nulo, exceto o indicado.

```dart
@TableIndex.sql('CREATE UNIQUE INDEX companies_cnpj_active ON companies (cnpj) '
    'WHERE cnpj IS NOT NULL AND deleted_at IS NULL')
class Companies extends Table { ... }
```

**company_modules**: `company_id TEXT NOT NULL REFERENCES companies(id)`, `module_type TEXT NOT NULL` (code), `enabled BOOL NOT NULL`. `UNIQUE (company_id, module_type)`.

**company_authorities**: `company_id TEXT NOT NULL REFERENCES companies(id)`, `authority TEXT NOT NULL` (code), `status TEXT NOT NULL` (code), `registration_number`, `valid_until TEXT` (`DateOnlyConverter`, `'AAAA-MM-DD'`), `notes`. `UNIQUE (company_id, authority)`.

`AppDatabase`:

```dart
@DriftDatabase(tables: [Companies, CompanyModules, CompanyAuthorities])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  @override int get schemaVersion => 1;
  @override MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'normatrack'));
  ref.onDispose(db.close);
  return db;
});
```

Nos testes: `AppDatabase(NativeDatabase.memory())` (de `package:drift/native.dart`), fechando no `tearDown`.

Os enums são convertidos em `company_mapper.dart` com `fromCode`/`code`, sem `textEnum` (que grava `name`). Códigos desconhecidos vindos do banco lançam `ArgumentError`: é corrupção, não entrada do usuário.

Se `@TableIndex.sql` não aceitar `WHERE` nesta versão do drift, crie o índice com `customStatement` em `onCreate` (depois de `m.createAll()`), registre no journal e confira se o schema dump e o teste de migração o cobrem.

## Providers

```dart
// lib/core/providers.dart
final clockProvider = Provider<Clock>((ref) => systemClock);
final idGeneratorProvider = Provider<IdGenerator>((ref) => uuidV7);

// local_company_repository.dart
final companyRepositoryProvider = Provider<CompanyRepository>((ref) =>
    LocalCompanyRepository(ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider), newId: ref.watch(idGeneratorProvider)));
```

Em `main.dart`: `runApp(const ProviderScope(child: NormaTrackApp()));`. A UI (task 003) depende só do tipo `CompanyRepository`.

## Interface

Sem UI nesta task.

## Testes

A pasta `test/` espelha `lib/`. Relógio fixo (`() => DateTime.utc(2026, 1, 1)`, avançando manualmente) e ids sequenciais (`'id-1'`, `'id-2'`…) nos testes de repositório.

| Arquivo | Cobre |
|---|---|
| `test/core/utils/br_documents_test.dart` | CNPJ (os 4 casos obrigatórios, minúsculas normalizadas, tamanho errado), CPF (válido, DV errado, todos iguais), CEP, telefone 10/11/9 dígitos, formatações |
| `test/core/utils/search_text_test.dart` | `"Indústria São João"` → `"industria sao joao"` |
| `test/features/companies/domain/enums_test.dart` | `fromCode(x.code) == x` para todo valor dos 4 enums; `code` únicos; código desconhecido lança erro; 9 órgãos, 3 módulos, 27 UFs |
| `test/features/companies/domain/company_validation_test.dart` | normalização (trim, vazio→null, máscaras); cada linha da tabela de validação; input só com razão social é válido |
| `test/features/companies/domain/company_test.dart` | `displayName`, `hasModule`, `registrationFor`, `isExpiredOn` (véspera, no dia, dia seguinte, sem validade), igualdade |
| `test/features/companies/data/local_company_repository_test.dart` | create → findById igual; update troca campos, módulos e registros e mantém `createdAt`; remover registro e readicionar reaproveita a linha; CNPJ duplicado (com ativa, com arquivada, depois de excluir, na própria edição); `CompanyNotFoundException`; arquivar/desarquivar e filtro `archived`; filtros `query` (acento, CNPJ com máscara), `module`, `authority`, `status`; ordenação; `watchAll` emite depois do update de um registro; delete some de `watchAll` e `findById` |
| `test/core/database/` (gerado por `make-migrations`) | Schema v1 bate com `drift_schemas/` |

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` e `flutter test` sem erros ou avisos novos.
- `grep -rE "package:(flutter|drift)" lib/features/companies/domain lib/core/utils` sem resultado.
- `test/widget_test.dart` continua passando.
- Todos os critérios de aceite do `README.md` marcados, ou justificados no journal.

## Riscos e alternativas

- **Validade no cadastro × prazo (C16):** a validade do registro também é, na prática, um prazo com alerta. Por ora ela só fica guardada no registro. Quando `Deadline` existir, avaliar se uma licença é criada a partir do registro ou se passa a referenciá-lo (`authorityRegistrationId`).
- **`Deadline.authority`** passa a reusar `Authority` (D007). Não mexa em prazos nesta task.
- **Suposições** (também em `docs/06-perguntas-em-aberto.md`, C18): telefone com 10 ou 11 dígitos; um telefone e um e-mail por empresa; nenhum módulo por padrão; registro vale até o dia da validade, inclusive; um registro por órgão, com observação livre (C17).
- *Descartado:* tabela de órgãos editável pela usuária, porque telas condicionais e relatórios dependeriam de dados em vez de código (decisão da usuária, 2026-09-24).
- *Descartado:* JSON com os dados de endereço/órgãos em uma coluna. Não permite filtrar por órgão nem validar no banco.
- *Descartado:* `textEnum` do drift, porque grava o `name` do enum e renomear viraria migração.

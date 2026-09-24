# Journal — 002

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-24 — Task criada

**Feito**
- Task criada a partir do pedido da usuária: cadastro de empresa com dados cadastrais, módulos ativos e órgãos (setores) em que a empresa tem ou precisa ter registro, estruturado para reuso em fluxos, relatórios e telas condicionais.
- Escopo dividido em duas tasks: esta (domínio + dados) e a [003](../003-empresas-telas/) (telas). Juntas passariam de uma tela grande e três tabelas, acima do limite de um PR revisável.
- Plano técnico escrito (status `planejada`).
- Requisitos RF-EMP-04 e RF-EMP-05 adicionados; domínio, perguntas em aberto, roadmap e decisões atualizados.

**Decidido** (respostas da usuária)
- Por órgão: situação (possui registro / precisa obter) + nº do registro + validade. "Não se aplica" = sem registro.
- Lista de órgãos fixa no código (enum com os 9). Incluir outro exige nova versão → [D007](../../docs/decisoes.md#d007--órgãos-e-módulos-como-enums-de-domínio).
- Só a razão social é obrigatória. Isso responde C5 em parte.
- Responsável legal: nome, CPF, telefone e e-mail.
- Endereço e responsável como colunas em `companies` (1:1), não tabelas próprias.
- A infra mínima (drift, uuid, Riverpod) entra nesta task porque é a primeira tabela do app.

**Pendente / dúvidas**
- C15: relação órgão ↔ módulo para telas condicionais (além de PF/Exército → Produtos Controlados, que já está nos requisitos).
- C16: a validade do registro deve gerar prazo com alerta?
- C17: Conselho de Classe e Secretaria de Meio Ambiente precisam de detalhe (qual conselho, municipal/estadual)? Suposição: campo `notes` livre, `// TODO(RF-EMP-05)`.

## 2026-09-24 — Plano completado para ser autocontido

**Feito**
- Revisão do plano mostrou lacunas que obrigariam outro agente a adivinhar. O `plan.md` foi reescrito com: contexto do repositório, ordem de implementação e commits, setup (versões, `build.yaml`, comandos), contratos completos (`CompanyInput`, exceções, filtros), valores de referência dos enums, normalização, tabela de validação, regras do repositório (transação, timestamps, upsert de filhos, cascata na exclusão), schema com índices e FKs, providers, testes por arquivo e como verificar.
- APIs conferidas no pub cache (drift 2.35.0, drift_dev 2.35.0, drift_flutter 0.3.1, uuid 4.6.0): `TableIndex.sql`, `make-migrations`, opções `databases`/`test_dir`/`schema_dir`/`store_date_time_values_as_text` e `Uuid().v7()`.
- Casos de teste do CNPJ conferidos com script (os dois válidos passam, os dois inválidos falham).
- Critério "docs refletem o modelo" marcado (feito na criação).

**Decidido**
- CNPJ alfanumérico suportado (IN RFB nº 2.229/2024, vigente desde julho de 2026). Também registrado em RF-EMP-04.
- Validade guardada como texto `AAAA-MM-DD`, para não mudar de dia por fuso. Timestamps em UTC, ISO-8601.
- UUID v7 (ordenado no tempo, melhor para índice e sync).
- Filtros de busca/módulo/órgão em Dart, sobre as empresas não excluídas: volume pequeno, e o `LIKE` do SQLite não trata acento.
- Entidades escritas à mão, sem `freezed` (T3 em aberto). Edição via `CompanyInput`, sem `copyWith`.
- Excluir a empresa exclui (lógico) também seus módulos e registros.

**Pendente / dúvidas**
- Suposições enviadas para confirmação em C18: telefone com 10/11 dígitos, um telefone/e-mail, nenhum módulo por padrão, validade inclusiva.

## 2026-09-24 — Implementação iniciada; passo 1 (dependências)

**Feito**
- Branch `task/002-empresas-dominio-e-dados` criada a partir de `docs/cadastro-de-empresa`. Status → `em andamento`.
- Código conferido contra o "Contexto do repositório" do plano: bate (só `main.dart`, tema e `StatusChip`; sem drift/Riverpod/`build.yaml`).
- Dependências adicionadas com os comandos do plano. Versões resolvidas: drift 2.35.0, drift_dev 2.35.0, drift_flutter 0.3.1 (sqlite3 3.6.0), uuid 4.6.0, flutter_riverpod 3.4.3, collection 1.19.1, meta 1.19.0, build_runner 2.16.1.
- `build.yaml` criado conforme o plano.

## 2026-09-24 — Passo 2: core/utils

**Feito**
- `clock.dart`, `id_generator.dart`, `search_text.dart` e `br_documents.dart` (CNPJ numérico/alfanumérico, CPF, CEP, telefone: normalizar, validar, formatar), com testes. CPF de teste `123.456.789-09` conferido por script.

**Decidido**
- `is…`/`format…` esperam valor já normalizado; `normalize…` é separado. Mantém a validação do domínio sobre o input normalizado, como no plano.
- `normalizeForSearch` com tabela de acentos do português (sem pacote extra de diacríticos).
- Validação de telefone marcada `// TODO(RF-EMP-04)` (suposição C18).

## 2026-09-24 — Passo 3: domínio

**Feito**
- `ModuleType`, `Authority`, `RegistrationStatus`, `BrazilianState`, `Address`, `LegalRepresentative`, `AuthorityRegistration`, `CompanyInput`, `Company`, `normalizeCompanyInput`, `validateCompany` e `CompanyRepository` (+ `CompanyFilter` e exceções), com testes de enums, entidade e validação.
- Suposições marcadas com `// TODO(RF-EMP-0X)`: telefone 10/11 dígitos e um telefone/e-mail (C18), nenhum módulo por padrão (C18), validade inclusiva (C18), validade × prazo (C16), observação livre por órgão (C17).

**Decidido**
- `BrazilianState` em ordem alfabética **estrita** da sigla (AM antes de AP, MG/MS/MT, RO/RR/RS, SE/SP). A lista do plano tinha AP/AM, MT/MS/MG etc. fora de ordem, mas a regra escrita é "ordem alfabética da sigla"; segui a regra. Valores do enum = sigla em minúsculas (`BrazilianState.ce`).
- `CompanyInput` mantém o construtor `const` do plano (coleções podem vir modificáveis de quem chama); `normalizeCompanyInput` e `Company` embrulham em coleções não modificáveis.
- `Company ==` compara id, timestamps, `archivedAt` e os dados editáveis (via `toInput()`).
- Documento que só tem máscara (ex.: `"../-"`) normaliza para `null`, como texto vazio.
- `CompanyFilter` tem `==`/`hashCode` para servir de chave de provider `family` na task 003.
- `validateCompany` não tem erro de UF: a UF é o enum `BrazilianState`, inválida não é representável.

## 2026-09-24 — Passo 4: tabelas, AppDatabase v1 e schema dump

**Feito**
- `company_tables.dart` (`Companies`, `CompanyModules`, `CompanyAuthorities`), `converters.dart` (`DateOnlyConverter` + mixin `EntityColumns` com `id`/`createdAt`/`updatedAt`/`deletedAt`) e `AppDatabase` v1 com `PRAGMA foreign_keys = ON` e `appDatabaseProvider`.
- `@TableIndex.sql` com `WHERE` funciona no drift 2.35.0 (conferido no pub cache): o índice parcial `companies_cnpj_active` está no código gerado e no dump. O plano B do `customStatement` não foi necessário.
- `drift_schemas/app/drift_schema_v1.json` gerado por `make-migrations`.
- `test/core/database/migration_test.dart`: schema v1 × dump (`SchemaVerifier`), banco novo × código gerado (`validateDatabaseSchema`), índice parcial e foreign keys ligadas.

**Decidido / desvios do plano**
- `make-migrations` só gera testes de migração com **duas ou mais** versões de schema (`make_migrations.dart`: `if (writer.schemas.length == 1) continue;`). Com só a v1 ele grava apenas o JSON. Os helpers foram gerados com `dart run drift_dev schema generate drift_schemas/app/ test/core/database/generated/` e o teste de v1 foi escrito à mão. Na v2, `make-migrations` passa a gerar os testes de passo em `test/core/database/`.
- `build_runner` 2.16 ignora `--delete-conflicting-outputs` ("These options have been removed"). O comando do `CLAUDE.md` continua funcionando (só avisa); não alterei o `CLAUDE.md`.
- Colunas comuns em um mixin (`EntityColumns`) em `core/database`, reaproveitável pelas próximas tabelas.
- `app_database.g.dart` é commitado (não há regra no `.gitignore` para `*.g.dart`), assim o projeto compila sem rodar codegen.

## 2026-09-24 — Passo 5: LocalCompanyRepository

**Feito**
- `company_mapper.dart` (linhas ↔ entidades, enums pelo `code`) e `LocalCompanyRepository` com todas as regras do plano: normalizar → validar → CNPJ duplicado → gravar em transação; upsert de módulos e registros; exclusão lógica em cascata; archive/unarchive idempotentes; filtros em Dart; ordenação por `normalizeForSearch(displayName)`.
- `local_company_repository_test.dart` (banco em memória, relógio fixo, ids sequenciais): 21 casos, cobrindo todos os itens da tabela de testes do plano.

**Decidido / desvios do plano**
- `@DataClassName('CompanyRow' | 'CompanyModuleRow' | 'CompanyAuthorityRow')` nas tabelas: o drift geraria `Company`, que colide com a entidade do domínio. O plano não previa; `plan.md` atualizado na seção Dados.
- Reatividade: `watchAll`/`watchById` usam uma consulta-gatilho (`customSelect('SELECT 1', readsFrom: {as 3 tabelas}).watch()`) e recarregam o agregado com `asyncMap`, com `distinct` para não emitir lista igual. Mais simples que combinar três streams sem `rxdart`, e cobre mudança em qualquer tabela.
- `updatedAt` da empresa só muda quando os dados cadastrais ou o arquivamento mudam; alterar só módulos/registros atualiza o `updatedAt` das linhas filhas, não o da empresa (leitura literal de "só nas linhas que mudaram de fato"). Se a task 003 precisar de "última alteração" do agregado, calcular pelo maior `updatedAt` entre as linhas.
- Empate na ordenação por nome resolvido pelo `id` (estável).
- Construtor com parâmetros nomeados privados (`required this._clock`, Dart ≥ 3.12); quem chama continua usando `clock:`/`newId:`, como no plano.

## 2026-09-24 — Passo 6: providers e ProviderScope

**Feito**
- `lib/core/providers.dart` (`clockProvider`, `idGeneratorProvider`) e `companyRepositoryProvider` em `local_company_repository.dart`, como no plano.
- `ProviderScope` em `main()`; `NormaTrackApp` inalterado, então `test/widget_test.dart` continua passando.
- `test/core/providers_test.dart`: o provider do repositório usa banco/relógio/ids sobrescritos, e o gerador padrão produz UUID v7 com relógio em UTC (teste extra, fora da tabela do plano).

# Plano técnico — 003

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md`, os `docs/` citados e o código. Quando algo não estiver aqui, **não invente**: registre a dúvida no `journal.md` e siga a regra de ambiguidade do `CLAUDE.md`. Suposições já tomadas estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código.

## Abordagem

Três telas de empresa (lista, formulário, detalhe) e o bottom sheet de registro em órgão, sobre o `CompanyRepository` da task 002, que não muda. Antes das telas vêm a navegação (`go_router` com barra inferior), a localização pt-BR e os componentes genéricos de `lib/app/widgets/` que o design system lista e ainda não existem. As telas leem dados por dois `StreamProvider`s (lista e empresa) e escrevem chamando o repositório direto. O estado do formulário é local da tela (`ConsumerStatefulWidget` com `TextEditingController`s), porque só existe enquanto ela está aberta.

**O que depende de prazos fica fora** (decisão da usuária, 2026-09-29): a situação na lista ("1 vencido", "Em dia"), as pílulas de resumo no cabeçalho do detalhe, o resumo de pendências por módulo, o botão "Gerar relatório" e a navegação para a tela do módulo. Cada lugar leva um `// TODO(RF-PRZ-05):` ou `// TODO(RF-REL-01):` / `// TODO(RF-EMP-03):`.

## Contexto do repositório (em 2026-09-29)

- Flutter 3.47.5, Dart 3.13.4, pacote `normatrack`. `analysis_options.yaml` usa `flutter_lints` e exclui `tasks/**`.
- Já existe (tasks 001, 002 e 004):
  - `lib/app/theme/`: `AppTheme.light`, `AppColors`, `AppSpacing` (inclui `screen` e `minTouch`), `AppRadius` (inclui `band`, `mdAll`, `lgAll`, `xlAll`, `pillAll`), `AppTypography` (`textTheme`, `number`, `tabular()`), `StatusColors`/`StatusTone`/`StatusStyle`.
  - `lib/app/widgets/status_chip.dart`: `StatusChip` e `StatusChip.iconFor(StatusTone)` (ícones de situação).
  - `lib/core/utils/`: `br_documents.dart` (`normalize*`, `isValid*`, `format*` de CNPJ, CPF, CEP e telefone; `digitsOnly`), `search_text.dart`, `clock.dart` (`Clock`, UTC), `id_generator.dart`.
  - `lib/core/providers.dart`: `clockProvider`, `idGeneratorProvider`.
  - `lib/features/companies/domain/`: `Company`, `CompanyInput`, `Address`, `LegalRepresentative`, `AuthorityRegistration` (com `isExpiredOn`), enums `ModuleType`, `Authority` (com `label` e `shortLabel`), `RegistrationStatus`, `BrazilianState`; `normalizeCompanyInput`, `validateCompany`, `CompanyField`, `CompanyFieldError(Type)`; `CompanyRepository`, `CompanyFilter`, `CompanyValidationException`, `DuplicateCnpjException`, `CompanyNotFoundException`. Leia esses arquivos antes de começar: os contratos estão lá e no [plano da 002](../002-empresas-dominio-e-dados/plan.md).
  - `lib/features/companies/data/local_company_repository.dart`: `companyRepositoryProvider` (`Provider<CompanyRepository>`).
  - `lib/main.dart`: `ProviderScope` em `main()`, `NormaTrackApp` com `MaterialApp(home: _HomePlaceholder())`.
- **Ainda não existe:** `go_router`, `flutter_localizations`, `lib/app/router.dart`, qualquer `presentation/`, e os widgets `AppTextField`, `NavRow`, `SwitchRow`, `EmptyState` etc.
- **Armadilhas conhecidas:**
  - `AppColors.onBandMuted` (subtítulo da faixa) não está no `ColorScheme`, e widgets fora de `lib/app/theme/` não podem usar `AppColors`. Por isso esta task cria a extensão `BandColors` (passo 2).
  - `test/widget_test.dart` monta `const NormaTrackApp()` sem `ProviderScope` e espera o texto `NormaTrack`. Ele **vai mudar** (passo 3): `NormaTrackApp` passa a depender do `routerProvider`.
  - Testes de widget **não usam drift**: o stream do drift deixa timers pendentes no `testWidgets` e o `drift_flutter` precisa de `path_provider`. Use o `FakeCompanyRepository` (seção Testes).
  - `DropdownButtonFormField.value` está depreciado nesta versão do Flutter: use `initialValue`.
  - **`go_router` 18.x não serve**: a 18.0.0 migrou para os pacotes `material_ui`/`cupertino_ui`, separados do `package:flutter/material.dart` que o app usa (o `Theme` seria outra classe). Fixe em `^17.5.0` (depende só de `flutter`). Reavalie quando o app migrar para `material_ui`.
- `updatedAt` da empresa não muda quando só módulos/registros mudam (journal da 002). Esta task **não** mostra "última alteração", então nada a fazer.

## Ordem de implementação

Branch: `task/003-empresas-telas`. Um commit por passo, no formato `feat(<escopo>): <o quê> [task 003, RF-EMP-0X]`, com a linha de coautoria que o harness indicar. Registre cada passo no `journal.md` à medida que avança; se o plano mudar, atualize este arquivo e explique no journal. Status → `em andamento` no primeiro commit.

1. **Setup**: dependências ([Setup](#setup)). `flutter pub get`, `flutter analyze` e `flutter test` continuam verdes.
2. **Tema e utilitários** (`feat(design)`, RNF-06): `BandColors`, `searchBarTheme`, `formatDate`, `input formatters`, com testes.
3. **Navegação** (`feat(app)`, RNF-06): `router.dart`, `AppShell`, telas provisórias de Painel e Ajustes, `NormaTrackApp` com `MaterialApp.router` e pt-BR, `widget_test.dart` atualizado. Depende de `EmptyState` e `BandTitle`: crie esses dois neste passo (com testes).
4. **Componentes** (`feat(design)`, RNF-06): os demais widgets de [Componentes](#componentes-libappwidgets), cada um com teste.
5. **Domínio** (`feat(empresas)`, RF-EMP-05): `RegistrationSituation` e `AuthorityRegistration.situationOn`, com testes.
6. **Lista** (`feat(empresas)`, RF-EMP-01): providers, `CompanyListScreen`, helpers de apresentação, `FakeCompanyRepository`, testes.
7. **Formulário e bottom sheet** (`feat(empresas)`, RF-EMP-04/02/05): `CompanyFormScreen`, `RegistrationSheet`, testes.
8. **Detalhe** (`feat(empresas)`, RF-EMP-03/05/01): `CompanyDetailScreen`, arquivar/desarquivar, testes.
9. **Docs e fechamento** (`docs(empresas)`): atualizar `docs/07-design-system.md` ([Docs](#docs-a-atualizar-no-mesmo-pr)), `docs/05-roadmap.md`, critérios no `README.md`, entrada final no journal, status `concluída` aqui e em `tasks/README.md`. `dart format .`, `flutter analyze` e `flutter test` sem erros. Não faça push nem abra PR sem a usuária pedir; quando pedir, o PR vai para `main` com `[task 003, RF-EMP-01..05]` no título.

## Setup

Versões resolvidas em 2026-09-29 (`flutter pub add --dry-run`):

```bash
flutter pub add 'go_router:^17.5.0' 'flutter_localizations:{"sdk":"flutter"}'
```

- `flutter_localizations` traz `intl 0.20.3` como transitiva. **Não** use `intl` direto: a data é formatada à mão (`formatDate`), e o `DatePicker` usa as `MaterialLocalizations` pt-BR.
- Sem codegen novo (nada de `go_router_builder`). Não rode `build_runner`: o schema do banco não muda.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| theme | `lib/app/theme/band_colors.dart` | `BandColors` (ThemeExtension) |
| theme | `lib/app/theme/app_theme.dart` | registra `BandColors.light`; `searchBarTheme`; exporta `band_colors.dart` |
| core | `lib/core/utils/date_format.dart` | `String formatDate(DateTime d)` → `dd/MM/yyyy` |
| app | `lib/app/formatters/br_input_formatters.dart` | `CnpjInputFormatter`, `CpfInputFormatter`, `PostalCodeInputFormatter`, `PhoneInputFormatter` |
| app | `lib/app/router.dart` | `AppRoutes`, `createAppRouter`, `routerProvider` |
| app | `lib/app/app_shell.dart` | `AppShell` (barra inferior) |
| app | `lib/app/placeholder_screens.dart` | `DashboardPlaceholderScreen`, `SettingsPlaceholderScreen` |
| app | `lib/main.dart` | `NormaTrackApp` como `ConsumerWidget` com `MaterialApp.router`; remove `_HomePlaceholder` |
| widgets | `lib/app/widgets/*.dart` | um arquivo por componente ([lista](#componentes-libappwidgets)) |
| domain | `lib/features/companies/domain/authority.dart` | `RegistrationSituation`, `AuthorityRegistration.situationOn` |
| presentation | `lib/features/companies/presentation/company_providers.dart` | `companiesProvider`, `companyProvider` |
| presentation | `lib/features/companies/presentation/company_labels.dart` | textos e mapeamentos de apresentação (ícones, descrições, situação → tom, mensagens de erro, cidade/UF) |
| presentation | `lib/features/companies/presentation/company_list_screen.dart` | `CompanyListScreen` |
| presentation | `lib/features/companies/presentation/company_form_screen.dart` | `CompanyFormScreen` |
| presentation | `lib/features/companies/presentation/registration_sheet.dart` | `showRegistrationSheet`, `RegistrationSheetResult` |
| presentation | `lib/features/companies/presentation/company_detail_screen.dart` | `CompanyDetailScreen` |

`presentation/` importa `domain/`, `lib/app/**`, `lib/core/utils/**` e `lib/core/providers.dart`, e obtém o repositório só por `companyRepositoryProvider` (tipo `CompanyRepository`). Nunca importa `AppDatabase` nem `data/` além desse provider.

## Tema e utilitários

**`BandColors`** (`ThemeExtension<BandColors>`, mesmo formato de `StatusColors`): um campo `final Color muted;` (texto secundário sobre a faixa). `static const light = BandColors(muted: AppColors.onBandMuted);`, `static BandColors of(BuildContext c) => Theme.of(c).extension<BandColors>() ?? light;`, `copyWith` e `lerp` (`Color.lerp`). Registrar em `extensions: const [StatusColors.light, BandColors.light]`.

**`searchBarTheme`** (busca da faixa, pílula branca sem borda):

```dart
searchBarTheme: SearchBarThemeData(
  elevation: const WidgetStatePropertyAll(0),
  backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
  shadowColor: const WidgetStatePropertyAll(Colors.transparent),
  surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
  side: const WidgetStatePropertyAll(BorderSide.none),
  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.pillAll)),
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
  textStyle: WidgetStatePropertyAll(text.bodyLarge),
  hintStyle: WidgetStatePropertyAll(text.bodyLarge?.copyWith(color: AppColors.placeholder)),
  constraints: const BoxConstraints(minHeight: AppSpacing.minTouch, maxHeight: AppSpacing.minTouch),
),
```

**`formatDate`**: `'${dd}/${MM}/${yyyy}'` com `padLeft(2, '0')` e ano com 4 dígitos. Dart puro.

**Input formatters** (`TextInputFormatter`, Flutter). Uma classe privada `_MaskFormatter` faz o trabalho:

1. Pega `newValue.text`, passa para maiúsculas, mantém só os caracteres permitidos e corta no tamanho máximo.
2. Aplica a máscara progressivamente: percorre a máscara; `#` consome o próximo caractere bruto; qualquer outro caractere da máscara é literal e só entra **se ainda houver caractere bruto a consumir** (nunca termina em literal, então o backspace no fim sempre apaga um caractere bruto).
3. Devolve o texto formatado com o cursor no fim (`TextSelection.collapsed(offset: text.length)`).

| Classe | Permitidos | Máx. | Máscara |
|---|---|---|---|
| `CnpjInputFormatter` | `[0-9A-Z]` (após maiúsculas) | 14 | `##.###.###/####-##` |
| `CpfInputFormatter` | `[0-9]` | 11 | `###.###.###-##` |
| `PostalCodeInputFormatter` | `[0-9]` | 8 | `#####-###` |
| `PhoneInputFormatter` | `[0-9]` | 11 | até 10 dígitos `(##) ####-####`; com 11, `(##) #####-####` |

Limitação aceita: editar no meio do texto joga o cursor para o fim. O CNPJ aceita letras (CNPJ alfanumérico, ver plano da 002), então o campo usa teclado de texto com `TextCapitalization.characters`, e não teclado numérico como no wireframe.

## Navegação

```dart
abstract final class AppRoutes {
  static const dashboard = '/painel';
  static const companies = '/empresas';
  static const newCompany = '/empresas/nova';
  static String company(String id) => '/empresas/$id';
  static String editCompany(String id) => '/empresas/$id/editar';
  static const settings = '/ajustes';
}

GoRouter createAppRouter({String initialLocation = AppRoutes.dashboard});

final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});
```

Estrutura (uma `GlobalKey<NavigatorState>` raiz, `_rootKey`):

- `StatefulShellRoute.indexedStack(builder: (context, state, shell) => AppShell(shell: shell), branches: [...])`
  - ramo 0: `GoRoute('/painel')` → `DashboardPlaceholderScreen`
  - ramo 1: `GoRoute('/empresas')` → `CompanyListScreen`, com filhas, **nesta ordem** (`nova` antes de `:id`), todas com `parentNavigatorKey: _rootKey` para cobrir a barra inferior:
    - `GoRoute('nova')` → `CompanyFormScreen()`
    - `GoRoute(':id')` → `CompanyDetailScreen(companyId: state.pathParameters['id']!)`, com filha `GoRoute('editar', parentNavigatorKey: _rootKey)` → `CompanyFormScreen(companyId: id)`
  - ramo 2: `GoRoute('/ajustes')` → `SettingsPlaceholderScreen`

`AppShell`: `Scaffold(body: shell, bottomNavigationBar: ClipRRect(borderRadius: vertical top AppRadius.xl, child: NavigationBar(...)))`. Destinos: Painel (`Icons.space_dashboard_outlined`), Empresas (`Icons.apartment_outlined`), Ajustes (`Icons.settings_outlined`). `onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex)`.

`NormaTrackApp` (`ConsumerWidget`):

```dart
MaterialApp.router(
  title: 'NormaTrack',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  themeMode: ThemeMode.light,
  routerConfig: ref.watch(routerProvider),
  locale: const Locale('pt', 'BR'),
  supportedLocales: const [Locale('pt', 'BR')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
)
```

Telas provisórias (`placeholder_screens.dart`), cada uma `Scaffold(appBar: AppBar(title: BandTitle(..., large: true)), body: EmptyState(...))`:

| Tela | Título | `EmptyState` |
|---|---|---|
| `DashboardPlaceholderScreen` | Painel | ícone `space_dashboard_outlined`; "Painel em construção"; "Os próximos vencimentos aparecem aqui quando os prazos forem cadastrados."; ação "Ver empresas" → `context.go(AppRoutes.companies)`. `// TODO(RF-PRZ-05):` |
| `SettingsPlaceholderScreen` | Ajustes | ícone `settings_outlined`; "Ajustes em construção"; "Notificações, antecedência padrão e backup ficam aqui."; sem ação. `// TODO(RF-PRZ-03):` |

## Componentes (`lib/app/widgets/`)

Cada um em seu arquivo (`snake_case` do nome), só com `Theme.of(context)`, `StatusColors.of`, `BandColors.of`, `AppSpacing` e `AppRadius`. Cada um com teste em `test/app/widgets/<arquivo>_test.dart`, montado em `MaterialApp(theme: AppTheme.light, home: Scaffold(body: ...))`.

| Widget | Assinatura | Comportamento |
|---|---|---|
| `BandTitle` | `({required String title, String? subtitle, bool large = false})` | Coluna para o `title:` do `AppBar`. Título em `titleLarge` (ou `headlineMedium` se `large`), cor `colorScheme.onPrimary`, 1 linha com reticências. Subtítulo em `bodyMedium` com `BandColors.of(context).muted`, algarismos tabulares (`AppTypography.tabular`). `large` só nas telas da barra inferior |
| `EmptyState` | `({required IconData icon, required String title, required String message, String? actionLabel, VoidCallback? onAction})` | Centralizado, padding `AppSpacing.xl`. Ícone 48 em `colorScheme.primary`, título `titleMedium`, mensagem `bodyMedium` centralizada, e `FilledButton.tonal(actionLabel)` se os dois vierem juntos (`assert` se só um vier) |
| `SectionCard` | `({required String title, String? caption, String? description, required List<Widget> children})` | Cabeçalho com padding horizontal `xs`: título `titleMedium` e `caption` à direita (`bodyMedium`); `description` abaixo do título (`bodyMedium`). Depois um `Card` com os `children` separados por `Divider` (sem divisória antes do primeiro). Espaço entre cabeçalho e card: `sm` |
| `StatusText` | `({required String label, StatusTone? tone})` | Linha com ícone 16 (`StatusChip.iconFor`) + texto `labelMedium` na cor forte do tom. Sem tom: só o texto em `colorScheme.onSurfaceVariant`, sem ícone. `Semantics(label: 'Situação: $label')` só quando há tom |
| `NavRow` | `({IconData? leadingIcon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap})` | `InkWell`, altura mínima 52, padding `EdgeInsets.fromLTRB(lg, sm, md, sm)`. Ícone opcional num quadrado 40 (`primaryContainer`, raio `md`, ícone `primary`). Título `bodyLarge` w600 (`textTheme.bodyLarge` + `labelLarge.fontWeight`); subtítulo `bodyMedium`. `trailing` (normalmente `StatusText`) e, se `onTap != null`, `Icons.chevron_right` em `colorScheme.onSurfaceVariant` |
| `SwitchRow` | `({IconData? leadingIcon, required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged})` | Mesmo layout do `NavRow` (altura mínima 64), com `Switch` no fim. Tocar na linha inteira alterna. `MergeSemantics` para o leitor de tela ler título + estado |
| `InfoRow` | `({required String label, required List<String> lines})` | Rótulo `bodyMedium` à esquerda; linhas à direita, alinhadas à direita, a 1ª em `bodyLarge` com o peso de `labelLarge` (mesma derivação do `NavRow`, sem `FontWeight` literal) e as demais em `bodyMedium`, todas tabulares. Padding `lg`/`md` |
| `AppTextField` | `({required String label, TextEditingController? controller, String? hint, bool required = false, String? errorText, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, TextCapitalization textCapitalization = TextCapitalization.none, int? maxLines = 1, int? minLines, bool readOnly = false, VoidCallback? onTap, Widget? suffixIcon, ValueChanged<String>? onChanged, TextInputAction? textInputAction, bool tabular = false})` | Coluna: rótulo `labelMedium` acima (com ` *` em `colorScheme.error` se `required`), espaço `xs`, `TextField`. Nunca usa `labelText`. Erro: `InputDecoration(error: Row(Icon(Icons.error_outline, 16), Text(errorText)))` na cor `colorScheme.error` e `bodySmall`, o que também pinta a borda de erro do tema. `tabular` aplica `AppTypography.tabular` ao texto |
| `AppDropdownField<T>` | `({required String label, required T? value, required List<T> items, required String Function(T) itemLabel, String Function(T)? selectedLabel, String? hint, required ValueChanged<T?> onChanged})` | Mesmo layout do `AppTextField`, com `DropdownButtonFormField<T>(initialValue: value, ...)`. Primeiro item fixo "Nenhuma" (valor `null`) para limpar. `selectedItemBuilder` usa `selectedLabel ?? itemLabel`. Como `initialValue` só vale na criação, use `key: ValueKey(value)` para refletir mudanças externas |
| `AppActionBar` | `({required List<Widget> children})` | Rodapé das telas internas: `Material` com `colorScheme.surfaceContainerLowest`, cantos superiores `AppRadius.xl`, padding `EdgeInsets.fromLTRB(lg, md, lg, lg)` dentro de `SafeArea(top: false)`, `Row` com espaço `md` entre os filhos. Usado em `Scaffold.bottomNavigationBar` |
| `DestructiveButton` | `({required String label, IconData? icon, required VoidCallback? onPressed})` | `OutlinedButton` (com ícone se houver) com `foregroundColor` e `side` em `colorScheme.error` via `OutlinedButton.styleFrom` |
| `showConfirmDialog` | `Future<bool> showConfirmDialog(BuildContext, {required String title, required String message, required String confirmLabel, bool destructive = false})` | `AlertDialog` com `TextButton('Cancelar')` e `TextButton(confirmLabel)`; se `destructive`, o de confirmar usa `colorScheme.error`. Devolve `true` só se confirmou (fechar fora = `false`). Arquivo `confirm_dialog.dart` |

## Domínio (acréscimo)

Em `authority.dart`:

```dart
/// Situação de um registro numa data. A UI converte para StatusTone.
enum RegistrationSituation { registered, expired, required }

// em AuthorityRegistration:
/// `required` se a situação é "precisa obter"; senão `expired` se
/// `isExpiredOn(today)`; senão `registered`.
RegistrationSituation situationOn(DateTime today);
```

"Não se aplica" não é situação: é a ausência do registro no mapa. Não existe "a vencer" para registro. `// TODO(RF-EMP-05): alerta antes da validade depende de C16.`

## Apresentação

### Providers (`company_providers.dart`)

```dart
final companiesProvider = StreamProvider.autoDispose
    .family<List<Company>, CompanyFilter>(
      (ref, filter) => ref.watch(companyRepositoryProvider).watchAll(filter),
    );

final companyProvider = StreamProvider.autoDispose.family<Company?, String>(
  (ref, id) => ref.watch(companyRepositoryProvider).watchById(id),
);
```

`CompanyFilter` já tem `==`/`hashCode`, então serve de chave. Escritas (`create`, `update`, `archive`, `unarchive`) chamam `ref.read(companyRepositoryProvider)` direto na tela. "Hoje" = `ref.read(clockProvider)().toLocal()`.

### Rótulos e mapeamentos (`company_labels.dart`)

```dart
extension ModuleTypeUi on ModuleType { IconData get icon; String get description; }
```

| Módulo | Ícone | Descrição (formulário) |
|---|---|---|
| `environmental` | `Icons.eco_outlined` | Licenças, ruídos, resíduos, ETE/ETA |
| `controlledProducts` | `Icons.shield_outlined` | Polícia Federal e Exército |
| `qualityControl` | `Icons.science_outlined` | Produtos, lotes, estoque |

`({String label, StatusTone? tone}) registrationDisplay(AuthorityRegistration? r, DateTime today)`, usado **igual** no formulário e no detalhe:

| Caso | Rótulo | Tom |
|---|---|---|
| `r == null` | Não se aplica | `null` (texto neutro) |
| `required` | Precisa obter | `StatusTone.dueSoon` |
| `expired` | Venceu `dd/MM/yyyy` | `StatusTone.overdue` |
| `registered` com validade | Até `dd/MM/yyyy` | `StatusTone.ok` |
| `registered` sem validade | Possui registro | `StatusTone.ok` |

O wireframe do formulário mostra a situação em pílula sem ícone. Aqui ela usa `StatusText` (texto colorido com ícone), como o `NavRow` do design system prevê: um padrão só para formulário e detalhe.

`String? cityState(Address a)`: `"Cidade/UF"`; só cidade → `"Cidade"`; só UF → `"UF"`; nada → `null`.

`String companyFieldMessage(CompanyFieldError e, CompanyInput normalized)`:

| Campo | Tipo | Mensagem |
|---|---|---|
| `legalName` | required | Informe a razão social |
| `cnpj` | invalid | `normalized.cnpj!.length < 14` ? "CNPJ incompleto" : "CNPJ inválido" |
| `legalRepCpf` | invalid | `< 11` ? "CPF incompleto" : "CPF inválido" |
| `postalCode` | invalid | CEP incompleto |
| `phone`, `legalRepPhone` | invalid | Telefone incompleto |
| `email`, `legalRepEmail` | invalid | E-mail inválido |

`DuplicateCnpjException` → erro no campo CNPJ: "Já existe uma empresa com este CNPJ (ativa ou arquivada)".

### Lista (`CompanyListScreen`, rota `/empresas`)

Wireframe: `docs/design/wireframes/Empresas.dc.html`. `ConsumerStatefulWidget` com estado `bool _archived = false`, `String _query = ''` e `List<Company>? _last`.

- `AppBar(title: BandTitle(title: 'Empresas', large: true), bottom: PreferredSize(...))`. O `bottom` é um `SearchBar` (`hintText: 'Buscar por nome ou CNPJ'`, `leading: Icon(Icons.search)`, `onChanged` → `setState(_query)`) com padding `EdgeInsets.fromLTRB(lg, 0, lg, lg)`. Altura do `PreferredSize` = 48 + `lg`.
- Corpo: `Column` com padding `AppSpacing.screen` + topo `lg`:
  - `SegmentedButton<bool>` largura total (`expandedInsets: EdgeInsets.zero`), `showSelectedIcon: false`, segmentos `false` "Ativas" e `true` "Arquivadas".
  - Lista: `ref.watch(companiesProvider(CompanyFilter(archived: _archived, query: _query.trim().isEmpty ? null : _query)))`. Com dado, guarde em `_last`. Enquanto carrega, mostre `_last` se houver (evita piscar a cada tecla), senão `CircularProgressIndicator` centralizado. Erro: `EmptyState(icon: Icons.error_outline, title: 'Não foi possível carregar as empresas', message: 'Tente abrir a tela de novo.')`.
  - Cada empresa é um `Card` com `NavRow(title: company.displayName, subtitle: cityState(address), onTap: () => context.go(AppRoutes.company(id)))`, espaço `sm` entre cards, `ListView` com padding inferior 88 para não ficar sob o FAB. `// TODO(RF-PRZ-05): pior situação dos prazos à direita.`
  - Vazio (escolha nesta ordem):

    | Condição | Título | Mensagem | Ação |
    |---|---|---|---|
    | busca não vazia | Nenhuma empresa encontrada | Confira o nome ou o CNPJ digitado. | — |
    | `_archived` | Nenhuma empresa arquivada | Empresas arquivadas aparecem aqui. | — |
    | ativas | Nenhuma empresa cadastrada | Cadastre a primeira empresa para acompanhar prazos e registros. | Cadastrar empresa → `AppRoutes.newCompany` |

    Ícone `Icons.apartment_outlined` nos três.
- `FloatingActionButton.extended(icon: Icon(Icons.add), label: Text('Nova empresa'), onPressed: → context.go(AppRoutes.newCompany))`.

### Formulário (`CompanyFormScreen({String? companyId})`, rotas `/empresas/nova` e `/empresas/:id/editar`)

Wireframe: `EmpresaForm.dc.html`. `ConsumerStatefulWidget`.

**Carga.** Criar: estado vazio. Editar: `initState` chama `repo.findById(companyId)`; enquanto carrega, `CircularProgressIndicator`; `null` → `EmptyState(title: 'Empresa não encontrada', message: 'Ela pode ter sido excluída.', actionLabel: 'Voltar', onAction: → context.go(AppRoutes.companies))`. Com a empresa, preencha a partir de `company.toInput()`, **formatando** os documentos (`formatCnpj`, `formatCpf`, `formatPostalCode`, `formatPhone`) para bater com as máscaras. Guarde esse input inicial (`_initial`) para saber se há alterações.

**Estado.** Um `TextEditingController` por campo de texto; `BrazilianState? _state`; `Set<ModuleType> _modules`; `Map<Authority, AuthorityRegistration> _registrations`; `Map<CompanyField, String> _errors`; `bool _saving`; `bool _saved`. `CompanyInput _currentInput()` monta o input dos controllers (texto bruto, com máscara: o repositório normaliza). Editar um campo remove o erro dele de `_errors`.

**Layout.** `Scaffold`:
- `AppBar(leading: IconButton(Icons.close, tooltip: 'Fechar', onPressed: → Navigator.maybePop), title: BandTitle(title: companyId == null ? 'Nova empresa' : 'Editar empresa'))`.
- Corpo: `ListView` com padding `AppSpacing.screen` + topo `lg`/base `xl`, espaço `lg` entre seções. Primeiro, `Text('Só a razão social é obrigatória. O resto pode ser preenchido depois.', style: bodyMedium)`. Depois as seções (`SectionCard`), cada campo com espaço `md` dentro de um `Padding(lg)`:

| Seção | Campos (`AppTextField` salvo indicação) |
|---|---|
| Identificação | Razão social * (`hint: 'Ex.: Indústria Alfa Ltda'`, `words`) · Nome fantasia (`hint: 'Como aparece nas listas'`, `words`) · CNPJ (`CnpjInputFormatter`, `characters`, `tabular`) · Inscrição estadual (`hint: 'Opcional'`, `characters`) |
| Endereço | CEP (`hint: '00000-000'`, `number`, formatter, `tabular`) · Logradouro (`hint: 'Rua, avenida…'`) · Número (`hint: 'Nº'`) e Complemento (`hint: 'Sala, galpão…'`) lado a lado (`Row`, flex 1 e 2) · Bairro · Cidade e UF lado a lado (flex 3 e 1). UF = `AppDropdownField<BrazilianState>` com `itemLabel: '${s.code} · ${s.label}'` e `selectedLabel: s.code`, sem valor padrão **[suposição: não pré-selecionar CE]** |
| Contato | Telefone (`hint: '(00) 00000-0000'`, `phone`, formatter, `tabular`) · E-mail (`hint: 'contato@empresa.com.br'`, `emailAddress`) |
| Responsável legal | Nome (`words`) · CPF (`hint: '000.000.000-00'`, `number`, formatter, `tabular`) · Telefone (como acima) · E-mail |
| Módulos (`description: 'Só os módulos ligados aparecem para a empresa.'`) | Um `SwitchRow` por `ModuleType` (ordem do enum), com `leadingIcon`, `title: label`, `subtitle: description`. Nenhum ligado por padrão (suposição da 002) |
| Órgãos (`description: 'Toque em um órgão para informar o registro.'`) | Um `NavRow` por `Authority` (ordem do enum), `title: label`, `trailing: StatusText` de `registrationDisplay(_registrations[a], hoje)`, `onTap` → `showRegistrationSheet`; com resultado, atualiza `_registrations` (remove a chave se `registration == null`) |

Módulos e órgãos são independentes: ligar um não mexe no outro (C15).

- `bottomNavigationBar: AppActionBar(children: [OutlinedButton('Cancelar' → Navigator.maybePop), Expanded(FilledButton('Salvar empresa' → _save))])`. Enquanto `_saving`, o `FilledButton` fica desabilitado.

**Salvar (`_save`).**
1. `final input = _currentInput(); final normalized = normalizeCompanyInput(input); final errors = validateCompany(normalized);`
2. Com erros: preencha `_errors` com `companyFieldMessage`, e role até o primeiro campo com erro (na ordem do enum `CompanyField`) com `Scrollable.ensureVisible(key.currentContext!)`. Cada campo validável tem uma `GlobalKey`. Não chame o repositório.
3. Sem erros: `_saving = true`; `create(input)` ou `update(companyId, input)`.
   - `DuplicateCnpjException` → `_errors[CompanyField.cnpj] = ...` e rola até o CNPJ.
   - `CompanyValidationException` (não deve ocorrer) → mesmo tratamento do passo 2.
   - `CompanyNotFoundException` → `SnackBar('Empresa não encontrada')` e `context.go(AppRoutes.companies)`.
4. Sucesso: `_saved = true`; `SnackBar('Empresa salva')`. Criar → `context.go(AppRoutes.company(novo.id))`. Editar → `context.pop()` (volta ao detalhe, que observa o repositório).

**Descartar alterações.** `PopScope(canPop: _saved || !_isDirty, onPopInvokedWithResult: ...)`, com `_isDirty = normalizeCompanyInput(_currentInput()) != normalizeCompanyInput(_initial)` (`_initial` = `CompanyInput(legalName: '')` ao criar). Se o pop foi bloqueado: `showConfirmDialog(title: 'Descartar alterações?', message: 'O que foi preenchido nesta tela será perdido.', confirmLabel: 'Descartar', destructive: true)`; confirmou → `_saved = true` (libera) e `context.pop()`.

### Bottom sheet de registro (`registration_sheet.dart`)

Wireframe: `EmpresaOrgao.dc.html`.

```dart
class RegistrationSheetResult {
  const RegistrationSheetResult(this.registration);
  final AuthorityRegistration? registration; // null = não se aplica
}

/// null = fechou sem aplicar (nada muda).
Future<RegistrationSheetResult?> showRegistrationSheet(
  BuildContext context, {required Authority authority,
  AuthorityRegistration? current, required DateTime today});
```

`showModalBottomSheet(isScrollControlled: true, useSafeArea: true, showDragHandle: true)`, conteúdo com padding `lg` + `MediaQuery.viewInsetsOf(context).bottom` e rolável. Estado local: um enum privado `_Choice { notApplicable, registered, required }` (inicial a partir de `current`), controllers de nº e observações, `DateTime? validUntil`.

- Cabeçalho: `authority.label` (`titleMedium`), abaixo "Registro da empresa neste órgão" (`bodyMedium`), e `IconButton(Icons.close, tooltip: 'Fechar')` à direita, que fecha com `null`.
- "Situação" (`labelMedium`) + `SegmentedButton<_Choice>` largura total, sem ícone: "Não se aplica" · "Possui" · "Precisa obter".
- Só com **Possui**: `AppTextField('Nº do registro')` e `AppTextField('Validade', readOnly: true, tabular: true)` mostrando `formatDate(validUntil)` (hint `dd/mm/aaaa`). Tocar abre `showDatePicker(context: context, initialDate: validUntil ?? today, firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: 'Validade')`. `suffixIcon`: sem data, `Icon(Icons.calendar_today_outlined)`; com data, `IconButton(Icons.close, tooltip: 'Remover validade')` que limpa. Se `validUntil` já passou (`AuthorityRegistration(...).isExpiredOn(today)`), `errorText: 'Validade vencida em dd/MM/yyyy'` (aviso, não bloqueia).
- Com **Possui** ou **Precisa obter**: `AppTextField('Observações', hint: 'Opcional', maxLines: 3, minLines: 2)`.
- `FilledButton('Aplicar')` largura total, que fecha com:
  - Não se aplica → `RegistrationSheetResult(null)`
  - Possui → `AuthorityRegistration(authority, registered, registrationNumber, validUntil, notes)`
  - Precisa obter → `AuthorityRegistration(authority, required, notes: notes)`: **nº e validade são descartados** (critério de aceite: só aparecem com "possui registro"), mesmo que o domínio os aceite.

### Detalhe (`CompanyDetailScreen({required String companyId})`, rota `/empresas/:id`)

Wireframe: `EmpresaDetalhe.dc.html`. `ConsumerWidget` sobre `companyProvider(companyId)`. Carregando: `Scaffold` com `AppBar` vazio e `CircularProgressIndicator`. `null`: `EmptyState('Empresa não encontrada', 'Ela pode ter sido excluída.', 'Voltar' → context.go(AppRoutes.companies))`. Erro: mesmo `EmptyState` com título "Não foi possível carregar a empresa".

- `AppBar(title: BandTitle(title: displayName, subtitle: [if cnpj 'CNPJ ${formatCnpj(cnpj)}', if isArchived 'Arquivada'].join(' · ') ou null), actions: [IconButton(Icons.edit_outlined, tooltip: 'Editar empresa', → context.go(AppRoutes.editCompany(id)))])`. `// TODO(RF-PRZ-05): resumo de situação (pílulas) na faixa.`
- Corpo: `ListView`, padding `AppSpacing.screen` + topo `lg`/base `xl`, espaço `lg` entre seções:
  1. **Módulos** (`SectionCard`): um `NavRow(leadingIcon, title: label)` sem `onTap` por módulo habilitado (ordem do enum). Nenhum habilitado → um `NavRow(title: 'Habilitar módulos', onTap: → editar)`. `// TODO(RF-EMP-03): abrir a tela do módulo e mostrar pendências (RF-PRZ-05).`
  2. **Órgãos** (`SectionCard`, `caption: '$n de 9 se aplicam'`): um `NavRow` por registro presente (ordem do enum), `title: label`, `subtitle`: `['Nº $numero', notes]` sem os nulos, juntos por ` · ` (ou `null`), `trailing: StatusText(registrationDisplay(...))`, sem `onTap`. Último item: `NavRow(title: n > 0 ? 'Ver todos os 9 órgãos' : 'Informar órgãos', onTap: → editar)`.
  3. **Dados da empresa** (`SectionCard`): `InfoRow`s só para o que existe, nesta ordem:

     | Rótulo | Linhas |
     |---|---|
     | Razão social | `legalName` (só se há `tradeName`: o título já mostra o `displayName`) |
     | Inscrição estadual | `stateRegistration` |
     | Endereço | `street[, number][ - complement]`; `district · cityState` (partes ausentes omitidas); `CEP ${formatPostalCode}` — linhas vazias omitidas |
     | Telefone | `formatPhone(phone)` |
     | E-mail | `email` |
     | Responsável legal | `name`; `CPF ${formatCpf}`; `formatPhone(phone)`; `email` — linhas vazias omitidas |

     Sem nenhuma linha: um `Padding(lg)` com `Text('Só a razão social foi informada.')`. O CNPJ não se repete aqui: já está na faixa.
  4. Ação no fim, largura total. `// TODO(RF-REL-01): botão "Gerar relatório" (tonal) quando houver relatórios.`
     - Ativa: `DestructiveButton(icon: Icons.archive_outlined, label: 'Arquivar')` → `showConfirmDialog(title: 'Arquivar empresa?', message: 'Ela sai da lista de ativas e pode ser desarquivada depois, em Arquivadas.', confirmLabel: 'Arquivar', destructive: true)` → `repo.archive(id)` → volta para a lista (`context.canPop() ? context.pop() : context.go(AppRoutes.companies)`) → `SnackBar('Empresa arquivada', action: SnackBarAction('Desfazer' → repo.unarchive(id)))`. Pegue o `ScaffoldMessenger` e o repositório **antes** do pop.
     - Arquivada: `OutlinedButton.icon(Icons.unarchive_outlined, 'Desarquivar')`, sem confirmação → `repo.unarchive(id)` → `SnackBar('Empresa desarquivada')`, fica no detalhe.
     - Falha (`CompanyNotFoundException`) → `SnackBar('Não foi possível concluir. A empresa não foi encontrada.')`.

Excluir empresa pela UI continua fora de escopo.

## Testes

A pasta `test/` espelha `lib/`. "Hoje" nos testes: `DateTime.utc(2026, 9, 29, 12)` (em qualquer fuso do Brasil, a data local é 29/09/2026).

**Helpers** (`test/helpers/`):

- `fake_company_repository.dart`: `FakeCompanyRepository implements CompanyRepository`, em memória. `create`/`update` fazem `normalizeCompanyInput` → `validateCompany` (lança `CompanyValidationException`) → CNPJ duplicado entre as não excluídas, exceto a própria (lança `DuplicateCnpjException`), com ids `'c1'`, `'c2'`… e relógio fixo. `archive`/`unarchive`/`delete` como no plano da 002 (inexistente → `CompanyNotFoundException`). `watchAll` aplica só `archived` e `query` (mesma regra da 002: `normalizeForSearch` em razão social/nome fantasia, ou `normalizeCnpj` contido no CNPJ) e ordena por `normalizeForSearch(displayName)`; `module`/`authority`/`status` são ignorados (a UI não os usa). Streams: `StreamController.broadcast`, e cada `watch*` emite o valor atual ao ser ouvido e de novo a cada mudança. Método `Future<Company> seed(CompanyInput input, {bool archived = false})` para montar cenários.
- `pump_app.dart`: `Future<void> pumpApp(WidgetTester tester, {FakeCompanyRepository? repository, String initialLocation = AppRoutes.dashboard})`. Define a tela em 390 × 844 lógicos (`tester.view.physicalSize = const Size(1170, 2532)`, `devicePixelRatio = 3`, com `addTearDown(tester.view.reset)`), monta `ProviderScope(overrides: [companyRepositoryProvider.overrideWithValue(repo), clockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 12)), routerProvider.overrideWith((ref) { final r = createAppRouter(initialLocation: initialLocation); ref.onDispose(r.dispose); return r; })], child: const NormaTrackApp())` e faz `pumpAndSettle`. Use `tester.scrollUntilVisible` / `ensureVisible` para campos abaixo da dobra.

**Dados de exemplo conferidos** (dígitos verificadores calculados por script em 2026-09-29): CNPJs válidos `11222333000181`, `22333444000181`, `98765432000198`, `12ABC34501DE35`; inválido `11222333000182`. CPF válido `12345678909`; inválido `12345678900`.

| Arquivo | Casos obrigatórios |
|---|---|
| `test/core/utils/date_format_test.dart` | `DateTime(2026, 8, 2)` → `02/08/2026`; `DateTime(2027, 12, 31)` → `31/12/2027` |
| `test/app/formatters/br_input_formatters_test.dart` | CNPJ: `11222333000181` → `11.222.333/0001-81`; `12abc34501de35` → `12.ABC.345/01DE-35`; `1234` → `12.34`; 15 caracteres cortados em 14; `12-3` → `12.3`. CPF `12345678909` → `123.456.789-09`. CEP `61939000` → `61939-000`. Telefone `8533334444` → `(85) 3333-4444`, `85999998888` → `(85) 99999-8888`, `853` → `(85) 3`, `8` → `(8`. Cursor sempre no fim |
| `test/app/theme/app_theme_test.dart` (acrescentar) | `BandColors` registrada com `AppColors.onBandMuted`; `searchBarTheme.backgroundColor` resolve para `AppColors.surface` |
| `test/app/widgets/<widget>_test.dart` (um por componente) | `BandTitle`: título e subtítulo aparecem; subtítulo usa `BandColors.muted`. `EmptyState`: sem ação não há botão; com ação, tocar chama o callback. `SectionCard`: título, caption e uma `Divider` a menos que filhos. `StatusText`: com tom, ícone de `StatusChip.iconFor` e cor forte; sem tom, sem ícone. `NavRow`: chevron só com `onTap`; tocar chama. `SwitchRow`: tocar na linha alterna. `InfoRow`: rótulo e linhas. `AppTextField`: `*` com `required`; `errorText` mostra ícone + texto; rótulo não é `labelText`. `AppDropdownField`: escolher item chama `onChanged`; "Nenhuma" devolve `null`. `AppActionBar`: filhos aparecem. `DestructiveButton`: cor de erro. `showConfirmDialog`: Cancelar → `false`, confirmar → `true` |
| `test/features/companies/domain/company_test.dart` (acrescentar) | `situationOn`: `required` (mesmo vencido) → `required`; `registered` vencido ontem → `expired`; vence hoje → `registered`; sem validade → `registered` |
| `test/features/companies/presentation/company_labels_test.dart` | As 5 linhas de `registrationDisplay`; `cityState` nos 4 casos; `companyFieldMessage` para CNPJ incompleto × inválido e CPF incompleto × inválido |
| `test/widget_test.dart` (reescrever) | `pumpApp` abre no Painel com "Painel em construção" e a `NavigationBar` com Painel, Empresas e Ajustes; tocar em Empresas mostra "Nenhuma empresa cadastrada"; tocar em Ajustes mostra "Ajustes em construção" |
| `test/features/companies/presentation/company_list_screen_test.dart` | Vazio → "Nenhuma empresa cadastrada" e ação abre "Nova empresa". Com `Indústria Alfa Ltda` (Maracanaú/CE, ativa) e `Beta Alimentos S.A.` (arquivada): Ativas mostra Alfa com "Maracanaú/CE" e não Beta; Arquivadas mostra Beta. Busca "alfa" e "industria" (sem acento) acham Alfa; "11.222.333" acha pelo CNPJ; "xyz" → "Nenhuma empresa encontrada". FAB abre "Nova empresa". Tocar em Alfa abre o detalhe e esconde a `NavigationBar` |
| `test/features/companies/presentation/company_form_screen_test.dart` | Só razão social → salva, abre o detalhe da empresa e o repositório tem 1 empresa. Razão social vazia → "Informe a razão social" e nada salvo. CNPJ `11222333000182` → "CNPJ inválido"; `1122233300` → "CNPJ incompleto"; CPF `12345678900` → "CPF inválido"; e-mail `a@b` → "E-mail inválido"; CEP `6193` → "CEP incompleto". Digitar `11222333000181` mostra `11.222.333/0001-81`. CNPJ de empresa arquivada já cadastrada → "Já existe uma empresa com este CNPJ (ativa ou arquivada)". Ligar "Ambiental" e salvar → `enabledModules == {environmental}`. Órgão: tocar "Polícia Federal" abre o sheet; "Possui" mostra "Nº do registro" e "Validade"; "Precisa obter" os esconde; Aplicar → linha mostra "Precisa obter". Editar: título "Editar empresa", campos formatados (CNPJ com máscara), salvar volta ao detalhe com o valor novo. Alterar um campo e tocar em Fechar → "Descartar alterações?"; Cancelar mantém a tela; Descartar sai. Sem alterações, Fechar sai direto |
| `test/features/companies/presentation/registration_sheet_test.dart` | Com `current` registrado e validade `2026-08-02` → "Validade vencida em 02/08/2026". Possui com nº `CRC 2024/0187` → Aplicar devolve registro com nº. Trocar para "Precisa obter" e Aplicar → nº e validade `null`, observação mantida. "Não se aplica" → `RegistrationSheetResult(null)`. Fechar (X) → `null`. (Monte um botão que chama `showRegistrationSheet` dentro de `MaterialApp(theme: AppTheme.light)`.) |
| `test/features/companies/presentation/company_detail_screen_test.dart` | Empresa com Ambiental habilitado → "Ambiental" aparece e "Produtos controlados" não. Registros SEMACE (validade `2027-03-10`), Polícia Federal (validade `2026-08-02`), Prefeitura (precisa obter) → "3 de 9 se aplicam", "Até 10/03/2027", "Venceu 02/08/2026", "Precisa obter", e ANVISA não aparece. Faixa com "CNPJ 11.222.333/0001-81"; dados com "CEP 61939-000", "(85) 3333-4444", "CPF 123.456.789-09". Arquivar → diálogo; Cancelar não muda nada; confirmar volta à lista, a empresa some de Ativas, aparece em Arquivadas e o SnackBar "Empresa arquivada" aparece. Empresa arquivada mostra "Desarquivar" e "Arquivada" na faixa; tocar desarquiva. Id inexistente → "Empresa não encontrada". Editar (lápis) abre "Editar empresa" |

## Docs a atualizar no mesmo PR

- `docs/07-design-system.md`:
  - Tabela de componentes: marcar ✅ `EmptyState`, `NavRow`/`SwitchRow`, `AppTextField`; acrescentar `BandTitle`, `SectionCard`, `StatusText`, `InfoRow`, `AppDropdownField`, `AppActionBar`, `DestructiveButton`/`showConfirmDialog`, com uma linha de uso cada.
  - Tokens: `BandColors` (`muted` = `onBandMuted`) e a busca da faixa via `searchBarTheme`.
  - Situação de registro em órgão: a tabela de `registrationDisplay` (rótulo × tom) e a nota de que o formulário usa `StatusText`, não pílula.
- `docs/05-roadmap.md`: marcar "CRUD de empresas", "Dados cadastrais e registros em órgãos" e "Habilitar módulos por empresa" com "tasks 002 e 003"; na Fase 0, "Riverpod, go_router, tema e localização pt-BR" como feito (tasks 001, 002 e 003).
- `docs/decisoes.md`: nova entrada `D010 — Navegação com go_router 17` (StatefulShellRoute com 3 ramos; telas internas no navigator raiz; 18.x adiado pela migração para `material_ui`).

## Como verificar (definição de pronto)

```bash
flutter pub get
dart format .
flutter analyze
flutter test
grep -rnE "Color\(0x|Colors\.|AppColors\." lib/features lib/app/widgets lib/app/*.dart   # deve sair vazio
grep -rnE "fontSize|fontWeight:" lib/features                                            # deve sair vazio
grep -rn "AppDatabase\|features/companies/data/company_" lib/features/companies/presentation   # deve sair vazio
flutter run   # conferir no emulador: criar, editar, órgão com validade vencida, arquivar/desfazer
```

Todos os critérios de aceite do `README.md` marcados ou justificados no journal.

## Riscos e alternativas

- **Tamanho do PR.** São 12 componentes, navegação e 3 telas. Os commits por passo mantêm a revisão possível. Se o passo 4 crescer demais, ele pode virar um PR separado antes das telas (registre no journal).
- **Máscara com cursor no fim.** Editar no meio do CNPJ/telefone joga o cursor para o fim. Aceito no MVP; um formatter que preserve a posição pode vir depois.
- **Riverpod 3 refaz o provider com erro automaticamente** (retry). Se um stream do repositório falhar, a tela alterna entre erro e carregando. Aceitável; os testes usam o fake, que não falha.
- **Situação na lista e no detalhe** fica para a task de prazos (RF-PRZ-05), que vai preencher os `TODO(RF-PRZ-05)` desta task.
- *Descartado:* estado do formulário num `Notifier` do Riverpod. O estado só vive enquanto a tela está aberta, e os controllers de texto já são estado local.
- *Descartado:* filtrar a busca no widget sobre a lista completa. Duplicaria a regra de busca do repositório; a lista anterior é mantida na tela enquanto a nova carrega.
- *Descartado:* `go_router` 18 (ver Contexto) e `intl`/`DateFormat` só para `dd/MM/yyyy`.
- *Descartado:* pré-selecionar a UF (CE). Não há regra para isso.

# Plano técnico — 009

> **Plano autocontido.** Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Fluxo: `.claude/skills/task/SKILL.md`.

## Abordagem

O Painel (aba "Painel", rota `/painel`) passa a ser `DashboardScreen`, uma tela de leitura. Ela assiste `DeadlineRepository.watchUpcoming()` (já pronto e testado), conta por situação em Dart puro, mostra três `StatTile` na faixa de cabeçalho e uma lista de `DeadlineCard`. O filtro por situação é estado local da tela. Sem mudança de schema, sem repositório novo, sem pacote novo.

## Contexto do repositório (em 2026-11-16)

- Flutter com Riverpod, go_router e drift. Suíte: 286 testes verdes; `main` limpa (task 008 mergeada).
- `DeadlineRepository.watchUpcoming()`: em aberto, não excluídos, de empresas vivas e não arquivadas, com o módulo habilitado; ordem vencimento, título (sem acento/caixa), id. O `LocalDeadlineRepository` cumpre isso e tem teste. O **`FakeDeadlineRepository` (`test/helpers/`) não**: só filtra `isOpen`. O passo 1 corrige.
- `Deadline` (`lib/features/deadlines/domain/deadline.dart`): `companyId`, `module`, `title`, `dueDate`, `situationOn(DateTime today)` → `DeadlineSituation { current, dueSoon, overdue, renewed, completed, cancelled }`. Em aberto só produz `current`, `dueSoon`, `overdue`.
- `lib/features/deadlines/presentation/deadline_labels.dart`: `deadlineDisplay(d, today)` (tom, `lead`, `text` do card), `deadlineTone`, `situationLabel`, `deadlineSubtitle`. `ModuleScreen._card` mostra como montar o `DeadlineCard` (`showYear: d.dueDate.year != today.year`).
- `deadline_providers.dart`: providers `StreamProvider.autoDispose`. Faltam o de próximos vencimentos e o de nomes de empresa.
- `companiesProvider(CompanyFilter())` (`company_providers.dart`): empresas não arquivadas (`archived: false` é o padrão). `Company.displayName` = nome fantasia ou razão social.
- "Hoje": `ref.read(clockProvider)().toLocal()` (`lib/core/providers.dart`; o clock devolve UTC). Mesmo padrão do `ModuleScreen`. O Painel não vira o dia sozinho com o app aberto (pendência já existente nas outras telas).
- `lib/app/placeholder_screens.dart` tem `DashboardPlaceholderScreen` (a trocar) e `SettingsPlaceholderScreen` (fica).
- `lib/app/router.dart`: `AppRoutes.dashboard = '/painel'`; detalhe do prazo em `AppRoutes.deadline(companyId, module, id)`, no navigator raiz (cobre a barra inferior).
- `AppShell` mantém os três ramos montados: o estado local do Painel (filtro) sobrevive à troca de aba.
- Testes: `pumpApp(tester, repository:, deadlineRepository:, initialLocation:)` (`test/helpers/pump_app.dart`); "hoje" = `testNow` = 2026-09-29 (UTC 12h). `pumpComponent` monta um widget isolado com o tema. `test/widget_test.dart` hoje espera "Painel em construção" e o botão "Ver empresas" (placeholder): o passo 5 o atualiza.
- Armadilha: o drift reaproveita streams com o mesmo SQL (D008); não mexa em `watchUpcoming`, não é preciso.
- Design system: `StatTile` está em `docs/07-design-system.md` mas **não existe** em `lib/app/widgets/`; é criado no passo 2.

## Ordem de implementação

Branch `task/009-painel-vencimentos`, a partir da `main` atualizada (`git checkout main && git pull && git checkout -b task/009-painel-vencimentos`). Um commit por passo, `feat(prazos): <o quê> [task 009, RF-PRZ-05]`, terminando com `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. `flutter test` ao fim de cada passo. Journal atualizado a cada passo, com datas absolutas. Status → `em andamento` no primeiro passo.

1. **Fake fiel ao real.** `FakeDeadlineRepository.watchUpcoming` passa a seguir o contrato quando `companies != null`: só prazos de empresa viva, não arquivada e com `hasModule(d.module)`. A cobertura vem dos testes de tela (passo 5), que usam empresa arquivada e módulo desligado.
2. **`StatTile`** (`lib/app/widgets/stat_tile.dart`) + `test/app/widgets/stat_tile_test.dart` + linha do `docs/07-design-system.md` (já descrito; marcar ✅ e detalhar).
3. **Domínio e rótulos:** `deadline_summary.dart` (contagem e filtro) e `situationPluralLabel` em `deadline_labels.dart`, com testes.
4. **Providers:** `upcomingDeadlinesProvider` e `companyNamesProvider`.
5. **`DashboardScreen`**, rota, remoção do placeholder, ajuste de `test/widget_test.dart`, testes da tela. Ajuste do detalhe: ao excluir, voltar com `pop` quando houver para onde (ver Regras).
6. **Fechamento:** conferir no emulador, `dart format .`, `flutter analyze`, `flutter test`; critérios marcados; status `concluída` (README e `tasks/README.md`); `docs/05-roadmap.md` (marcar "Painel de próximos vencimentos (RF-PRZ-05)" com "— task 009"); `docs/07-design-system.md` (StatTile ✅, linha do Painel: só prazos, "Para lançar" na Fase 2); `docs/06` (C23); journal; `git push -u origin task/009-painel-vencimentos` e dar o link `https://github.com/Lazaro-Barros/NormaTrack/pull/new/task/009-painel-vencimentos` (sem `gh`; confira o remote com `git remote -v`).

## Setup

Nenhum pacote, nenhum codegen, nenhuma migração.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| domain | `lib/features/deadlines/domain/deadline_summary.dart` (novo) | `SituationCounts`, `filterBySituation` |
| presentation | `lib/features/deadlines/presentation/deadline_labels.dart` | + `situationPluralLabel` |
| presentation | `lib/features/deadlines/presentation/deadline_providers.dart` | + `upcomingDeadlinesProvider`, `companyNamesProvider` |
| presentation | `lib/features/deadlines/presentation/dashboard_screen.dart` (novo) | `DashboardScreen` |
| app | `lib/app/widgets/stat_tile.dart` (novo) | `StatTile` |
| app | `lib/app/placeholder_screens.dart` | remove `DashboardPlaceholderScreen` (e imports que sobrarem) |
| app | `lib/app/router.dart` | `/painel` → `DashboardScreen` |
| presentation | `lib/features/deadlines/presentation/deadline_detail_screen.dart` | excluir: `pop` se `context.canPop()`, senão `go` ao módulo |
| test | `test/helpers/fake_deadline_repository.dart` | `watchUpcoming` fiel |

## Domínio e contratos

`lib/features/deadlines/domain/deadline_summary.dart` (Dart puro, sem Flutter):

```dart
@immutable
class SituationCounts {
  const SituationCounts({this.overdue = 0, this.dueSoon = 0, this.current = 0});

  /// Conta só prazos em aberto; os demais (renovado, concluído, cancelado) são ignorados.
  factory SituationCounts.of(Iterable<Deadline> deadlines, DateTime today);

  final int overdue;
  final int dueSoon;
  final int current;

  int get total => overdue + dueSoon + current;

  int of(DeadlineSituation s); // overdue/dueSoon/current; 0 para as demais

  // ==, hashCode, toString
}

/// Mantém a ordem. [situation] `null` = todos.
List<Deadline> filterBySituation(
  List<Deadline> deadlines,
  DateTime today,
  DeadlineSituation? situation,
);
```

`deadline_labels.dart`:

```dart
/// Rótulo dos tiles: "Vencidos", "A vencer", "Vigentes". Só para as três situações em aberto.
String situationPluralLabel(DeadlineSituation s) => switch (s) {
  DeadlineSituation.overdue => 'Vencidos',
  DeadlineSituation.dueSoon => 'A vencer',
  DeadlineSituation.current => 'Vigentes',
  _ => situationLabel(s),
};
```

`deadline_providers.dart`:

```dart
/// Próximos vencimentos de todas as empresas (RF-PRZ-05).
final upcomingDeadlinesProvider = StreamProvider.autoDispose<List<Deadline>>(
  (ref) => ref.watch(deadlineRepositoryProvider).watchUpcoming(),
);

/// Nome de exibição por id, das empresas não arquivadas.
final companyNamesProvider = Provider.autoDispose<AsyncValue<Map<String, String>>>(
  (ref) => ref
      .watch(companiesProvider(const CompanyFilter()))
      .whenData((list) => {for (final c in list) c.id: c.displayName}),
);
```

(Importe `companiesProvider` de `company_providers.dart` e `CompanyFilter` de `company_repository.dart`.)

### `StatTile` (`lib/app/widgets/stat_tile.dart`)

```dart
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.tone,       // StatusTone: cor suave de fundo, forte no texto e ícone
    required this.count,
    required this.label,      // "Vencidos"
    this.selected = false,
    this.onTap,
  });

  /// Altura fixa, para uso em `AppBar.bottom`: 12 + 36 + 18 + 12.
  static const double height = 78;
}
```

- Fundo `StatusColors.of(context).resolve(tone).background`, cantos `AppRadius.lgAll` (o wireframe usa 14; vale o token do docs/07).
- Conteúdo: `Text('$count', style: AppTypography.number.copyWith(color: foreground))` (constante `TextStyle`: Manrope 800, 30/36, tabular); abaixo uma `Row` com o ícone de `StatusChip.iconFor(tone)` (tamanho 16) e o rótulo em `textTheme.labelMedium` (13/18, peso 600), cor forte. Padding `AppSpacing.md`.
- Anel quando `selected`: `Border.all(width: 2, color: foreground)` no mesmo `Container` (sem mudar o tamanho: `Container` com `foregroundDecoration` para a borda, para o conteúdo não saltar). Sem anel: sem borda.
- Toque: `Material(color: transparent)` + `InkWell(borderRadius: AppRadius.lgAll)`; mínimo 48 de altura é satisfeito pela altura 78.
- Semântica: `Semantics(button: true, selected: selected, label: '$count $label', excludeSemantics: true)`.
- Texto da cor forte sobre a cor suave tem contraste ≥ 4,5:1 (par já coberto por teste do tema). O ícone e o rótulo garantem "nunca só cor".

## Regras de implementação

- **Fonte dos dados.** A tela assiste `upcomingDeadlinesProvider` e `companyNamesProvider`. Os tiles contam a lista inteira (sem filtro); a lista mostra `filterBySituation(all, today, _filter)`.
- **Empresa no card.** `subtitle: names[d.companyId]`. O `watchUpcoming` só devolve prazos de empresas não arquivadas, que são as de `companyNamesProvider`; se um id faltar por corrida entre os dois streams, a linha de contexto fica vazia (`null`), sem erro. Esperar os dois providers carregarem antes de montar a lista evita piscar.
- **Filtro.** `DeadlineSituation? _filter` no `State`. Tocar no tile X: `_filter = _filter == X ? null : X`. Tile com contagem 0 continua tocável. Tile `selected: _filter == situation`.
- **Hoje.** `today = ref.read(clockProvider)().toLocal()`, lido a cada `build`.
- **Navegação.** `onTap` do card: `context.push(AppRoutes.deadline(d.companyId, d.module, d.id))`. `push` (não `go`) para que voltar retorne ao Painel com o filtro preservado. **[suposição]** (C23).
- **Excluir no detalhe** (`deadline_detail_screen.dart`, ~linha 340): trocar `router.go(AppRoutes.module(...))` por `router.canPop() ? router.pop() : router.go(AppRoutes.module(...))` para que, vindo do Painel, o usuário volte ao Painel. Vindo do módulo (`go`, pilha construída) o `pop` leva ao módulo, igual a hoje. Ver o teste existente de exclusão em `deadline_detail_screen_test.dart` e mantê-lo verde; se ele depender do `go`, ajustar a asserção para o resultado visível (tela do módulo). Renovar continua com `go` ao novo ciclo (leva ao Empresas > detalhe; **[suposição]**, aceito e registrado em C23).
- **Estados.** Carregando (um dos dois providers sem valor e sem erro): `Center(CircularProgressIndicator)`. Erro em qualquer um: `EmptyState(error_outline, 'Não foi possível carregar os prazos', 'Tente abrir a tela de novo.')`. Os tiles na faixa mostram 0 enquanto carrega.
- **Rodapé da lista.** `padding bottom: AppSpacing.xl` (sem FAB). Sem `FilledButton` na tela (o Painel não tem ação primária; a ação do vazio é tonal, dentro do `EmptyState`).
- Marque com `// TODO(RF-PRZ-05):` a linha de contexto (empresa) e o `push`, apontando C23.

## Interface

`DashboardScreen` (`ConsumerStatefulWidget`) — `Scaffold`:

- `appBar: AppBar(title: BandTitle(title: 'Painel', large: true), bottom: PreferredSize(preferredSize: Size.fromHeight(StatTile.height + AppSpacing.lg), child: Padding(EdgeInsets.fromLTRB(lg, 0, lg, lg), child: Row(3 × Expanded(StatTile), separados por SizedBox(width: AppSpacing.sm)))))`.
- Ordem e dados dos tiles: Vencidos (`StatusTone.overdue`, `counts.overdue`), A vencer (`dueSoon`), Vigentes (`ok`, `counts.current`). Rótulo via `situationPluralLabel`.
- `body`, quando há dados: `ListView(padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xl))` com o título de seção `Text('Próximos vencimentos', style: textTheme.titleMedium)` (padding horizontal `AppSpacing.xs`, como no `ModuleScreen`) e os cards com `SizedBox(height: AppSpacing.sm)` entre eles. O card é montado como `ModuleScreen._card`: `deadlineDisplay`, `showYear: d.dueDate.year != today.year`.
- Vazios (substituem a lista, mantendo os tiles):
  - Sem nenhum prazo em aberto: `EmptyState(icon: Icons.space_dashboard_outlined, title: 'Nenhum prazo em aberto', message: 'Cadastre prazos no módulo de uma empresa para acompanhar os vencimentos aqui.', actionLabel: 'Ver empresas', onAction: () => context.go(AppRoutes.companies))`.
  - Filtro sem resultado: `EmptyState` sem ação, ícone do tom (`StatusChip.iconFor(tone)`), título `'Nenhum prazo vencido'` / `'Nenhum prazo a vencer'` / `'Nenhum prazo vigente'`, mensagem `'Toque de novo no filtro para ver todos os prazos.'`.
- Wireframe `Main.dc.html` já ajustado (2026-11-16): sem sino, sem data, sem "Ver todos", sem "Para lançar".

## Testes

Datas conferidas com "hoje" = 2026-09-29 (`testNow`). Empresas: **Indústria Alfa Ltda** (sem nome fantasia) e **Beta Alimentos** (`tradeName` "Beta Alimentos", razão social qualquer), ambas com `ModuleType.environmental` habilitado. Prazos (módulo ambiental, lembretes padrão: licença 150, laudo e manutenção 30):

| Título | Empresa | Categoria | Vencimento | Dias | Situação | Card |
|---|---|---|---|---|---|---|
| Licença de Operação | Alfa | licença | 2026-09-26 | −3 | vencido | "Venceu" / "há 3 dias" |
| Laudo da ETE | Alfa | laudo | 2026-10-11 | 12 | a vencer | "Vence" / "em 12 dias" |
| Licença de Instalação | Beta | licença | 2026-11-13 | 45 | a vencer (45 ≤ 150) | "Vence" / "em 45 dias" |
| Bomba dosadora | Beta | manutenção | 2027-03-15 | 167 | vigente (167 > 30) | "Em 167 dias" |

Ordem esperada na lista: Licença de Operação, Laudo da ETE, Licença de Instalação, Bomba dosadora. Contagens: vencidos 1, a vencer 2, vigentes 1.

| Arquivo | Cobre |
|---|---|
| `test/features/deadlines/domain/deadline_summary_test.dart` (novo) | `SituationCounts.of` com os 4 prazos acima → (1, 2, 1, total 4); ignora renovado/concluído/cancelado (construir `Deadline` com `status`); lista vazia → zeros; `of(situation)` devolve cada contagem e 0 para `renewed`; `filterBySituation` mantém a ordem, `null` devolve tudo, filtro sem resultado devolve `[]`; no dia do vencimento (2026-09-29) conta a vencer, e no dia seguinte, vencido |
| `test/features/deadlines/presentation/deadline_labels_test.dart` | acrescentar `situationPluralLabel`: Vencidos, A vencer, Vigentes |
| `test/app/widgets/stat_tile_test.dart` (novo) | mostra número e rótulo; `onTap` dispara; `selected` muda a decoração (anel presente só selecionado: achar o `Container` com `foregroundDecoration` com borda); semântica `label: '3 Vencidos'`, `isSelected`, `isButton`; altura = `StatTile.height`; cor de fundo = `StatusColors.light.overdue.background` e de texto = `foreground`; com `count: 0` continua tocável |
| `test/features/deadlines/presentation/dashboard_screen_test.dart` (novo) | com os 4 prazos: tiles "1 Vencidos", "2 A vencer", "1 Vigentes"; cards na ordem esperada com "Alfa"/"Beta Alimentos" e os textos relativos da tabela; tocar "A vencer" deixa só os 2 prazos a vencer e marca o tile; tocar de novo mostra os 4; trocar para "Vencidos" e depois "Vigentes" troca o filtro; tocar no card abre o detalhe (título do prazo na tela) e voltar (`tester.pageBack()` ou botão de voltar) retorna ao Painel com o filtro mantido; sem prazos: "Nenhum prazo em aberto" e "Ver empresas" leva a Empresas; filtro sem resultado (só vigentes e toca em Vencidos): "Nenhum prazo vencido" sem botão; empresa arquivada, empresa com módulo desligado e prazo concluído/cancelado não aparecem nem contam (exercita o passo 1); criar um prazo pelo repositório com a tela aberta atualiza tiles e lista; excluir no detalhe aberto a partir do Painel volta ao Painel |
| `test/widget_test.dart` | onde espera "Painel em construção", esperar "Nenhum prazo em aberto" (banco vazio); o teste "ação do Painel abre Empresas" continua válido (botão "Ver empresas") |
| `test/features/deadlines/presentation/deadline_detail_screen_test.dart` | o teste de exclusão existente continua verde |

O `FakeDeadlineRepository` não tem teste próprio: a fidelidade dele é exercitada pelos testes de tela acima (empresa arquivada, módulo desligado).

Meta: 286 testes atuais verdes + os novos (≈ 20).

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` sem avisos, `flutter test` verde.
- No emulador (`Medium_Phone_API_37.0`; `flutter run` e conferir por `adb`/captura): cadastrar duas empresas com prazos vencido, a vencer e vigente; Painel mostra contagens e lista na ordem; tocar em cada tile filtra e destaca; tocar de novo limpa; tocar num card abre o detalhe e voltar retorna ao Painel com o filtro mantido; renovar/concluir muda as contagens ao voltar; arquivar uma empresa tira os prazos dela do Painel; sem prazos aparece o vazio com "Ver empresas".
- Conferir com fonte do sistema grande que os tiles não estouram (altura fixa 78; registrar no journal se estourar).

## Riscos e alternativas

- **[suposição]** Linha de contexto do card = empresa, sem categoria/órgão (como o wireframe). Em C23.
- **[suposição]** Voltar do detalhe leva ao Painel (`push`); excluir volta ao Painel; renovar a partir do Painel deixa o usuário no detalhe do novo ciclo dentro da aba Empresas. Em C23.
- **[suposição]** Sem limite na lista (resposta da usuária); com centenas de prazos, a `ListView` já é preguiçosa. Reavaliar paginação/"Ver todos" se a cliente reclamar.
- Tile de altura fixa: fonte grande pode cortar. Mesmo risco dos banners da 008.
- *Descartado:* filtro persistente entre sessões; limite de 10 itens com "Ver todos"; esconder "Vigentes" da lista; tiles apenas informativos (contradiz docs/07 "tocar filtra").

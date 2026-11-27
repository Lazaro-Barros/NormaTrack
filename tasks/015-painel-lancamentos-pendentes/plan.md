# Plano técnico — 015

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

As pendências já são calculadas pelo domínio (`pendingLaunches`, task 013) e expostas por `MeasurementRepository.watchPendingLaunches(today:)` sem `companyId` (todas as empresas vivas, não arquivadas, com o módulo do contexto habilitado). Esta task:

1. agrupa as pendências por empresa + contexto + frequência no domínio (`PendingGroup`), uma linha por grupo;
2. cria o widget genérico `PendingRow`;
3. põe a seção "Lançamentos pendentes" no Painel, acima de "Próximos vencimentos";
4. cria `todayProvider` (data local sem hora que vira à meia-noite e ao voltar o app para a frente) e troca a leitura avulsa do relógio por ele nas telas que mostram situação relativa a hoje.

## Contexto do repositório (em 2026-11-27)

- Flutter 3.47.9, Dart `^3.13.4`, `flutter_riverpod ^3.4.3` (providers manuais, sem codegen), `go_router`.
- `lib/features/measurements/domain/pending_launch.dart`: `PendingKind { toLaunch, overdue }`, `PendingLaunch(companyId, context, period, kind, expected, filled)`, `pendingLaunches(...)` ordenada por início do período, contexto, empresa, frequência.
- `lib/features/measurements/presentation/measurement_labels.dart`: `periodTitle` ("Semana 48"), `periodRange` ("23 a 29/11/2026"; vazio na diária), `monitoringStatus` (linha do módulo: "1 semana atrasada", "n semanas atrasadas", "A lançar", "Em dia").
- `measurement_providers.dart`: `companyPendingLaunchesProvider` (family por `companyId` + `today`). Não há provider das pendências de todas as empresas.
- `MeasurementContext` (`noise` "Ruídos", `effluent` "Controle da ETE", `water` "Controle da ETA"); só `noise` tem tela (`AppRoutes.noise(companyId, {DateTime? week})` → `/empresas/:id/modulos/ambiental/ruidos?semana=AAAA-MM-DD`). Ícone de Ruídos no módulo: `Icons.graphic_eq`.
- Painel: `lib/features/deadlines/presentation/dashboard_screen.dart` (`StatTile`s na faixa que filtram, lista de `DeadlineCard`, `EmptyState` sem prazos e no filtro vazio, erro "Não foi possível carregar os prazos"). `companyNamesProvider` dá o nome de exibição das empresas não arquivadas.
- "Hoje" hoje: cada tela faz `ref.read(clockProvider)().toLocal()` no `build` (Painel, `module_screen.dart` `_DeadlinesState`, `company_detail_screen.dart` `_Detail`, `deadline_detail_screen.dart`) ou no `initState` (`noise_launch_screen.dart`: `_today` e `_current` são `late final`). Nada reconstrói a tela quando o dia vira (observado na 013). `clockProvider` (`lib/core/providers.dart`) devolve UTC. O domínio de prazos ignora a hora de `today` (`Deadline.daysUntilDue`).
- `NormaTrackApp` (`lib/main.dart`) é `ConsumerStatefulWidget`; `AppLifecycleListener` já é usado em `settings_screen.dart`.
- Testes: `pumpApp` (`test/helpers/pump_app.dart`) monta o app com `clockProvider` fixo em `testNow` = 29/09/2026 12:00 UTC (semana 40, 28/09 a 04/10/2026) e `FakeMeasurementRepository` (pendências pelo mesmo `pendingLaunches`; `seedPoint`, `seedMeasurement`). `text_scalers.dart` tem `NonLinearScaler` e `withTextScaler`; `pump_widget.dart` monta um widget solto com o tema.
- Armadilhas: a fonte Ahem dos testes é larga (texto à direita precisa poder quebrar); dois `pumpApp` no mesmo teste não trocam a rota; voltar nos testes é `tester.tap(find.byTooltip('Voltar'))`; `git checkout` de arquivo desfaz edições não commitadas.

## Ordem de implementação

Um commit por passo, direto na `main`, com `dart format .`, `flutter analyze` e `flutter test` verdes, seguido de `git push origin main`. Mensagem: `tipo(escopo): descrição [task 015, RF-…]` + linha `Co-Authored-By` da sessão.

1. **`todayProvider`** (`feat(core): data de hoje que vira o dia sozinha [task 015, RF-PRZ-05]`): provider, listener no `NormaTrackApp`, troca nas cinco telas, testes.
2. **Domínio e `PendingRow`** (`feat(medicoes): agrupar pendências e PendingRow [task 015, RF-AMB-02]`): `PendingGroup`/`groupPendingLaunches`, rótulos, widget, testes, `docs/07-design-system.md` (componente).
3. **Painel** (`feat(painel): lançamentos pendentes no Painel [task 015, RF-AMB-02, RF-PRZ-05]`): provider, seção, testes; wireframe `Main` com o protótipo; `docs/07-design-system.md` (tela Painel).
4. **Emulador** (correções, se houver, num commit `fix(painel): …`).
5. **Fechamento** (`docs(painel): fechamento da task 015 [task 015, …]`): critérios, journal, status aqui e no índice, `docs/05-roadmap.md`, `docs/06-perguntas-em-aberto.md` (C28).

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| core | `lib/core/today.dart` (novo) | `TodayNotifier` e `todayProvider` |
| app | `lib/main.dart` | `AppLifecycleListener(onResume:)` chama `todayProvider.notifier.refresh()` |
| domain | `lib/features/measurements/domain/pending_launch.dart` | `PendingGroup`, `groupPendingLaunches` |
| presentation | `lib/features/measurements/presentation/measurement_labels.dart` | `overdueLabel`, `pendingGroupStatus`; `monitoringStatus` passa a usar `overdueLabel` |
| presentation | `lib/features/measurements/presentation/measurement_providers.dart` | `pendingLaunchesProvider` (todas as empresas) |
| presentation | `lib/features/measurements/presentation/pending_section.dart` (novo) | `launchRouteFor`, `PendingSection` (título + linhas) |
| widget | `lib/app/widgets/pending_row.dart` (novo) | `PendingRow` |
| presentation | `dashboard_screen.dart`, `module_screen.dart`, `company_detail_screen.dart`, `deadline_detail_screen.dart`, `noise_launch_screen.dart` | `ref.watch(todayProvider)` |

## Domínio e contratos

### `todayProvider` (`lib/core/today.dart`)

```dart
/// Data local de hoje, sem hora. Vira sozinha à meia-noite (timer) e quando o
/// app volta para a frente (`refresh`, chamado pelo NormaTrackApp).
final todayProvider = NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);

class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final clock = ref.watch(clockProvider);
    _schedule(clock);
    return _dateOf(clock());
  }

  /// Relê o relógio; só notifica se a data mudou. Reagenda o timer.
  void refresh() { ... }
}
```

- `_dateOf(now)`: `final l = now.toLocal(); DateTime(l.year, l.month, l.day)`.
- `_schedule`: cancela o timer anterior e agenda para `DateTime(l.year, l.month, l.day + 1).difference(l) + 1 s` (`l` = agora local). Ao disparar, chama `refresh()`, que recalcula a data e reagenda (se disparou cedo, continua no mesmo dia e só reagenda).
- `refresh()` compara com `state` e só atribui se diferente (evita reconstruir à toa ao voltar o app).
- `NormaTrackApp`: `late final AppLifecycleListener _lifecycle = AppLifecycleListener(onResume: () => ref.read(todayProvider.notifier).refresh())` criado no `initState`, `dispose` no `dispose`.
- Telas: trocar `ref.read(clockProvider)().toLocal()` por `ref.watch(todayProvider)` no `build` do Painel, `_DeadlinesState` (o `MonitoringSection` recebe direto, sem o `DateTime(...)`), `_Detail` da empresa e detalhe do prazo. Em `noise_launch_screen.dart`: remover `_today`/`_current` `late final`; `_current` vira getter `MeasurementPeriod.containing(_weekly, ref.watch/read(todayProvider))` (watch no `build`, read em handlers) e o `savePeriod` usa `ref.read(todayProvider)`. `_period` continua como está (a semana escolhida não muda sozinha; na virada para uma semana nova a seta "próxima" passa a habilitar).
- Formulários e `notification_sync.dart` continuam com `clockProvider` (leem na hora de salvar/planejar).

### Agrupamento (`pending_launch.dart`, Dart puro)

```dart
/// Pendências de um contexto de uma empresa numa frequência: o que uma linha
/// do Painel mostra e o que "Lançar" abre.
@immutable
class PendingGroup {
  const PendingGroup({required this.oldest, required this.overdue, required this.total});
  final PendingLaunch oldest;   // período pendente mais antigo
  final int overdue;            // períodos atrasados
  final int total;              // atrasados + o corrente, se pendente
  String get companyId => oldest.companyId;
  MeasurementContext get context => oldest.context;
  MeasurementFrequency get frequency => oldest.period.frequency;
  PendingKind get kind => overdue > 0 ? PendingKind.overdue : PendingKind.toLaunch;
  // == e hashCode por oldest, overdue, total
}

/// Agrupa por (empresa, contexto, frequência). Ordem: início do período mais
/// antigo, contexto, empresa, frequência (a mesma de `pendingLaunches`).
List<PendingGroup> groupPendingLaunches(Iterable<PendingLaunch> pending);
```

- Lista vazia → lista vazia. A ordem final na tela desempata pelo nome da empresa (ver Interface).
- `PendingKind` do grupo: atrasado se houver qualquer período atrasado.

### Rótulos (`measurement_labels.dart`)

- `String overdueLabel(MeasurementFrequency f, int n)`: semanal "1 semana atrasada" / "n semanas atrasadas"; quinzenal "1 quinzena atrasada" / "n quinzenas atrasadas"; mensal "1 mês atrasado" / "n meses atrasados"; diária "1 dia atrasado" / "n dias atrasados". `monitoringStatus` passa a usar `overdueLabel(MeasurementFrequency.weekly, n)` (mesmos textos de hoje).
- `({String label, StatusTone tone}) pendingGroupStatus(PendingGroup g)`: `overdue > 0` → `(overdueLabel(g.frequency, g.overdue), StatusTone.overdue)`; senão `('A lançar', StatusTone.dueSoon)`.
- Linha do Painel: título `'${g.context.label} · $companyName'`; subtítulo `periodTitle(p)` + (`' · ${periodRange(p)}'` se o intervalo não for vazio), com `p = g.oldest.period`. Ex.: "Ruídos · Indústria Alfa Ltda", "Semana 46 · 09 a 15/11/2026", "2 semanas atrasadas".

**[suposição]** (C28) Uma linha por empresa e contexto com a contagem de atrasadas, em vez de "A lançar"/"Atrasado" por período (decidido pelo usuário em 2026-11-27); a linha aponta para o período mais antigo.

### Provider e rota

```dart
/// Pendências de todas as empresas em [today] (data local, sem hora).
final pendingLaunchesProvider = StreamProvider.autoDispose
    .family<List<PendingLaunch>, DateTime>((ref, today) =>
        ref.watch(measurementRepositoryProvider).watchPendingLaunches(today: today));
```

`String launchRouteFor(PendingGroup g)`: `noise` → `AppRoutes.noise(g.companyId, week: g.oldest.period.start)`; `effluent`/`water` → `AppRoutes.module(g.companyId, g.context.module)` com `// TODO(RF-AMB-07): tela de lançamento da ETE/ETA na task 017.` A navegação é `context.push` (voltar retorna ao Painel com o filtro, como os cards de prazo, C23).

## Interface

### `PendingRow` (`lib/app/widgets/pending_row.dart`)

```dart
class PendingRow extends StatelessWidget {
  const PendingRow({super.key, required this.icon, required this.title,
    this.subtitle, required this.statusLabel, required this.tone,
    required this.onLaunch, this.actionLabel = 'Lançar'});
  final IconData icon; final String title; final String? subtitle;
  final String statusLabel; final StatusTone tone;
  final VoidCallback onLaunch; final String actionLabel;
}
```

- `Card` do tema (branco, sem borda, raio do tema), padding `EdgeInsets.all(AppSpacing.md)`. O card não é tocável: a ação é só o botão.
- Linha: quadrado 40 × 40, raio `AppRadius.md`, fundo `StatusColors.of(context).resolve(tone).background`, ícone 20 na cor `foreground`; `AppSpacing.md`; coluna `Expanded` com título (`titleSmall`, quebra livre), subtítulo (`bodySmall`, `onSurfaceVariant`, `AppTypography.tabular`) e `StatusText(label: statusLabel, tone: tone)`; `AppSpacing.sm`; `FilledButton.tonal(onPressed: onLaunch, child: Text(actionLabel))`.
- Situação nunca só por cor: o `StatusText` tem ícone + texto.
- Fonte grande: com `MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3`, o botão desce para baixo dos textos, alinhado à direita (mesmo corte da `MeasurementInputRow`).
- Semântica: o botão fica com o rótulo visível ("Lançar"); título, subtítulo e situação são lidos antes dele (o `StatusText` já diz "Situação: …"). Teste confere `find.widgetWithText(FilledButton, 'Lançar')`.
- Teste `test/app/widgets/pending_row_test.dart`: textos e ícone do tom; toque em "Lançar" chama `onLaunch`; sem subtítulo; fonte 1,3×, 2× e `NonLinearScaler` sem exceção de overflow (`tester.takeException()` nulo) e, em 2×, botão abaixo do título (`getTopLeft` do botão > `getBottomLeft` do título).

### Painel

- Dados: `today = ref.watch(todayProvider)`; `pendingLaunchesProvider(today)`; grupos = `groupPendingLaunches(list)` filtrados para empresas presentes em `names` (por segurança), ordenados de forma estável por (início do mais antigo, nome da empresa com `searchText`/comparação simples, contexto).
- Estados: erro em prazos, nomes **ou** pendências → `EmptyState` "Não foi possível carregar o Painel" / "Tente abrir a tela de novo." (o título atual muda; ajustar o teste se existir). Carregando qualquer um → indicador.
- Corpo:
  - Filtro ativo: como hoje (só prazos filtrados ou o vazio do filtro); a seção de pendências não aparece.
  - Sem filtro, sem prazos e sem pendências: o `EmptyState` atual ("Nenhum prazo em aberto", "Ver empresas").
  - Sem filtro: `ListView` com, se houver grupos, o cabeçalho "Lançamentos pendentes" (`titleMedium`) com a contagem de grupos à direita (`bodyMedium`, `onSurfaceVariant`, tabular) e um `PendingRow` por grupo (`AppSpacing.sm` entre eles); depois `AppSpacing.lg` e "Próximos vencimentos" com os cards; sem prazos, abaixo do cabeçalho de vencimentos vai `EmptyState(inline: true)` com o mesmo texto e ação do vazio atual.
- `PendingRow`: ícone por contexto (`noise` → `Icons.graphic_eq`; `effluent`/`water` → `Icons.water_drop_outlined`), título, subtítulo e situação como em "Rótulos"; `onLaunch: () => context.push(launchRouteFor(g))`.
- Wireframe: `prototypes/Main.dc.html` (aprovado) substitui `docs/design/wireframes/Main.dc.html`.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/core/today_test.dart` (novo) | Em `testWidgets` (fake async): com relógio mutável em 29/09/2026 23:59:30 local, estado 29/09; avança o relógio para 30/09 00:00:05 e `tester.pump(Duration(seconds: 40))` → 30/09. `refresh()` sem mudança de dia não notifica (listener com contador). `refresh()` depois de mudar o relógio para 02/10 → 02/10. Container descartado cancela o timer (sem "Timer still pending") |
| `test/main_lifecycle_test.dart` ou dentro do teste do Painel | `pumpApp` com relógio mutável (novo parâmetro `clock` no `pumpApp`): prazo vencido em 26/09 mostra "há 3 dias"; muda o relógio para 30/09 e simula `inactive` → `resumed` (`tester.binding.handleAppLifecycleStateChanged`) → "há 4 dias" |
| `test/features/measurements/domain/pending_launch_test.dart` | `groupPendingLaunches`: vazio; duas empresas e semanas 38–40 (hoje 29/09/2026: semana 40 corrente) → um grupo por empresa com `oldest` = semana 38, `overdue` 2, `total` 3; só o corrente → `toLaunch`, overdue 0; frequências diferentes no mesmo contexto viram grupos separados; ordem pela mais antiga |
| `test/features/measurements/presentation/measurement_labels_test.dart` | `overdueLabel` nas quatro frequências, singular e plural; `pendingGroupStatus`; `monitoringStatus` sem mudança |
| `test/app/widgets/pending_row_test.dart` | ver `PendingRow` |
| `test/features/deadlines/presentation/dashboard_screen_test.dart` | seção com dois grupos (Alfa com pontos desde 14/09/2026 → semanas 38 e 39 atrasadas + 40; Beta com ponto desde 28/09 → "A lançar"), textos "Ruídos · Indústria Alfa Ltda", "Semana 38 · 14 a 20/09/2026", "2 semanas atrasadas", contagem "2", ordem; "Lançar" abre `Semana 38` na tela de ruídos e voltar mostra o Painel; tile selecionado esconde a seção; sem prazos com pendências → seção + vazio inline; lançar a semana mais antiga (`seedMeasurement`) faz a linha passar para a semana 39; empresa arquivada e Ambiental desligado somem; erro de carregamento (se o teste existente cobre, ajustar o título) |
| `module_screen_test`, `company_detail_screen_test`, `deadline_detail_screen_test`, `noise_launch_screen_test` | seguem verdes sem mudança (o relógio fixo do `pumpApp` alimenta o `todayProvider`) |

Datas conferidas: 29/09/2026 é terça; semana ISO 40 = 28/09 a 04/10; 39 = 21 a 27/09; 38 = 14 a 20/09/2026.

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` e `flutter test` sem erros.
- Emulador `Medium_Phone_API_37.0`: copiar o banco antes (`adb exec-out run-as br.com.normatrack.app cat app_flutter/normatrack.sqlite > <scratchpad>/antes.sqlite`), `flutter build apk --debug`, `adb install -r build/app/outputs/flutter-apk/app-debug.apk` (sem `pm clear`, sem desinstalar). Painel mostra as pendências da Indústria Alfa (pontos com medições na semana 48 de 2026; o que faltar aparece), "Lançar" abre a semana certa, filtro esconde a seção, fonte 2,0 sem corte. Depois, tabelas antigas iguais à cópia (os lançamentos feitos no teste ficam como dados de teste).

## Riscos e alternativas

- **[suposição]** C28: uma linha por empresa e contexto (com a contagem) em vez de uma por período; seção acima dos vencimentos e escondida no filtro; tiles só de prazos; sem limite. Escolhas do usuário em 2026-11-27, falta confirmar com a cliente.
- Timer do Android pode atrasar com o app em segundo plano; o `onResume` cobre esse caso.
- *Descartado:* uma linha por semana com "Ver todas" (cresce com o atraso); somar pendências nos tiles (mistura prazo e lançamento); `Stream.periodic` a cada minuto (acorda à toa).

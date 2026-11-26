# Plano técnico — 010

> **Plano autocontido.** Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-PRZ-03):` no código. Fluxo: `.claude/skills/task/SKILL.md`. Decisões do usuário: fim do `journal.md` (2026-11-26) e C4 em `docs/06-perguntas-em-aberto.md`.

## Abordagem

Um **planejador em Dart puro** transforma a lista de prazos em aberto (a mesma de `DeadlineRepository.watchUpcoming`, que já exclui empresa arquivada e módulo desligado) numa lista de notificações: uma por dia de lembrete futuro, às 8h, e uma **semanal repetitiva** a partir de 7 dias depois do vencimento. Um **sincronizador** (provider Riverpod) escuta os prazos, os nomes das empresas e o ajuste "ligado/desligado" e, a cada mudança, **substitui** todos os agendamentos pendentes pelo plano novo. O agendamento fica atrás da interface `NotificationScheduler`; a implementação real usa `flutter_local_notifications` com modo **inexato**. Tocar na notificação abre o detalhe do prazo. Ajustes ganha a seção Alertas (interruptor e aviso de permissão bloqueada). Sem tabela nova: o ajuste fica em `shared_preferences`.

## Contexto do repositório (em 2026-11-26)

- Flutter 3.47.9, Dart ^3.13.4, Riverpod 3, go_router 17, drift. Suíte: 324 testes verdes na `main` (tasks 009 e 011 concluídas).
- `Deadline` (`lib/features/deadlines/domain/deadline.dart`): `id`, `companyId`, `module`, `title`, `dueDate` (só data, local), `reminderDays` (decrescente, ex.: `[150, 30, 10, 3, 0]`), `reminderDates`, `isOpen`, `daysUntilDue(today)`. Função livre `reminderDate(dueDate, daysBefore)`.
- `upcomingDeadlinesProvider` e `companyNamesProvider` em `lib/features/deadlines/presentation/deadline_providers.dart` (task 009). `deadlineRepositoryProvider` tem `findById(id)`.
- `clockProvider` (`lib/core/providers.dart`) devolve **UTC**; use `.toLocal()`.
- `formatDate(DateTime)` → `dd/MM/yyyy` em `lib/core/utils/date_format.dart` (Dart puro).
- Rotas: `AppRoutes.dashboard` (`/painel`), `AppRoutes.settings` (`/ajustes`), `AppRoutes.deadline(companyId, module, id)` no navigator raiz. `routerProvider` dá o `GoRouter`.
- `lib/app/placeholder_screens.dart` só tem `SettingsPlaceholderScreen` (a remover; o arquivo some).
- `main.dart`: `runApp(ProviderScope(child: NormaTrackApp()))`. `NormaTrackApp` é `ConsumerWidget`.
- Widgets: `SectionCard` (título, `caption`, `description`, `children`), `SwitchRow` (`leadingIcon`, `title`, `subtitle`, `value`, `onChanged`), `NavRow` (`leadingIcon`, `title`, `subtitle`, `trailing`, `onTap`), `EmptyState`.
- Testes de app: `pumpApp` (`test/helpers/pump_app.dart`) com repositórios falsos e `testNow` = 2026-09-29 12:00 UTC (09:00 em Fortaleza, UTC−3). `test/widget_test.dart` espera "Ajustes em construção" (passo 6 ajusta).
- Android: AGP `9.1.0` (`android/settings.gradle.kts`), `compileSdk = flutter.compileSdkVersion` (= 36), sem desugaring, manifest sem receivers. SDK local tem `android-37.0`.
- `docs/04-arquitetura.md` já prevê `lib/core/notifications/` e agendamento inexato.

### Spike (2026-11-26, `prototypes/spike/`)

Numa cópia do projeto: `flutter_local_notifications 23.0.4`, `timezone 0.11.2`, `flutter_timezone 5.1.1`, `shared_preferences 2.5.6`, com as mudanças de `prototypes/spike/android.diff`. Resultado no emulador `Medium_Phone_API_37.0`: compila e roda; `FlutterTimezone.getLocalTimezone()` → `America/Fortaleza`; `requestNotificationsPermission()` mostra o diálogo e devolve `true`; notificação `zonedSchedule` inexata chegou com o app em segundo plano; a semanal (`DateTimeComponents.dayOfWeekAndTime`) ficou em `pendingNotificationRequests()`. **O spike instala por cima do app no emulador (mesmo `applicationId`); os dados do banco ficam.**

## Ordem de implementação

Commits direto na `main` (D012), um por passo, com `dart format .`, `flutter analyze` e `flutter test` verdes, seguido de `git push origin main`. Mensagem: `feat(notificacoes): <o quê> [task 010, RF-PRZ-03]` (ou `fix`/`test`/`docs`/`build`), terminando com a linha de coautoria do agente. Journal a cada passo. Status → `em andamento` no passo 1.

1. **Setup Android e pacotes** (`build`): ver Setup. Conferir `flutter build apk --debug`.
2. **Planejador** (`lib/core/notifications/deadline_notification_planner.dart`) + testes.
3. **Ajuste e agendador**: `NotificationSettings` (interface + `SharedPrefsNotificationSettings`), `NotificationScheduler` (interface + `LocalNotificationScheduler`), providers, fakes de teste em `test/helpers/`, override no `pumpApp`.
4. **Sincronizador** (`notification_sync.dart`) ligado no `NormaTrackApp` + testes.
5. **Toque na notificação** (`lib/app/notification_navigation.dart`) + pedido de permissão na primeira abertura + testes.
6. **Tela de Ajustes** (`lib/features/settings/presentation/settings_screen.dart`), rota, remoção do placeholder, `test/widget_test.dart`, testes da tela.
7. **Fechamento**: emulador (ver "Como verificar"), docs (`docs/04` seção Alertas, `docs/07` linha de Ajustes, `docs/decisoes.md` D013, `docs/05` item marcado, wireframe `Ajustes.dc.html` com o texto novo da linha), critérios, status `concluída`, journal, push.

## Setup

```bash
flutter pub add flutter_local_notifications:^23.0.4 timezone:^0.11.2 flutter_timezone:^5.1.1 shared_preferences:^2.5.6
```

Android (exatamente o `prototypes/spike/android.diff`):

- `android/settings.gradle.kts`: `id("com.android.application") version "9.1.1" apply false` (o plugin exige AGP ≥ 9.1.1).
- `android/app/build.gradle.kts`: `compileSdk = 37` (o plugin exige 37; o padrão do Flutter é 36); em `compileOptions`, `isCoreLibraryDesugaringEnabled = true`; bloco no fim:
  ```kotlin
  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  }
  ```
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` dentro de `<manifest>`; dentro de `<application>`, os dois receivers do README do plugin (`ScheduledNotificationReceiver` e `ScheduledNotificationBootReceiver` com `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON` e `com.htc.intent.action.QUICKBOOT_POWERON`), `exported="false"`. **Sem** `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` (agendamento inexato). `POST_NOTIFICATIONS` já vem do manifest do plugin.

Sem codegen, sem migração.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| core (Dart puro) | `lib/core/notifications/deadline_notification_planner.dart` (novo) | `PlannedNotification`, `planDeadlineNotifications`, `notificationIdFor` |
| core | `lib/core/notifications/notification_scheduler.dart` (novo) | interface `NotificationScheduler` |
| core | `lib/core/notifications/local_notification_scheduler.dart` (novo) | implementação com o plugin |
| core | `lib/core/notifications/notification_settings.dart` (novo) | interface `NotificationSettings` + `SharedPrefsNotificationSettings` |
| core | `lib/core/notifications/notification_providers.dart` (novo) | providers (ver Contratos) |
| core | `lib/core/notifications/notification_sync.dart` (novo) | `notificationSyncProvider` |
| app | `lib/app/notification_navigation.dart` (novo) | `openDeadlineFromNotification` |
| app | `lib/main.dart` | inicializa o agendador antes do `runApp`; `NormaTrackApp` ativa sync e toque |
| app | `lib/app/router.dart` | `/ajustes` → `SettingsScreen` |
| app | `lib/app/placeholder_screens.dart` | **removido** |
| presentation | `lib/features/settings/presentation/settings_screen.dart` (novo) | tela Ajustes (seção Alertas) |
| test | `test/helpers/fake_notification_scheduler.dart`, `test/helpers/fake_notification_settings.dart` (novos) | fakes |
| test | `test/helpers/pump_app.dart` | overrides dos fakes; devolve-os para os testes (ver Testes) |

## Domínio e contratos

`deadline_notification_planner.dart` (sem import de Flutter; importa `Deadline`, `formatDate`):

```dart
/// Hora fixa das notificações (resposta do usuário, C4).
const notificationHour = 8;

/// Teto de agendamentos: alguns Android (Samsung) limitam a 500 alarmes por app.
const maxScheduledNotifications = 400;

@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.deadlineId,
    required this.fireAt,   // local, sem fuso: DateTime(y, m, d, 8)
    required this.weekly,   // true = repete toda semana no mesmo dia e hora
    required this.title,
    required this.body,
  });
  final int id;
  final String deadlineId; // também é o payload
  final DateTime fireAt;
  final bool weekly;
  final String title;
  final String body;
  // ==, hashCode, toString
}

/// Plano completo para os prazos em aberto, ordenado por [fireAt] (desempate:
/// título sem acento/caixa, depois id), cortado em [max].
List<PlannedNotification> planDeadlineNotifications(
  List<Deadline> deadlines,
  Map<String, String> companyNames,
  DateTime now, {        // local
  int max = maxScheduledNotifications,
});

/// Id estável: FNV-1a 32 bits de "$deadlineId|$yyyy-MM-dd|$kind" (`kind` = "r"
/// lembrete ou "w" semanal), com `& 0x7fffffff` (positivo, cabe no int do Android).
int notificationIdFor(String deadlineId, DateTime date, {required bool weekly});
```

`notification_scheduler.dart`:

```dart
abstract interface class NotificationScheduler {
  /// Toques em notificações com o app aberto ou em segundo plano: payload = id do prazo.
  Stream<String> get taps;
  /// Payload da notificação que abriu o app fechado; `null` se não foi uma.
  Future<String?> launchPayload();
  /// Permissão do sistema concedida (Android 13+); `true` em versões sem permissão.
  Future<bool> areEnabled();
  /// Mostra o pedido do sistema; devolve se ficou concedida.
  Future<bool> requestPermission();
  Future<void> openSystemSettings();
  /// Cancela os pendentes e agenda [plan]. Não remove notificações já exibidas.
  Future<void> replaceAll(List<PlannedNotification> plan);
  /// Cancela os pendentes.
  Future<void> cancelAll();
}
```

`LocalNotificationScheduler` (APIs conferidas no pub cache, v23.0.4):

- `static Future<LocalNotificationScheduler> create()`: `tzdata.initializeTimeZones()` (`package:timezone/data/latest_all.dart`); `tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier))`, com `try/catch` caindo para `America/Sao_Paulo`; `plugin.initialize(settings: InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')), onDidReceiveNotificationResponse: (r) { if (r.payload != null) _taps.add(r.payload!); })`.
- `launchPayload`: `plugin.getNotificationAppLaunchDetails()`; se `didNotificationLaunchApp`, `notificationResponse?.payload`.
- `areEnabled`/`requestPermission`: `resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()` → `areNotificationsEnabled()` / `requestNotificationsPermission()` (`null` → `true`).
- `openSystemSettings`: `plugin.openAppNotificationSettings()`.
- `replaceAll` (na implementação, serializado por `LatestOnlyRunner`: uma substituição por vez, só a mais recente; `cancelAll` = substituir por lista vazia): `plugin.cancelAllPendingNotifications()` e, para cada item, `zonedSchedule(id:, scheduledDate: tz.TZDateTime(tz.local, y, m, d, 8), notificationDetails: _details, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, title:, body:, payload: deadlineId, matchDateTimeComponents: weekly ? DateTimeComponents.dayOfWeekAndTime : null)`.
- `_details`: `NotificationDetails(android: AndroidNotificationDetails('prazos', 'Vencimento de prazos', channelDescription: 'Avisos nos dias de lembrete de cada prazo', importance: Importance.high, priority: Priority.high, styleInformation: BigTextStyleInformation('')))`. Se `BigTextStyleInformation('')` não exibir o corpo, use `null` e registre no journal.
- Exceções do plugin no `replaceAll` são capturadas e registradas com `debugPrint` (o app não pode quebrar por causa de notificação).

`notification_settings.dart`:

```dart
abstract interface class NotificationSettings {
  Future<bool> isEnabled();              // padrão true
  Future<void> setEnabled(bool value);
  Future<bool> wasPermissionAsked();     // padrão false
  Future<void> markPermissionAsked();
}
```

`SharedPrefsNotificationSettings` usa `SharedPreferencesAsync()` com as chaves `notifications.enabled` e `notifications.permission_asked`.

`notification_providers.dart`:

```dart
/// Sobrescrito em main.dart (instância criada antes do runApp) e nos testes.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => throw UnimplementedError('notificationSchedulerProvider não configurado'),
);
final notificationSettingsProvider = Provider<NotificationSettings>(
  (ref) => SharedPrefsNotificationSettings(),
);
/// Ligado/desligado (Ajustes). `set` grava e atualiza o estado.
final notificationsEnabledProvider =
    AsyncNotifierProvider<NotificationsEnabledNotifier, bool>(NotificationsEnabledNotifier.new);
/// Permissão do sistema; `ref.invalidate` ao voltar para o app.
final notificationPermissionProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationSchedulerProvider).areEnabled(),
);
```

`notification_sync.dart`:

```dart
/// Mantém os agendamentos iguais ao plano. Ativado por `ref.watch` no NormaTrackApp.
final notificationSyncProvider = Provider<void>((ref) { ... });
```

## Regras de implementação

- **Plano por prazo** (só `d.isOpen`; a lista já vem filtrada):
  - Para cada `days` em `reminderDays`: `date = reminderDate(dueDate, days)`; `fireAt = DateTime(date.year, date.month, date.day, 8)`; entra se `fireAt.isAfter(now)`. Lembrete de hoje depois das 8h **não** é agendado: o Painel mostra o prazo. **[suposição]** (evita reavisar a cada abertura do app).
  - Semanal: `first = DateTime(due.y, due.m, due.d + 7, 8)`; enquanto `!first.isAfter(now)`, soma 7 dias (`DateTime(y, m, d + 7, 8)`). Uma entrada `weekly: true` com esse `fireAt`. Vale para todo prazo em aberto (os ainda não vencidos já deixam a semanal agendada).
  - **Corrigido na implementação (2026-11-26):** o Android repete `dayOfWeekAndTime` a partir da próxima ocorrência contando de agora e ignora a data de início (visto no emulador e no código nativo do plugin). A entrada repetitiva só é usada quando `first` está a menos de 7 dias de `now`; senão, `overdueOneShotWeeks` (4) avisos avulsos em `first`, `first + 7`, `+ 14`, `+ 21`. Ver journal e D013.
  - O plano não depende de "hoje" fora do `now` recebido.
- **Textos** (`title` = `d.title`; `empresa` = `companyNames[d.companyId]`, omitida com o separador se faltar):
  - Lembrete, `n = dias de date até dueDate`: `n == 0` → `"$empresa · Vence hoje"`; `n == 1` → `"$empresa · Vence amanhã (dd/MM/aaaa)"`; senão `"$empresa · Vence em $n dias (dd/MM/aaaa)"`.
  - Semanal: `"$empresa · Vencido desde dd/MM/aaaa"` (data do vencimento). Texto fixo porque a mesma notificação se repete.
- **Ordem e teto**: ordenar por `fireAt`, depois título (`normalizeForSearch`, de `lib/core/utils/search_text.dart`), depois `id`; `take(max)`. O que fica de fora entra numa sincronização futura (cada abertura do app reagenda). Registrar no journal se o teto for atingido em uso real.
- **Ids**: `notificationIdFor` (FNV-1a: `h = 0x811c9dc5`; para cada unidade UTF-16 `h = ((h ^ c) * 0x01000193) & 0xffffffff`; resultado `h & 0x7fffffff`). Estáveis entre sincronizações, para que reagendar não troque o id de uma notificação já exibida.
- **Sincronização** (`notificationSyncProvider`):
  - Lê `ref.watch(notificationsEnabledProvider)`, `ref.watch(upcomingDeadlinesProvider)` e `ref.watch(companyNamesProvider)`. Enquanto algum estiver carregando ou com erro, não faz nada.
  - Desligado → `scheduler.cancelAll()`. Ligado → `scheduler.replaceAll(planDeadlineNotifications(list, names, ref.read(clockProvider)().toLocal()))`.
  - Não pede permissão: agenda mesmo sem permissão (o Android guarda os agendamentos; aparecem quando a permissão for dada).
  - Chamadas são `unawaited` com `catchError` → `debugPrint`.
- **Ativação**: `NormaTrackApp.build` faz `ref.watch(notificationSyncProvider)`.
- **Toque** (`lib/app/notification_navigation.dart`):
  ```dart
  /// Vai ao Painel e empilha o detalhe do prazo (voltar leva ao Painel).
  /// Prazo inexistente ou excluído: só o Painel.
  Future<void> openDeadlineFromNotification(GoRouter router, DeadlineRepository repo, String deadlineId);
  ```
  `NormaTrackApp` vira `ConsumerStatefulWidget`; no `initState`, assina `scheduler.taps` (cancelar no `dispose`) e, depois do primeiro frame (`WidgetsBinding.instance.addPostFrameCallback`), lê `launchPayload()` e, se houver, abre o prazo.
- **Permissão na primeira abertura** **[suposição]**: depois do primeiro frame, se `isEnabled()` e `!wasPermissionAsked()`, chama `requestPermission()` e `markPermissionAsked()`, uma vez só. Depois disso, só pela tela de Ajustes.
- **main.dart**:
  ```dart
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final scheduler = await LocalNotificationScheduler.create();
    runApp(ProviderScope(
      overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
      child: const NormaTrackApp(),
    ));
  }
  ```
  `tasks/009-painel-vencimentos/prototypes/seed_main.dart` passa a sobrescrever o mesmo provider (senão quebra ao rodar).
- Marque com `// TODO(RF-PRZ-03):` a hora fixa (C4), o lembrete de hoje depois das 8h e o pedido de permissão na primeira abertura.

## Interface

`SettingsScreen` (`ConsumerStatefulWidget`) em `/ajustes`, no lugar do placeholder:

- `appBar: AppBar(title: BandTitle(title: 'Ajustes', large: true))`.
- `body: ListView(padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xl))` com um `SectionCard(title: 'Alertas', children: [...])`:
  - `SwitchRow(leadingIcon: Icons.notifications_outlined, title: 'Notificações de vencimento', subtitle: 'Às 8h, nos dias de lembrete e toda semana depois de vencido', value: enabled, onChanged: _toggle)`.
  - Só quando ligado **e** a permissão do sistema está negada: `NavRow(leadingIcon: Icons.notifications_off_outlined, title: 'Bloqueadas no Android', subtitle: 'Toque para permitir nas configurações do aparelho', onTap: scheduler.openSystemSettings)`.
- `_toggle(true)`: `set(true)`; se a permissão está negada, `requestPermission()` e `markPermissionAsked()`; depois `ref.invalidate(notificationPermissionProvider)`. `_toggle(false)`: `set(false)`.
- Ao voltar para o app (`AppLifecycleListener(onResume: () => ref.invalidate(notificationPermissionProvider))`, criado no `initState` e descartado no `dispose`), a linha de bloqueio some se a permissão foi dada.
- Carregando: o interruptor aparece com `value: true` desabilitado (`onChanged` sem efeito) até o ajuste carregar. Sem `FilledButton` na tela.
- Wireframe `docs/design/wireframes/Ajustes.dc.html`: trocar "Aviso diário na janela de alerta" pelo subtítulo acima. Backup, "Antecedência padrão" e "Sobre" ficam no wireframe e fora desta task.

## Testes

"Agora" nos testes do planejador: `DateTime(2026, 9, 29, 9)` (local). Prazos (empresa "Indústria Alfa Ltda", id `c1`):

| Prazo | Vencimento | Lembretes | Agendados (fireAt às 8h) |
|---|---|---|---|
| Licença de Instalação (`d1`) | 2026-11-13 | 150, 30, 10, 3, 0 | 14/10, 03/11, 10/11, 13/11 (150 → 16/06, passado) + semanal 20/11 |
| Licença de Operação (`d2`) | 2026-09-26 (vencido) | 150, 30, 10, 3, 0 | só semanal 03/10 |
| Laudo antigo (`d3`) | 2026-09-09 (vencido) | 30, 10, 3, 0 | só semanal 30/09 (16/09 e 23/09 já passaram) |
| Laudo de hoje (`d4`) | 2026-09-29 | 30, 10, 3, 0 | nada às 8h de hoje (já são 9h); semanal 06/10 |

Datas conferidas: 13/11 − 30 = 14/10; − 10 = 03/11; − 3 = 10/11; − 150 = 16/06; 26/09 + 7 = 03/10; 09/09 + 21 = 30/09; 29/09 + 7 = 06/10.

| Arquivo | Cobre |
|---|---|
| `test/core/notifications/deadline_notification_planner_test.dart` | tabela acima (fireAt, weekly, ordem global: 30/09 d3, 03/10 d2, 06/10 d4, 14/10 d1, 03/11, 10/11, 13/11, 20/11); textos: "Indústria Alfa Ltda · Vence em 30 dias (13/11/2026)", "… · Vence em 10 dias (13/11/2026)", "… · Vence hoje", "… · Vencido desde 26/09/2026"; lembrete de 1 dia → "Vence amanhã (dd/MM/aaaa)"; empresa ausente → texto sem "· "; teto (`max: 3`) mantém os 3 primeiros; `now` exatamente às 8h do dia do lembrete não agenda (não é *depois*); `notificationIdFor` estável, diferente entre lembrete e semanal do mesmo dia, sempre em `0..0x7fffffff`; lista vazia → `[]` |
| `test/core/notifications/notification_sync_test.dart` | `ProviderContainer` com fakes (repositórios da task 009, `FakeNotificationScheduler`, `FakeNotificationSettings`, `clockProvider` fixo): ao ativar, `replaceAll` com o plano; criar prazo → novo `replaceAll` que o inclui; arquivar a empresa → plano sem os prazos dela; desligar → `cancelAll`; religar → `replaceAll` de novo |
| `test/app/notification_navigation_test.dart` | via `pumpApp`: `fake.tap('<id>')` abre o detalhe (título na faixa) e voltar leva ao Painel; id inexistente fica no Painel; `launchPayload` definido antes do `pumpApp` abre o detalhe na abertura |
| `test/features/settings/presentation/settings_screen_test.dart` | seção "Alertas" e interruptor ligado por padrão; desligar grava `false` e chama `cancelAll`; ligar com permissão negada chama `requestPermission`; com ligado e permissão negada aparece "Bloqueadas no Android" e tocar chama `openSystemSettings`; com permissão concedida a linha não aparece |
| `test/app/first_launch_permission_test.dart` | primeira abertura pede permissão uma vez e marca; segunda abertura (`wasPermissionAsked` = true) não pede; com notificações desligadas não pede |
| `test/widget_test.dart` | aba Ajustes mostra "Alertas" no lugar de "Ajustes em construção" |

Fakes:

- `FakeNotificationScheduler`: guarda `lastPlan`, contadores `replaceCalls`, `cancelCalls`, `permissionRequests`, `settingsOpened`; `enabled` (padrão `true`) e `grantOnRequest` (padrão `true`) configuráveis; `String? launch`; `void tap(String id)` emite em `taps`.
- `FakeNotificationSettings`: em memória, padrões `enabled = true`, `asked = true` (para os testes existentes não verem o pedido de permissão; o teste de primeira abertura usa `asked: false`).
- `pumpApp` ganha parâmetros opcionais `notificationScheduler` e `notificationSettings` (cria os fakes se não vierem) e os coloca nos overrides.

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` sem avisos, `flutter test` verde (324 + os novos).
- `flutter build apk --debug` compila.
- No emulador (com `seed_main.dart` da task 009 para ter dados): na primeira abertura aparece o pedido de permissão; Ajustes mostra a seção Alertas; `adb shell dumpsys alarm | grep normatrack` mostra alarmes agendados. Para ver uma notificação de verdade, mude a hora do emulador para 07:59 de um dia de lembrete (`adb shell date` exige root; use as configurações de data/hora do emulador) ou crie um prazo com lembrete amanhã e avance a data. Tocar na notificação abre o detalhe; voltar leva ao Painel. Desligar em Ajustes some com os pendentes. Negar a permissão (`adb shell pm revoke br.com.normatrack.app android.permission.POST_NOTIFICATIONS`) faz aparecer "Bloqueadas no Android"; o toque abre as configurações do app. Ao fim, deixar a permissão como estava.

## Riscos e alternativas

- **[suposição]** Hora fixa 8h; lembrete do dia depois das 8h não é agendado; permissão pedida na primeira abertura. Em C4 / journal.
- Fabricantes que matam apps em segundo plano (Xiaomi, Huawei) podem atrasar ou perder alarmes inexatos (README do plugin). O Painel continua sendo a fonte confiável.
- Limite de 500 alarmes (Samsung): teto de 400.
- AGP 9.1.1 e compileSdk 37 são exigência do plugin; o spike compilou com eles.
- *Descartado:* alarme exato (`SCHEDULE_EXACT_ALARM`), desnecessário para aviso diário; `WorkManager` com checagem diária, mais frágil e com mais configuração nativa; tabela drift para o ajuste (é preferência do aparelho, não dado do domínio, e não precisa sincronizar); um resumo por dia (o usuário escolheu uma notificação por prazo); horário configurável (o usuário escolheu 8h fixo).

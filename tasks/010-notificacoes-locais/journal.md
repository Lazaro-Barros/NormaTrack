# Journal — 010

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-30 — Task criada

**Feito**
- Criada junto com as tasks 007 a 010, na divisão das telas de prazo depois da task 006 (domínio e dados): 007 módulo e cadastro, 008 detalhe e renovação, 009 painel, 010 notificações.

**Pendente / dúvidas**
- Rascunho. Pendente: C4 (repetição do alerta até a renovação) e escolha do pacote de notificações.

## 2026-11-26 — Refinamento: respostas do usuário

**Decidido** (respostas do usuário)
- Quando avisar: nos dias de lembrete do prazo (`reminderDays`, ex.: licença 150, 30, 10, 3 e no dia) e, depois de vencido, uma vez por semana até o prazo ser renovado, concluído ou cancelado. Registrado em C4. Alternativas descartadas: só nos dias de lembrete (nada depois de vencido); todo dia na janela de alerta (como dizia o wireframe de Ajustes).
- Uma notificação por prazo (tocar abre o detalhe daquele prazo). Descartado: um resumo por dia.
- Horário fixo: 8h. Descartado: horário ajustável em Ajustes.
- Ajustes agora só com a seção Alertas (ligar/desligar e permissão do Android 13+). Backup e "Sobre" ficam para a task de backup (RNF-04).

## 2026-11-26 — Spike e plano

**Feito**
- Conferida no pub cache a API de `flutter_local_notifications` 23.0.4 (`initialize(settings:)`, `zonedSchedule(id:, scheduledDate:, …, androidScheduleMode:, matchDateTimeComponents:)`, `cancelAllPendingNotifications`, `getNotificationAppLaunchDetails`, `openAppNotificationSettings`, `requestNotificationsPermission`, `areNotificationsEnabled`), `flutter_timezone` 5.1.1 (`getLocalTimezone()` → `TimezoneInfo.identifier`), `timezone` 0.11.2 e `shared_preferences` 2.5.6 (`SharedPreferencesAsync`).
- O plugin exige AGP ≥ 9.1.1, compileSdk 37 e desugaring. O projeto estava com AGP 9.1.0 e compileSdk 36.
- Spike numa cópia do projeto (`prototypes/spike/`): compilou e rodou no emulador; fuso `America/Fortaleza`; diálogo de permissão devolveu `true`; a notificação inexata agendada para +20 s chegou com o app em segundo plano; a semanal repetitiva ficou pendente. O spike substituiu o app instalado no emulador (mesmo `applicationId`), sem perder dados.
- `plan.md` escrito (planejador puro, sincronizador, agendador atrás de interface, toque, Ajustes, testes com datas conferidas por script). README com escopo e 8 critérios. Status → `planejada`.

**Decidido** (por conta do agente, no plano)
- Agendamento inexato (`inexactAllowWhileIdle`), sem permissão de alarme exato — como já previa `docs/04`.
- Substituir todos os pendentes a cada mudança, com ids estáveis (FNV-1a de prazo + data + tipo) e teto de 400 (limite de 500 alarmes de alguns aparelhos).
- Semanal como uma notificação repetitiva (`dayOfWeekAndTime`) agendada desde já, a partir de vencimento + 7 dias, para funcionar mesmo sem abrir o app.
- Ajuste ligado/desligado em `shared_preferences`, não no banco (preferência do aparelho, não dado do domínio). Vira D013 no fechamento.
- **[suposição]** lembrete de hoje depois das 8h não é agendado; permissão pedida uma vez na primeira abertura.

**Pendente / dúvidas**
- Aprovação do plano pelo usuário.

## 2026-11-26 — Implementação, passo 1: setup

**Feito**
- Plano aprovado pelo usuário. Status → `em andamento`.
- AGP 9.1.1, compileSdk 37, desugaring e receivers no manifest (igual ao `prototypes/spike/android.diff`); pacotes `flutter_local_notifications` ^23.0.4, `timezone` ^0.11.2, `flutter_timezone` ^5.1.1, `shared_preferences` ^2.5.6. `flutter build apk --debug` compila; 324 testes verdes.

## 2026-11-26 — Passos 2 a 4: planejador, agendador e sincronização

**Feito**
- Planejador puro (`lib/core/notifications/deadline_notification_planner.dart`) com 11 testes, nas datas da tabela do plano.
- `NotificationScheduler` + `LocalNotificationScheduler`, `NotificationSettings` + `SharedPrefsNotificationSettings` (teste com `InMemorySharedPreferencesAsync`; `shared_preferences_platform_interface` entrou como dev_dependency), providers e fakes no `pumpApp`.
- Sincronizador ligado no `NormaTrackApp`; `main.dart` cria o `LocalNotificationScheduler` antes do `runApp`. `seed_main.dart` da 009 ajustado para o mesmo override. 342 testes verdes.

**Decidido** (desvios do plano)
- O sincronizador ficou em `lib/app/notification_sync.dart`, não em `lib/core/notifications/`: ele lê os providers da feature de prazos, e o `core` não deve depender de `features/*/presentation`.
- Sem `BigTextStyleInformation('')`: com texto vazio, a notificação expandida ficaria vazia. O corpo é curto e cabe no estilo padrão.
- `notificationSyncProvider` é `autoDispose` (assiste providers `autoDispose`); fica vivo porque o `NormaTrackApp` o assiste.

## 2026-11-26 — Passos 5 a 7: toque, Ajustes, emulador e fechamento

**Feito**
- Toque na notificação (`lib/app/notification_navigation.dart`): vai ao Painel e empilha o detalhe; prazo inexistente fica no Painel. `NormaTrackApp` virou `ConsumerStatefulWidget`, assina `taps`, lê `launchPayload()` e pede a permissão uma vez na primeira abertura.
- Tela de Ajustes (`lib/features/settings/presentation/settings_screen.dart`) com a seção Alertas; placeholder removido. Wireframe com o subtítulo novo.
- **Emulador:** com os dados do `seed_main.dart` (3 prazos em aberto), o Android mostrou os alarmes do plano. Desligar em Ajustes zerou os alarmes (17 → 0) e religar voltou a 17. Revogando `POST_NOTIFICATIONS`, apareceu "Bloqueadas no Android", e o toque abriu `AppNotificationSettingsActivity`; com a permissão devolvida, a linha sumiu ao voltar (`AppLifecycleListener`). Permissão deixada concedida, como estava.
- **Bug achado no emulador e corrigido:** as semanais de prazos ainda não vencidos estavam marcadas para o próximo domingo/quarta, e não para vencimento + 7. O código nativo do plugin (`getNextFireDateMatchingDateTimeComponents`) calcula a próxima ocorrência *a partir de agora* e ignora a data de início. Correção no planejador: repetitiva só com a primeira ocorrência a menos de 7 dias; antes disso, 4 avisos semanais avulsos. Plano, `docs/04` e D013 atualizados.
- **Corrida corrigida:** na abertura o sincronizador dispara várias vezes seguidas; duas substituições intercaladas podiam deixar itens de um plano velho. `LatestOnlyRunner` faz uma por vez e aplica só a mais recente (com teste).
- `docs/05` (item marcado), `docs/07` (linha de Ajustes), `docs/decisoes.md` D013. Suíte: 356 testes verdes; `flutter analyze` limpo; APK debug compila.

**Pendente / dúvidas**
- **Não conferido no aparelho:** o toque numa notificação real abrindo o detalhe (coberto por testes de widget). A entrega de uma notificação agendada foi vista no spike.
- Se o app não for aberto por mais de 4 semanas depois de um vencimento ainda distante no momento da última abertura, os avisos semanais param até a próxima abertura (limite do plugin, D013).
- C4 (hora fixa, semanal, uma por prazo) e as suposições (lembrete do dia depois das 8h não agendado; permissão na primeira abertura) aguardam confirmação da cliente.
- Fabricantes que matam apps em segundo plano podem atrasar alarmes inexatos (README do plugin).

**Refs:** commits 9462725, 870ca97, 3eb064b, 4a5e8c1, 219be02, a44c896, 729c47b, cdd68b0, 5cddfb8 · docs/decisoes.md#d013

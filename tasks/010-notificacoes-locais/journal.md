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

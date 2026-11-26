# 010 — Notificações locais de prazo

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RF-PRZ-03 · RNF-05 · D004 |
| **Depende de** | 006, 008, 009 |
| **Wireframe** | [Ajustes](../../docs/design/wireframes/Ajustes.dc.html) (só a seção Alertas) |

## Objetivo

O celular avisa nos dias de lembrete de cada prazo em aberto e, depois de vencido, toda semana, mesmo com o app fechado.

> **Ponto de partida para quem for implementar:** [plan.md](plan.md).

## Escopo

- Notificação local às **8h** (fixo) em cada dia de lembrete do prazo (`reminderDays`) e, a partir de 7 dias depois do vencimento, **uma vez por semana** até o prazo ser renovado, concluído, cancelado ou excluído.
- **Uma notificação por prazo**: título do prazo, empresa e quando vence. Tocar abre o detalhe do prazo; voltar leva ao Painel.
- Agendamentos refeitos a cada mudança em prazos, empresas (arquivar, desligar módulo) ou no ajuste, e a cada abertura do app.
- Permissão do Android 13+ pedida na primeira abertura.
- Tela **Ajustes** com a seção Alertas: ligar/desligar as notificações e aviso "Bloqueadas no Android" com atalho para as configurações do aparelho.
- Android: AGP 9.1.1, compileSdk 37, desugaring e receivers do plugin.

## Fora de escopo

- Alertas por e-mail (Fase 5, C24).
- Horário configurável e resumo diário (descartados pelo usuário).
- Backup/restauração, "Antecedência padrão" e "Sobre" em Ajustes (task de backup, RNF-04).
- Alarme exato.

## Decisões (2026-11-26)

- Respostas do usuário: dias de lembrete + semanal depois de vencido; uma notificação por prazo; 8h fixo; Ajustes só com Alertas (C4, journal).
- **[suposição]** Lembrete de hoje já passado das 8h não é agendado; a permissão é pedida uma vez na primeira abertura.

## Critérios de aceite

- [x] Cada prazo em aberto tem notificação às 8h em cada dia de lembrete futuro e uma semanal a partir de 7 dias depois do vencimento, com o texto do plano.
- [x] Prazos renovados, concluídos, cancelados, excluídos, de empresa arquivada ou de módulo desligado não notificam (agendamentos refeitos a cada mudança).
- [x] Tocar na notificação abre o detalhe do prazo, com o app aberto ou fechado; voltar leva ao Painel. (Coberto por testes de widget com o agendador falso; no aparelho, só a entrega foi vista, no spike.)
- [x] Na primeira abertura o app pede a permissão de notificação uma vez.
- [x] Ajustes mostra a seção Alertas; desligar cancela os pendentes e ligar reagenda; com a permissão negada aparece "Bloqueadas no Android", que abre as configurações.
- [x] Os testes do plano (planejador, sincronização, toque, Ajustes, primeira abertura) passam.
- [x] `dart format .`, `flutter analyze`, `flutter test` e `flutter build apk --debug` sem erros; conferido no emulador.
- [x] `docs/04`, `docs/07`, `docs/decisoes.md` (D013), roadmap e wireframe de Ajustes atualizados.

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

# 012 — Backup e restauração manual do banco

| | |
|---|---|
| **Status** | concluída |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)) |
| **Requisitos** | RNF-04 |
| **Depende de** | 010 (tela de Ajustes, sincronização das notificações) |
| **Wireframe** | [docs/design/wireframes/Ajustes.dc.html](../../docs/design/wireframes/Ajustes.dc.html) (aviso e linhas "Fazer backup" / "Restaurar backup") |

## Objetivo

Os dados vivem só no aparelho. Com esta task, a usuária gera em Ajustes um arquivo com todos os dados e o envia para onde quiser (Drive, WhatsApp, e-mail), e consegue restaurar esse arquivo no mesmo aparelho ou em outro. O app avisa enquanto nenhum backup foi feito.

> **Ponto de partida para quem for implementar:** [plan.md](plan.md).

## Escopo

- **Fazer backup:** cópia consistente do banco SQLite (`VACUUM INTO`) num arquivo `NormaTrack-backup-AAAA-MM-DD-HHMM.ntbackup`, entregue pela folha de compartilhamento do Android.
- **Restaurar backup:** seletor de arquivo do Android, validação do arquivo, confirmação com o resumo (empresas, prazos, última alteração) e substituição de todos os dados. Antes de substituir, o app guarda uma cópia automática dos dados atuais; o SnackBar de sucesso oferece "Desfazer".
- **Validação:** só banco do NormaTrack; backup de versão de schema mais antiga é migrado ao abrir; de versão mais nova é recusado ("atualize o app"); arquivo de outro app ou corrompido é recusado sem tocar nos dados.
- Depois de restaurar, todas as telas e os agendamentos de notificação refletem os dados restaurados, sem reiniciar o app.
- **Aviso** em Ajustes: "Os dados ficam só neste aparelho. Nenhum backup feito ainda." até o primeiro backup; depois, a linha "Fazer backup" mostra "Último backup em DD/MM/AAAA".
- Novos componentes genéricos: `NoticeBanner` (aviso na cor suave de um tom) e `showProgressDialog` (operação bloqueante com indicador).

## Fora de escopo

- Lembrete periódico de backup (notificação ou aviso depois de N dias): descartado por ora pelo usuário.
- Backup automático, em nuvem ou agendado; exportação legível (JSON, planilha).
- Escolher pasta para salvar (o compartilhamento cobre Drive e Arquivos).
- Preferências do aparelho (notificações ligadas, permissão pedida, data do último backup): ficam em `shared_preferences` e não entram no backup (D013).
- "Antecedência padrão" e "Sobre" em Ajustes (wireframe): ficam para outra task.

## Decisões (2026-11-26)

Respostas do usuário, todas na opção recomendada (journal, C25):

- Formato: cópia do arquivo SQLite, enviada pela folha de compartilhamento.
- Restaurar: confirmação com resumo + cópia automática dos dados atuais antes de substituir.
- Validação: mesma versão de schema ou mais antiga (migrada); mais nova é recusada.
- Aviso "Nenhum backup feito ainda" e data do último backup, sem lembrete periódico.

## Critérios de aceite

- [x] "Fazer backup" gera o arquivo `.ntbackup` com todos os dados e abre a folha de compartilhamento; escolher um destino grava a data do último backup, fechar a folha não grava.
- [x] Ajustes mostra o aviso âmbar enquanto não há backup e "Último backup em DD/MM/AAAA" depois.
- [x] "Restaurar backup" valida o arquivo escolhido e pede confirmação com empresas, prazos e data da última alteração; cancelar não muda nada.
- [x] Confirmar substitui os dados; Painel, Empresas, detalhes e notificações passam a refletir o backup sem reiniciar o app; "Desfazer" volta aos dados de antes.
- [x] Backup de schema mais antigo é migrado; mais novo, de outro app ou corrompido é recusado com mensagem clara e os dados atuais ficam intactos (também se a abertura do banco restaurado falhar; este último coberto por teste, não no emulador).
- [x] Testes do plano passam (serviço de backup com arquivos reais, providers reabrindo o banco, Ajustes, componentes novos).
- [x] `dart format .`, `flutter analyze`, `flutter test` e `flutter build apk --debug` sem erros; conferido no emulador sem perder os dados da usuária.
- [x] `docs/02`, `docs/04`, `docs/05`, `docs/06`, `docs/07`, `docs/decisoes.md` e o wireframe de Ajustes atualizados.

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)

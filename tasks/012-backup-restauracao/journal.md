# Journal — 012

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-26 — Task criada e refinada

**Feito**
- Task criada a partir do último item da Fase 1 do roadmap (RNF-04), pedida pela sessão principal depois das tasks 009–011.
- Lidos RNF-04 (`docs/02`), a sugestão de pacotes e o risco de perda de dados (`docs/04`), o wireframe de Ajustes (aviso + "Fazer backup" / "Restaurar backup" acima de Alertas), a tela de Ajustes da task 010, o `AppDatabase` e a cadeia de providers até o `notificationSyncProvider`.
- Conferidas no pub cache as APIs de `share_plus` 13.3.1, `file_picker` 13.4.1 (federado: `android_file_picker` 2.2.1), `drift_flutter` 0.3.1 (caminho padrão `<documentos>/normatrack.sqlite`, isolate de fundo) e `sqlite3` 3.6.0.

**Decidido** (perguntas ao usuário, todas na opção recomendada; registradas em `docs/06` como C25)
- Formato: cópia do SQLite (`VACUUM INTO`) num `.ntbackup` datado, enviada pela folha de compartilhamento. Descartados: salvar numa pasta escolhida; exportação JSON.
- Restaurar: confirmação com resumo (empresas, prazos, última alteração) e cópia automática dos dados atuais antes de substituir, com "Desfazer". Descartados: só confirmação; backup obrigatório antes.
- Validação: aceita mesma versão de schema ou mais antiga (migrada ao abrir); recusa mais nova, outro app ou corrompido sem tocar nos dados.
- Aviso "Os dados ficam só neste aparelho. Nenhum backup feito ainda." até o primeiro backup; depois, "Último backup em DD/MM/AAAA". Sem lembrete periódico por ora.
- Técnico (agente): banco reabrível por uma "época" no Riverpod em vez de reiniciar o app; data do último backup em `shared_preferences` (D013), fora do backup.

**Pendente / dúvidas**
- Suposições do plano marcadas com **[suposição]**: `unavailable` no compartilhamento não conta como backup; só a cópia de segurança mais recente; o que o resumo conta; pilhas das outras abas não são resetadas.
- "Antecedência padrão" e "Sobre" do wireframe ficam fora (outra task).

## 2026-11-26 — Plano aprovado; pacotes e build

**Feito**
- Usuário aprovou o plano sem mudanças. Status → `em andamento`.
- `flutter pub add share_plus file_picker path_provider 'sqlite3:^3.6.0' path`: share_plus 13.3.1, file_picker 13.4.1 (android_file_picker 2.2.1), path_provider 2.1.6, sqlite3 3.6.0 mantido no lock, path 1.9.1.
- `flutter build apk --debug` passou sem mudar nada em `android/` (com `android.builtInKotlin=false`, os plugins Kotlin aplicam o próprio `kotlin-android`).

## 2026-11-26 — Banco reabrível

**Feito**
- `AppDatabase.close()` idempotente; `currentSchemaVersion = 2`; `appDatabasePath()` explícito (mesmo caminho padrão do drift_flutter, nada muda para os dados existentes); `databasePathProvider`, `databaseOpenerProvider` e `databaseEpochProvider` (`reopen()`), observados pelo `appDatabaseProvider`.
- Teste `test/core/database/app_database_reopen_test.dart`: fechar duas vezes; `reopen()` cria outro banco, fecha o antigo e o `companiesProvider` passa a ler o novo.

## 2026-11-26 — Serviço de backup e restauração

**Feito**
- `lib/features/backup/domain/backup.dart` (Dart puro): `BackupSummary`, `BackupFailure`, `BackupException`, `BackupFile`, `backupFileName` e as interfaces `BackupService`, `BackupFiles`, `BackupSettings`.
- `LocalBackupService`: `VACUUM INTO` para gerar o backup e a cópia de segurança; `inspect` com `sqlite3` só leitura (`user_version`, tabelas por versão, `quick_check`, contagens); `restore` fecha, troca o arquivo (apaga `-wal`/`-shm`/`-journal`, cópia via `.tmp` + rename), reabre e força a abertura; em erro volta à cópia de segurança.
- `PlatformBackupFiles` (share_plus + file_picker) e `SharedPrefsBackupSettings` (`backup.last_at`).
- Testes com arquivos reais em pasta temporária: contagens (arquivada conta, excluída e renovada não), recusas (bytes aleatórios, outro app, sem `user_version`, versão 3, inexistente), troca A → B, desfazer e refazer, backup v1 migrado para v2 (com `validateDatabaseSchema`), falha simulada na reabertura volta aos dados A.

**Decidido**
- Desvio do plano: `undoRestore` move a cópia de segurança para a área de trabalho e, se a restauração falhar, devolve-a ao lugar, para os dados de antes continuarem desfazíveis. O `restore` público apaga o arquivo escolhido; o interno não.

## 2026-11-26 — NoticeBanner e diálogo de progresso

**Feito**
- `NoticeBanner` (`lib/app/widgets/notice_banner.dart`): fundo suave do tom, ícone e texto na cor forte, ênfase em `labelMedium`; o alinhamento do texto com o ícone sai da altura da linha (`AppTypography.lineHeight`), sem número fixo.
- `showProgressDialog` (`lib/app/widgets/progress_dialog.dart`): diálogo não dispensável que fecha quando a `Future` termina, devolvendo o valor ou propagando o erro.
- Testes de widget dos dois e linhas novas na tabela de componentes do `docs/07`.

## 2026-11-26 — Ajustes com backup e restauração

**Feito**
- `lastBackupAtProvider` (`AsyncNotifier`), `BackupNotice` e `BackupSection` em `lib/features/backup/presentation/backup_section.dart`; Ajustes mostra aviso → seção Backup → Alertas.
- Fluxos: gerar (progresso) → compartilhar → gravar data + "Backup feito"; escolher → conferir (progresso) → confirmação vermelha com resumo → restaurar (progresso) → "Backup restaurado" com "Desfazer" (10 s, `persist: false`).
- Fakes `test/helpers/fake_backup.dart`, sobrescritos por padrão no `pumpApp`.
- Testes: `settings_backup_test.dart` (aviso, data, folha fechada, erros, as 4 mensagens de recusa, plural e data na confirmação, cancelar, restaurar, desfazer, falha) e `restore_integration_test.dart` (banco em arquivo + providers reais: restaurar faz a sincronização agendar só os prazos do backup).

**Decidido**
- O subtítulo "Último backup em DD/MM/AAAA" fica no estilo padrão do `NavRow`, que não aceita estilo próprio; não vale estender o componente só para os algarismos tabulares de uma data curta.

## 2026-11-26 — Verificação no emulador

**Feito** (emulador `Medium_Phone_API_37.0`, app instalado com `adb install -r`, que mantém os dados; `flutter install` desinstala antes e não foi usado)
- Antes de tudo, cópia do banco da usuária no Mac (`adb exec-out run-as br.com.normatrack.app cat app_flutter/normatrack.sqlite`): 5 empresas, incluindo "Alfa To To To To"; 5 prazos ativos, 1 concluído, 1 renovado; `quick_check` ok.
- Ajustes mostra o aviso âmbar e a seção Backup como no wireframe.
- "Fazer backup": folha com `NormaTrack-backup-2026-11-26-1357.ntbackup` (Quick Share, Drive, Gmail). Fechar a folha não grava; escolher um app (Quick Share, saindo sem enviar) grava "Último backup em 26/11/2026" e tira o aviso. O arquivo gerado (puxado do cache) é SQLite v2 íntegro.
- Arquivos de teste enviados por `adb push` para `/sdcard/Download/`: texto → "Este arquivo não é um backup do NormaTrack."; `user_version` 3 → mensagem de versão mais nova; nos dois o banco ficou byte a byte igual.
- Backup com uma empresa e um prazo a mais ("Restaurada Teste Ltda", vence 10/12/2026): confirmação "6 empresas e 7 prazos, com última alteração em 26/11/2026"; depois de restaurar, o Painel mostra o prazo novo sem reiniciar e `shared_prefs/scheduled_notifications.xml` passa a ter "Restaurada Teste Ltda · Vence em 10 dias (10/12/2026)".
- "Desfazer" (dentro dos 10 s) volta aos dados de antes ("Dados anteriores de volta").
- Restaurado de novo o backup com os dados da usuária: as 5 tabelas ficaram iguais, linha a linha, à cópia inicial, e os agendamentos não têm mais o prazo de teste. Arquivos de teste apagados do emulador; ficou `/sdcard/Download/original-usuaria.ntbackup` (backup dos dados dela).

**Decidido**
- Limite confirmado: escolher um app na folha já conta como backup, mesmo que o envio não termine (o Android não informa mais que isso). Fica como suposição em C25.
- As falhas dos fluxos de backup passam a ir para o log (`debugPrint`), como na sincronização das notificações.

**Pendente / dúvidas**
- Uma vez, logo depois da primeira restauração (app aberto por `adb` sem `flutter run`), escolher um arquivo para restaurar não abriu a confirmação nem mostrou erro, embora o arquivo tenha sido copiado. Não reproduziu em quatro tentativas seguintes (duas com `flutter attach`, duas sem, incluindo a mesma sequência Painel → Ajustes → restaurar). Com o log de falhas, uma repetição deixa rastro no logcat (`flutter`).
- O arquivo escolhido fica em `files/backup/restaurar.ntbackup` quando a pessoa cancela ou o arquivo é recusado (é sobrescrito na próxima escolha). Pequeno; não tratado.

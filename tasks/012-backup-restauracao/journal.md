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

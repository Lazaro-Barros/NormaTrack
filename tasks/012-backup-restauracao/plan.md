# Plano técnico — 012

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RNF-04):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

O backup é uma **cópia do arquivo SQLite** feita com `VACUUM INTO` sobre o banco aberto (cópia consistente, compactada, sem depender do WAL), com extensão `.ntbackup`, entregue pela folha de compartilhamento (`share_plus`). A restauração escolhe o arquivo com `file_picker`, copia-o para uma área de trabalho do app, valida com `sqlite3` em modo só leitura (tabelas e `user_version`), mostra o resumo, guarda uma cópia de segurança dos dados atuais (`VACUUM INTO`), **fecha** o `AppDatabase`, troca o arquivo e **reabre** o banco trocando a "época" do provider. Tudo que depende do banco (repositórios, `StreamProvider`s, sincronização das notificações) se reconstrói sozinho pelo Riverpod. Se a abertura do banco restaurado falhar (migração, arquivo ruim), o app volta para a cópia de segurança.

## Contexto do repositório (em 2026-11-26)

- Flutter 3.47.9 (Dart ^3.13.4), Riverpod 3.4.3, drift 2.35.0 + drift_flutter 0.3.1, sqlite3 3.6.0 (transitivo), `shared_preferences` 2.5.6, `flutter_local_notifications` 23.
- `lib/core/database/app_database.dart`: `AppDatabase` com `schemaVersion => 2` (v1: `companies`, `company_modules`, `company_authorities`; v2: + `deadlines`, `deadline_reminders`), migração `stepByStep` e `PRAGMA foreign_keys = ON` no `beforeOpen`. `appDatabaseProvider` cria `AppDatabase(driftDatabase(name: 'normatrack'))` e fecha no `onDispose`.
- O `driftDatabase` do drift_flutter grava em `getApplicationDocumentsDirectory()/normatrack.sqlite` (no Android, `/data/data/br.com.normatrack.app/app_flutter/normatrack.sqlite`) e abre o banco num isolate de fundo (`NativeDatabase.createBackgroundConnection`). Fechar o `AppDatabase` encerra o isolate e solta o arquivo.
- Repositórios: `companyRepositoryProvider` e `deadlineRepositoryProvider` fazem `ref.watch(appDatabaseProvider)`; os `StreamProvider`s das telas e o `notificationSyncProvider` (`lib/app/notification_sync.dart`) dependem deles. Logo, reconstruir o `appDatabaseProvider` reconstrói a cadeia inteira.
- `test/core/providers_test.dart` sobrescreve `appDatabaseProvider.overrideWithValue(db)`: continua funcionando.
- `test/helpers/pump_app.dart` monta o app inteiro com fakes; a tela de Ajustes vai precisar dos fakes de backup ali também.
- Schemas gerados para teste: `test/core/database/app/generated/schema_v1.dart`, `schema_v2.dart` e `SchemaVerifier` (`drift_dev/api/migrations_native.dart`).
- Ajustes (`lib/features/settings/presentation/settings_screen.dart`, task 010) só tem a seção Alertas.
- Widgets disponíveis: `SectionCard`, `NavRow`, `SwitchRow`, `showConfirmDialog` (`destructive: true`). Não existe componente de aviso nem de progresso bloqueante.
- Android: AGP 9.1.1, compileSdk 37, `android.builtInKotlin=false` (plugins que aplicam `kotlin-android`, como `share_plus` e `android_file_picker`, funcionam).
- Armadilha: `VACUUM INTO` falha se o arquivo de destino já existe; apagar antes.
- Armadilha: o seletor do Android devolve uma cópia em `cache/file_picker/<uuid>/` (`copyToCache` padrão `true`); `PlatformFile.path` pode ser nulo em outros casos, por isso copiar com `xFile.saveTo`.

## Ordem de implementação

Um commit por passo, direto na `main`, cada um com `dart format .`, `flutter analyze` e `flutter test` verdes, seguido de `git push origin main`. Formato: `tipo(escopo): descrição [task 012, RNF-04]`.

1. **Pacotes e Android** — `flutter pub add share_plus file_picker path_provider 'sqlite3:^3.6.0' path`; `flutter build apk --debug` para provar que compila com AGP 9. Commit `build(backup): pacotes de backup e restauração`.
2. **Banco reabrível** — `app_database.dart`: `close()` idempotente, `databasePathProvider`, `databaseOpenerProvider`, `databaseEpochProvider`; testes. Commit `feat(banco): banco reabrível para restauração`.
3. **Domínio e serviço de backup** — `lib/features/backup/domain/backup.dart`, `data/local_backup_service.dart`, `data/shared_prefs_backup_settings.dart`, `data/platform_backup_files.dart`; testes com arquivos reais. Commit `feat(backup): serviço de backup e restauração do banco`.
4. **Componentes** — `NoticeBanner` e `showProgressDialog` em `lib/app/widgets/` com testes; `docs/07` atualizado. Commit `feat(design): NoticeBanner e diálogo de progresso`.
5. **Tela de Ajustes** — aviso, seção Backup, fluxos de backup e restauração, Desfazer; fakes em `test/helpers/`; testes de widget e de integração (providers reabrindo). Commit `feat(ajustes): backup e restauração em Ajustes`.
6. **Verificação no emulador** (ver "Como verificar"), registrada no journal; correções viram commits próprios.
7. **Fechamento** — critérios marcados, journal final, status `concluída` (README e índice), `docs/02` (RNF-04 sem "(?)"), `docs/04` (pacotes e risco), `docs/05` (roadmap), `docs/06` (C25), `docs/07` (tela Ajustes), `docs/decisoes.md` (D014), wireframe de Ajustes. Commit `docs(backup): fechamento da task 012 e D014`.

## Setup

| Pacote | Versão | Uso |
|---|---|---|
| `share_plus` | ^13.3.1 | `SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'application/octet-stream')], fileNameOverrides: [nome]))` → `ShareResult.status` (`success` = a pessoa escolheu um destino; `dismissed`; `unavailable`) |
| `file_picker` | ^13.4.1 | `FilePicker.pickFile(type: FileType.any)` → `PlatformFile?` (null = cancelou); `file.xFile.saveTo(destino)`; `FilePicker.clearTemporaryFiles()` |
| `path_provider` | ^2.1.6 (já transitivo) | `getApplicationDocumentsDirectory()`, `getApplicationSupportDirectory()`, `getTemporaryDirectory()` |
| `sqlite3` | ^3.6.0 (já transitivo; manter 3.6.0 no lock) | `sqlite3.open(path, mode: OpenMode.readOnly)`, `select`, `close()` |
| `path` | ^1.9.1 (já transitivo) | `p.join` |

APIs conferidas no pub cache (`~/.pub-cache/hosted/pub.dev/`): `file_picker-13.4.1/lib/src/file_picker.dart` (`pickFile`), `file_picker_platform_interface-4.3.0/lib/src/platform_file.dart` (`path`, `xFile`), `android_file_picker-2.2.1` (`copyToCache`), `share_plus-13.3.1/lib/share_plus.dart` e `share_plus_platform_interface-7.2.0` (`ShareParams`, `ShareResultStatus`), `drift_flutter-0.3.1/lib/src/native.dart` (`DriftNativeOptions.databasePath`, caminho padrão), `sqlite3-3.6.0` (`OpenMode`, `close`). Nenhuma mudança manual em `android/` é esperada (os plugins declaram o próprio `FileProvider`); se o build do passo 1 falhar, registrar no journal e ajustar.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| core | `lib/core/database/app_database.dart` | `close()` idempotente; `appDatabasePath()`; providers `databasePathProvider`, `databaseOpenerProvider`, `databaseEpochProvider`; `appDatabaseProvider` observando época e abridor |
| domain | `lib/features/backup/domain/backup.dart` | `BackupSummary`, `BackupFailure`, `BackupException`, `BackupFile`, interfaces `BackupService`, `BackupFiles`, `BackupSettings`; constantes de nome de arquivo |
| data | `lib/features/backup/data/local_backup_service.dart` | `LocalBackupService` (drift + sqlite3 + `dart:io`) e `backupServiceProvider` |
| data | `lib/features/backup/data/platform_backup_files.dart` | `PlatformBackupFiles` (share_plus + file_picker) e `backupFilesProvider` |
| data | `lib/features/backup/data/shared_prefs_backup_settings.dart` | `SharedPrefsBackupSettings` e `backupSettingsProvider` |
| presentation | `lib/features/backup/presentation/backup_providers.dart` | `lastBackupAtProvider` (`AsyncNotifierProvider<LastBackupAtNotifier, DateTime?>`) |
| presentation | `lib/features/backup/presentation/backup_section.dart` | `BackupNotice` e `BackupSection` (aviso + card com as duas linhas e os fluxos) |
| presentation | `lib/features/settings/presentation/settings_screen.dart` | aviso e seção Backup acima de Alertas |
| widgets | `lib/app/widgets/notice_banner.dart` | `NoticeBanner` |
| widgets | `lib/app/widgets/progress_dialog.dart` | `showProgressDialog` |

## Valores de referência

| Item | Valor |
|---|---|
| Nome do arquivo | `NormaTrack-backup-AAAA-MM-DD-HHMM.ntbackup`, hora local (ex.: `NormaTrack-backup-2026-11-26-1430.ntbackup`) |
| MIME no compartilhamento | `application/octet-stream` |
| Área de trabalho | `getApplicationSupportDirectory()/backup/` |
| Arquivo escolhido (copiado) | `<área>/restaurar.ntbackup` |
| Cópia de segurança | `<área>/antes-da-restauracao.ntbackup` (só a mais recente) |
| Backup gerado | `getTemporaryDirectory()/backup/<nome>` (a pasta é esvaziada a cada novo backup) |
| Preferência | `backup.last_at` (ISO-8601 UTC) em `SharedPreferencesAsync` |

`BackupFailure` (mensagem pt-BR no SnackBar):

| Valor | Quando | Mensagem |
|---|---|---|
| `notABackup` | não é SQLite, `user_version` 0, ou faltam tabelas da versão | "Este arquivo não é um backup do NormaTrack." |
| `newerVersion` | `user_version` > `schemaVersion` do app | "Este backup é de uma versão mais nova do NormaTrack. Atualize o app para restaurá-lo." |
| `corrupted` | `PRAGMA quick_check` ≠ `ok` | "Este backup está danificado e não pode ser restaurado." |
| `failed` | erro de E/S ou ao abrir o banco restaurado (com volta à cópia de segurança) | "Não foi possível restaurar o backup. Os dados atuais foram mantidos." |

Falha ao gerar ou compartilhar o backup: "Não foi possível fazer o backup."

## Domínio e contratos

`lib/features/backup/domain/backup.dart` (Dart puro, sem `dart:io`):

```dart
/// Resumo de um arquivo de backup, para a confirmação.
@immutable
class BackupSummary {
  const BackupSummary({required this.schemaVersion, required this.companyCount,
    required this.deadlineCount, this.lastChangeAt});
  final int schemaVersion;
  final int companyCount;   // empresas não excluídas (inclui arquivadas)
  final int deadlineCount;  // prazos não excluídos e não renovados (ciclos atuais)
  final DateTime? lastChangeAt; // maior updated_at de companies e deadlines (UTC); null se vazio
}

enum BackupFailure { notABackup, newerVersion, corrupted, failed }

class BackupException implements Exception {
  const BackupException(this.failure, [this.cause]);
  final BackupFailure failure;
  final Object? cause;
}

/// Arquivo gerado por [BackupService.create].
@immutable
class BackupFile { const BackupFile({required this.path, required this.name}); final String path; final String name; }

abstract interface class BackupService {
  /// Gera o backup do banco aberto. Lança [BackupException] (`failed`).
  Future<BackupFile> create();
  /// Caminho onde o arquivo escolhido deve ser copiado antes de [inspect].
  Future<String> stagingPath();
  /// Valida o arquivo em [path] sem alterá-lo. Lança [BackupException].
  Future<BackupSummary> inspect(String path);
  /// Substitui os dados pelos de [path] (validado de novo aqui), guardando
  /// antes a cópia de segurança. Em erro, os dados atuais ficam como estavam
  /// e lança [BackupException].
  Future<void> restore(String path);
  /// Volta aos dados de antes da última restauração. Lança [BackupException]
  /// (`failed`) se não houver cópia.
  Future<void> undoRestore();
}

/// Entrada e saída de arquivos pelo sistema (compartilhar, escolher).
abstract interface class BackupFiles {
  /// Abre a folha de compartilhamento. `true` se a pessoa escolheu um destino.
  Future<bool> share(BackupFile file);
  /// Abre o seletor e copia o escolhido para [destinationPath].
  /// `false` se a pessoa cancelou.
  Future<bool> pick(String destinationPath);
}

/// Preferências do aparelho sobre backup (fora do banco, D013).
abstract interface class BackupSettings {
  Future<DateTime?> lastBackupAt();
  Future<void> setLastBackupAt(DateTime at);
}

String backupFileName(DateTime localNow); // NormaTrack-backup-AAAA-MM-DD-HHMM.ntbackup
```

`LocalBackupService`:

```dart
LocalBackupService({
  required AppDatabase Function() database,      // banco aberto agora
  required Future<void> Function() reopen,        // troca a época e devolve
  required Future<String> Function() databasePath,
  required Future<String> Function() workDirectory, // área de trabalho (criada se faltar)
  required Future<String> Function() exportDirectory, // onde gerar o backup
  required Clock clock,
});
```

Provider (`backupServiceProvider`, `Provider<BackupService>`): `database: () => ref.read(appDatabaseProvider)`, `reopen: () async => ref.read(databaseEpochProvider.notifier).reopen()`, `databasePath: ref.read(databasePathProvider)`, `workDirectory` = support dir + `/backup`, `exportDirectory` = temp dir + `/backup`, `clock: ref.read(clockProvider)`.

Banco reabrível (`app_database.dart`):

```dart
class AppDatabase extends _$AppDatabase {
  Future<void>? _closing;
  @override
  Future<void> close() => _closing ??= super.close(); // idempotente
}

Future<String> appDatabasePath() async =>
    p.join((await getApplicationDocumentsDirectory()).path, 'normatrack.sqlite');

final databasePathProvider = Provider<Future<String> Function()>((ref) => appDatabasePath);
final databaseOpenerProvider = Provider<AppDatabase Function()>((ref) {
  final path = ref.watch(databasePathProvider);
  return () => AppDatabase(driftDatabase(name: 'normatrack',
      native: DriftNativeOptions(databasePath: path)));
});
final databaseEpochProvider = NotifierProvider<DatabaseEpoch, int>(DatabaseEpoch.new);
class DatabaseEpoch extends Notifier<int> {
  @override int build() => 0;
  /// Faz o [appDatabaseProvider] criar um banco novo (o antigo é fechado no onDispose).
  void reopen() => state++;
}
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(databaseEpochProvider);
  final db = ref.watch(databaseOpenerProvider)();
  ref.onDispose(db.close);
  return db;
});
```

O caminho explícito é o mesmo do padrão do drift_flutter (`<documentos>/normatrack.sqlite`): nada muda para os dados existentes.

## Regras de implementação

**create()**
1. `dir = exportDirectory()`; apagar o conteúdo e recriar.
2. `name = backupFileName(clock().toLocal())`; `path = p.join(dir, name)`.
3. `await database().customStatement('VACUUM INTO ?', [path])`.
4. Devolver `BackupFile(path, name)`. Qualquer erro → `BackupException(failed, e)`.

**inspect(path)** — `sqlite3.open(path, mode: OpenMode.readOnly)`, sempre fechado no `finally`:
1. `PRAGMA user_version` → `v`. `SqliteException` (ex.: "file is not a database") → `notABackup`.
2. `v == 0` → `notABackup`; `v > AppDatabase.schemaVersion` (constante `AppDatabase.currentSchemaVersion = 2`, usada pelo `schemaVersion`) → `newerVersion`.
3. Tabelas exigidas por versão (de `sqlite_master`): v ≥ 1 `companies`, `company_modules`, `company_authorities`; v ≥ 2 + `deadlines`, `deadline_reminders`. Falta → `notABackup`.
4. `PRAGMA quick_check` ≠ `ok` → `corrupted`.
5. Contagens: `SELECT COUNT(*) FROM companies WHERE deleted_at IS NULL`; com v ≥ 2, `SELECT COUNT(*) FROM deadlines WHERE deleted_at IS NULL AND status <> 'renewed'` (senão 0). `lastChangeAt` = maior `updated_at` entre `companies` e (v ≥ 2) `deadlines`, `DateTime.parse` (texto ISO, D008); null se não houver linha.
6. Arquivo inexistente ou ilegível → `failed`.

**restore(path)** — a UI impede chamadas simultâneas com o diálogo de progresso bloqueante; o serviço ainda lança `StateError` se `restore`/`undoRestore` for chamado com outra em curso:
1. `await inspect(path)` (propaga a falha; nada mudou).
2. Cópia de segurança: apagar `antes-da-restauracao.ntbackup` se existir; `VACUUM INTO` nele a partir do banco atual. Falha → `failed` (nada mudou).
3. `await database().close()`.
4. `dbPath = databasePath()`: apagar `dbPath-wal`, `dbPath-shm`, `dbPath-journal` se existirem; copiar `path` para `dbPath.tmp` e renomear para `dbPath`.
5. `await reopen()`; forçar a abertura e a migração: `await database().customSelect('SELECT COUNT(*) FROM companies').get()`.
6. Se 3–5 falharem: `database().close()` (ignorar erro), repetir o passo 4 com a cópia de segurança, `reopen()`, e lançar `BackupException(failed, e)`.
7. Apagar `path` (o arquivo escolhido) no fim, com sucesso ou falha.

**undoRestore()** — sem a cópia de segurança → `failed`. Senão, mover a cópia para `stagingPath()` e chamar `restore(staging)`: a nova cópia de segurança passa a ser a dos dados restaurados (desfazer de novo refaz).

**PlatformBackupFiles**
- `share`: `SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/octet-stream', name: file.name)], fileNameOverrides: [file.name], subject: file.name))`; devolve `status == ShareResultStatus.success`. **[suposição]** `unavailable` (aparelho não informa) conta como não feito: o aviso continua até um compartilhamento confirmado. Limite conhecido: `success` significa que a pessoa escolheu um app, não que o envio terminou.
- `pick`: `FilePicker.pickFile(type: FileType.any)` (sem filtro de extensão: `.ntbackup` não tem MIME e o filtro do Android recusaria; quem valida é o `inspect`); null → `false`; `await file.xFile.saveTo(destinationPath)`; `FilePicker.clearTemporaryFiles()` num `try` ignorado; `true`.

**SharedPrefsBackupSettings** — chave `backup.last_at`, ISO UTC; leitura inválida → null.

**LastBackupAtNotifier** — `build()` lê `backupSettingsProvider.lastBackupAt()`; `record(DateTime at)` grava e atualiza o estado. A restauração não muda a data (é preferência do aparelho).

**Fluxo "Fazer backup"** (BackupSection): `showProgressDialog(context, 'Gerando backup…', service.create())` → `files.share(file)` → se `true`, `lastBackupAt.record(clock())` e SnackBar "Backup feito". `BackupException` → SnackBar "Não foi possível fazer o backup.".

**Fluxo "Restaurar backup"**:
1. `staging = await service.stagingPath()`; `if (!await files.pick(staging)) return;`
2. `summary = await showProgressDialog(context, 'Conferindo o arquivo…', service.inspect(staging))`; falha → SnackBar com a mensagem da tabela.
3. `showConfirmDialog(title: 'Restaurar backup?', message: …, confirmLabel: 'Restaurar', destructive: true)`. Mensagem: "Os dados atuais serão substituídos pelos do arquivo: {n} empresa(s) e {m} prazo(s), com última alteração em {DD/MM/AAAA}. Os dados atuais ficam guardados neste aparelho até a próxima restauração." Sem `lastChangeAt`: "…{n} empresas e {m} prazos." Plural: "1 empresa"/"2 empresas", "1 prazo"/"0 prazos". Cancelar → fim.
4. `showProgressDialog(context, 'Restaurando…', service.restore(staging))`; falha → SnackBar com a mensagem.
5. Sucesso → SnackBar "Backup restaurado" com ação "Desfazer" (`persist: false`, `duration: 10 s`). Desfazer → `showProgressDialog('Desfazendo…', service.undoRestore())` → SnackBar "Dados anteriores de volta" ou "Não foi possível desfazer.".

**Navegação depois de restaurar** — as pilhas das outras abas podem apontar para empresas/prazos que não existem no backup. As telas de detalhe já tratam `null` (registro inexistente) como nas exclusões. **[suposição]** não resetar as pilhas; conferir no emulador e registrar.

## Interface

Ajustes (`SettingsScreen`), de cima para baixo, seguindo o wireframe:

1. `BackupNotice` — só quando `lastBackupAt` carregou e é `null`: `NoticeBanner(tone: StatusTone.dueSoon, icon: Icons.warning_amber_rounded, message: 'Os dados ficam só neste aparelho.', emphasis: 'Nenhum backup feito ainda.')`.
2. `SectionCard(title: 'Backup')`:
   - `NavRow(leadingIcon: Icons.upload_outlined, title: 'Fazer backup', subtitle: lastBackupAt == null ? 'Exporta um arquivo com todos os dados' : 'Último backup em DD/MM/AAAA')`.
   - `NavRow(leadingIcon: Icons.download_outlined, title: 'Restaurar backup', subtitle: 'Substitui os dados atuais')`.
3. `SectionCard(title: 'Alertas')` — como hoje.

Sem `FilledButton` na tela (nenhuma ação primária). A restauração é destrutiva: confirmação com o botão vermelho (`destructive: true`). Datas com `formatDate` em algarismos tabulares (o `NavRow` usa o estilo do tema; o subtítulo com data usa `AppTypography.tabular` se o `NavRow` aceitar estilo; senão manter o texto padrão e registrar).

Componentes novos em `lib/app/widgets/`:

- `NoticeBanner({required StatusTone tone, required IconData icon, required String message, String? emphasis})`: `Container` com o fundo suave do tom (`StatusColors.of(context).resolve(tone).background`), `AppRadius.lgAll` e padding `AppSpacing.md`; `Row` com o ícone (cor forte, alinhado ao topo) e, após `AppSpacing.sm`, um `Text.rich`: `message` em `textTheme.bodyMedium` e `emphasis` (precedida de espaço) em `textTheme.labelMedium` (mesmo tamanho e altura, peso 600), ambos na cor forte do tom. Sem altura fixa (cresce com a fonte do sistema). `Semantics(container: true, label: 'message emphasis', excludeSemantics: true)`.
- `Future<T> showProgressDialog<T>(BuildContext context, String label, Future<T> future)`: diálogo não dispensável (`barrierDismissible: false`, `PopScope(canPop: false)`) com `CircularProgressIndicator` e o rótulo; fecha quando a `future` termina (sucesso ou erro) e devolve/propaga o resultado.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/core/database/app_database_reopen_test.dart` | `close()` duas vezes não lança; `reopen()` faz o `appDatabaseProvider` devolver outra instância e fechar a antiga (opener sobrescrito com `NativeDatabase` em arquivo temporário); os providers de repositório e um `StreamProvider` (`companiesProvider`) passam a ler o banco novo |
| `test/features/backup/domain/backup_test.dart` | `backupFileName(DateTime(2026, 11, 26, 14, 5))` = `NormaTrack-backup-2026-11-26-1405.ntbackup` |
| `test/features/backup/data/local_backup_service_test.dart` | com `Directory.systemTemp.createTempSync()` e `AppDatabase(NativeDatabase(File(...)))`: `create()` gera arquivo com nome datado que o `inspect` aceita, com contagens certas (2 empresas, sendo 1 arquivada; 1 excluída não conta; 1 prazo renovado + 1 ciclo atual = 1); arquivo de bytes aleatórios → `notABackup`; SQLite de outro app (tabela `foo`, `user_version` 1) → `notABackup`; `user_version` 3 → `newerVersion`; banco v1 (via `SchemaVerifier.schemaAt(1)` + `VACUUM INTO`) aceito com `deadlineCount` 0 e, ao restaurar, migrado para v2 (tabela `deadlines` existe e a empresa continua); `restore` troca os dados (A → B) e `undoRestore` volta (B → A); falha na reabertura (abridor que lança na 1ª vez) → `failed` e os dados A continuam; `inspect` falhando não cria cópia de segurança nem fecha o banco; arquivo escolhido apagado no fim |
| `test/features/backup/data/shared_prefs_backup_settings_test.dart` | grava e lê a data (UTC); sem valor → null (com `SharedPreferencesAsyncPlatform` em memória, como em `notification_settings` da task 010) |
| `test/app/widgets/notice_banner_test.dart` | mostra mensagem e ênfase, ícone, cor de fundo do tom; semântica com o texto inteiro |
| `test/app/widgets/progress_dialog_test.dart` | mostra o rótulo enquanto a `future` corre, fecha ao terminar e devolve o valor; com erro, fecha e propaga; voltar não fecha |
| `test/features/settings/presentation/settings_backup_test.dart` | com fakes (`FakeBackupService`, `FakeBackupFiles`, `FakeBackupSettings` em `test/helpers/`): aviso aparece sem backup; "Fazer backup" compartilha, grava a data e troca o subtítulo para "Último backup em 29/09/2026" e o aviso some; fechar a folha não grava; erro → SnackBar; restaurar cancelado no seletor não chama `inspect`; `inspect` com falha mostra a mensagem certa (as 4); confirmação mostra contagens, plural e data; cancelar não chama `restore`; confirmar chama `restore` e mostra "Backup restaurado"; "Desfazer" chama `undoRestore` |
| `test/helpers/pump_app.dart` | sobrescrever os três providers de backup com fakes, para os testes do app inteiro que abrem Ajustes |

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze`, `flutter test` e `flutter build apk --debug` sem erros.
- No emulador `Medium_Phone_API_37.0` (sem `pm clear`, sem desinstalar; instalar com `flutter run -d emulator-5554` ou `flutter install` mantendo os dados):
  1. **Antes de tudo**, salvar uma cópia dos dados atuais no Mac: `adb exec-out run-as br.com.normatrack.app cat app_flutter/normatrack.sqlite > <scratchpad>/emulador-antes.sqlite` (e `-wal` se existir) e conferir que abre e tem a empresa "Alfa To To To To".
  2. Ajustes mostra o aviso; "Fazer backup" abre a folha; salvar em Arquivos/Drive (ou outro destino disponível); o subtítulo vira "Último backup em …".
  3. Preparar um backup diferente no Mac (cópia do arquivo do passo 1 com uma empresa "Restaurada Teste" inserida pelo `sqlite3`), `adb push` para `/sdcard/Download/`, restaurar pelo app: confirmação com as contagens, Painel e Empresas mostram a empresa nova sem reiniciar; `adb shell dumpsys alarm` mostra os agendamentos refeitos.
  4. "Desfazer" (ou restaurar o backup do passo 2) volta aos dados de teste do emulador; conferir "Alfa To To To To" e os prazos.
  5. Arquivo qualquer (ex.: um `.txt`) e um backup com `user_version` 3 → mensagens de recusa, dados intactos.
- Se algo der errado no emulador, voltar com o arquivo do passo 1 (`adb push` + `run-as cp` com o app parado).

## Riscos e alternativas

- **[suposição]** Compartilhamento `unavailable` não conta como backup feito; `success` só garante que um destino foi escolhido (C25).
- **[suposição]** Só a cópia de segurança mais recente é guardada, apagada na restauração seguinte (C25).
- **[suposição]** O resumo conta empresas não excluídas (arquivadas incluídas) e prazos em ciclo atual (não renovados, não excluídos) (C25).
- **[suposição]** As pilhas de navegação das outras abas não são resetadas após restaurar.
- Risco: algum widget ler o banco no intervalo entre fechar e reabrir (milissegundos) e mostrar erro. Mitigação: diálogo de progresso bloqueante; os providers se reconstroem com a nova época.
- Risco: plugins com Kotlin e AGP 9. Mitigação: build no passo 1.
- *Descartado:* exportação JSON (manutenção a cada tabela nova, mais risco); copiar o arquivo `.sqlite` direto (inconsistente com o banco aberto/WAL); reiniciar o app após restaurar (não há API no Android sem plugin e a experiência é pior); escolher pasta com `FilePicker.saveFile` (o compartilhamento já cobre Drive e Arquivos); filtro de extensão no seletor (o Android não conhece o MIME de `.ntbackup`).

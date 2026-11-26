import 'package:meta/meta.dart';

/// Extensão dos arquivos de backup (cópia do banco SQLite, RNF-04).
const backupExtension = 'ntbackup';

/// `NormaTrack-backup-AAAA-MM-DD-HHMM.ntbackup`, com a hora local de [local].
String backupFileName(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  final date =
      '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)}';
  return 'NormaTrack-backup-$date-${two(local.hour)}${two(local.minute)}'
      '.$backupExtension';
}

/// Resumo de um arquivo de backup, mostrado na confirmação da restauração.
@immutable
class BackupSummary {
  const BackupSummary({
    required this.schemaVersion,
    required this.companyCount,
    required this.deadlineCount,
    this.lastChangeAt,
  });

  final int schemaVersion;

  // TODO(RNF-04): suposição (C25) — empresas não excluídas, arquivadas
  // incluídas; prazos no ciclo atual (não renovados, não excluídos).
  final int companyCount;
  final int deadlineCount;

  /// Maior `updatedAt` de empresas e prazos, em UTC; `null` sem registros.
  final DateTime? lastChangeAt;

  @override
  bool operator ==(Object other) =>
      other is BackupSummary &&
      other.schemaVersion == schemaVersion &&
      other.companyCount == companyCount &&
      other.deadlineCount == deadlineCount &&
      other.lastChangeAt == lastChangeAt;

  @override
  int get hashCode =>
      Object.hash(schemaVersion, companyCount, deadlineCount, lastChangeAt);

  @override
  String toString() =>
      'BackupSummary(v$schemaVersion, $companyCount empresas, '
      '$deadlineCount prazos, $lastChangeAt)';
}

/// Por que um backup não pôde ser feito ou restaurado.
enum BackupFailure {
  /// Não é SQLite, ou não tem as tabelas do NormaTrack.
  notABackup,

  /// Schema mais novo que o deste app.
  newerVersion,

  /// SQLite danificado (`quick_check` falhou).
  corrupted,

  /// Erro de arquivo ou ao abrir o banco restaurado.
  failed,
}

class BackupException implements Exception {
  const BackupException(this.failure, [this.cause]);

  final BackupFailure failure;
  final Object? cause;

  @override
  String toString() => 'BackupException(${failure.name}, $cause)';
}

/// Arquivo gerado por [BackupService.create].
@immutable
class BackupFile {
  const BackupFile({required this.path, required this.name});

  final String path;
  final String name;
}

/// Cópia e restauração do banco local.
abstract interface class BackupService {
  /// Gera o backup do banco aberto. Lança [BackupException] (`failed`).
  Future<BackupFile> create();

  /// Onde copiar o arquivo escolhido antes de [inspect] e [restore].
  Future<String> stagingPath();

  /// Valida o arquivo em [path] sem alterá-lo. Lança [BackupException].
  Future<BackupSummary> inspect(String path);

  /// Substitui os dados pelos de [path], guardando antes uma cópia dos dados
  /// atuais. Em erro, os dados atuais ficam como estavam e lança
  /// [BackupException]. O arquivo em [path] é apagado no fim.
  Future<void> restore(String path);

  /// Volta aos dados de antes da última restauração. Lança
  /// [BackupException] (`failed`) se não houver cópia.
  Future<void> undoRestore();
}

/// Entrada e saída de arquivos pelo sistema.
abstract interface class BackupFiles {
  /// Abre a folha de compartilhamento. `true` se a pessoa escolheu um destino.
  Future<bool> share(BackupFile file);

  /// Abre o seletor e copia o arquivo escolhido para [destinationPath].
  /// `false` se a pessoa cancelou.
  Future<bool> pick(String destinationPath);
}

/// Preferências do aparelho sobre backup. Ficam fora do banco (D013) e,
/// portanto, fora do próprio backup.
abstract interface class BackupSettings {
  Future<DateTime?> lastBackupAt();
  Future<void> setLastBackupAt(DateTime at);
}

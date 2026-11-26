import 'package:normatrack/features/backup/domain/backup.dart';

/// Serviço de backup em memória: registra as chamadas e devolve o que o teste
/// configurar.
class FakeBackupService implements BackupService {
  BackupSummary summary = const BackupSummary(
    schemaVersion: 2,
    companyCount: 0,
    deadlineCount: 0,
  );
  BackupFailure? createFailure;
  BackupFailure? inspectFailure;
  BackupFailure? restoreFailure;
  BackupFailure? undoFailure;

  int createCalls = 0;
  final inspected = <String>[];
  final restored = <String>[];
  int undoCalls = 0;

  static const staging = '/fake/restaurar.ntbackup';

  @override
  Future<BackupFile> create() async {
    createCalls++;
    if (createFailure case final f?) throw BackupException(f);
    return const BackupFile(
      path: '/fake/NormaTrack-backup.ntbackup',
      name: 'NormaTrack-backup.ntbackup',
    );
  }

  @override
  Future<String> stagingPath() async => staging;

  @override
  Future<BackupSummary> inspect(String path) async {
    inspected.add(path);
    if (inspectFailure case final f?) throw BackupException(f);
    return summary;
  }

  @override
  Future<void> restore(String path) async {
    restored.add(path);
    if (restoreFailure case final f?) throw BackupException(f);
  }

  @override
  Future<void> undoRestore() async {
    undoCalls++;
    if (undoFailure case final f?) throw BackupException(f);
  }
}

/// Folha de compartilhamento e seletor falsos.
class FakeBackupFiles implements BackupFiles {
  bool shareResult = true;
  bool pickResult = true;
  final shared = <BackupFile>[];
  final picked = <String>[];

  @override
  Future<bool> share(BackupFile file) async {
    shared.add(file);
    return shareResult;
  }

  @override
  Future<bool> pick(String destinationPath) async {
    picked.add(destinationPath);
    return pickResult;
  }
}

class FakeBackupSettings implements BackupSettings {
  FakeBackupSettings({this.lastAt});

  DateTime? lastAt;

  @override
  Future<DateTime?> lastBackupAt() async => lastAt;

  @override
  Future<void> setLastBackupAt(DateTime at) async => lastAt = at;
}

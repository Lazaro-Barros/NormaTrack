import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/clock.dart';
import '../domain/backup.dart';

/// A UI depende só do tipo [BackupService].
final backupServiceProvider = Provider<BackupService>(
  (ref) => LocalBackupService(
    database: () => ref.read(appDatabaseProvider),
    reopen: () async => ref.read(databaseEpochProvider.notifier).reopen(),
    databasePath: ref.watch(databasePathProvider),
    workDirectory: () async =>
        p.join((await getApplicationSupportDirectory()).path, 'backup'),
    exportDirectory: () async =>
        p.join((await getTemporaryDirectory()).path, 'backup'),
    clock: ref.watch(clockProvider),
  ),
);

/// Tabelas que um backup precisa ter em cada versão do schema.
const _tablesByVersion = {
  1: ['companies', 'company_modules', 'company_authorities'],
  2: ['deadlines', 'deadline_reminders'],
};

/// Backup e restauração do banco SQLite local (RNF-04): o backup é uma cópia
/// consistente feita com `VACUUM INTO`; restaurar fecha o banco, troca o
/// arquivo e reabre (o que roda as migrações de um backup mais antigo).
class LocalBackupService implements BackupService {
  LocalBackupService({
    required this._database,
    required this._reopen,
    required this._databasePath,
    required this._workDirectory,
    required this._exportDirectory,
    required this._clock,
  });

  static const stagingName = 'restaurar.$backupExtension';

  // TODO(RNF-04): suposição (C25) — só a cópia de segurança mais recente.
  static const safetyName = 'antes-da-restauracao.$backupExtension';

  final AppDatabase Function() _database;
  final Future<void> Function() _reopen;
  final Future<String> Function() _databasePath;
  final Future<String> Function() _workDirectory;
  final Future<String> Function() _exportDirectory;
  final Clock _clock;

  bool _busy = false;

  Future<String> _work(String name) async {
    final dir = Directory(await _workDirectory());
    await dir.create(recursive: true);
    return p.join(dir.path, name);
  }

  @override
  Future<String> stagingPath() => _work(stagingName);

  @override
  Future<BackupFile> create() async {
    try {
      final dir = Directory(await _exportDirectory());
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
      final name = backupFileName(_clock().toLocal());
      final path = p.join(dir.path, name);
      await _vacuumInto(path);
      return BackupFile(path: path, name: name);
    } on Object catch (e) {
      throw BackupException(BackupFailure.failed, e);
    }
  }

  Future<void> _vacuumInto(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
    await _database().customStatement('VACUUM INTO ?', [path]);
  }

  @override
  Future<BackupSummary> inspect(String path) async {
    if (!await File(path).exists()) {
      throw const BackupException(BackupFailure.failed);
    }
    return _inspect(path);
  }

  BackupSummary _inspect(String path) {
    final Database db;
    try {
      db = sqlite3.open(path, mode: OpenMode.readOnly);
    } on SqliteException catch (e) {
      throw BackupException(BackupFailure.notABackup, e);
    }
    try {
      final int version;
      try {
        version = db.select('PRAGMA user_version').first.columnAt(0) as int;
      } on SqliteException catch (e) {
        // "file is not a database" e afins.
        throw BackupException(BackupFailure.notABackup, e);
      }
      if (version <= 0) throw const BackupException(BackupFailure.notABackup);
      if (version > AppDatabase.currentSchemaVersion) {
        throw const BackupException(BackupFailure.newerVersion);
      }
      final tables = {
        for (final row in db.select(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        ))
          row['name'] as String,
      };
      final required = [
        for (final MapEntry(:key, :value) in _tablesByVersion.entries)
          if (key <= version) ...value,
      ];
      if (!tables.containsAll(required)) {
        throw const BackupException(BackupFailure.notABackup);
      }
      if (db.select('PRAGMA quick_check').first.columnAt(0) != 'ok') {
        throw const BackupException(BackupFailure.corrupted);
      }
      final hasDeadlines = version >= 2;
      int count(String sql) => db.select(sql).first.columnAt(0) as int;
      final last =
          db
                  .select(
                    'SELECT MAX(at) FROM ('
                    'SELECT MAX(updated_at) AS at FROM companies'
                    '${hasDeadlines ? ' UNION ALL SELECT MAX(updated_at) FROM deadlines' : ''}'
                    ')',
                  )
                  .first
                  .columnAt(0)
              as String?;
      return BackupSummary(
        schemaVersion: version,
        companyCount: count(
          'SELECT COUNT(*) FROM companies WHERE deleted_at IS NULL',
        ),
        deadlineCount: hasDeadlines
            ? count(
                'SELECT COUNT(*) FROM deadlines '
                "WHERE deleted_at IS NULL AND status <> 'renewed'",
              )
            : 0,
        lastChangeAt: last == null ? null : DateTime.tryParse(last)?.toUtc(),
      );
    } on SqliteException catch (e) {
      throw BackupException(BackupFailure.corrupted, e);
    } finally {
      db.close();
    }
  }

  @override
  Future<void> restore(String path) => _exclusive(() async {
    try {
      await _restore(path);
    } finally {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  });

  @override
  Future<void> undoRestore() => _exclusive(() async {
    final safety = File(await _work(safetyName));
    if (!await safety.exists()) {
      throw const BackupException(BackupFailure.failed);
    }
    final staging = await safety.rename(await stagingPath());
    try {
      await _restore(staging.path);
      await staging.delete();
    } on Object {
      // Mantém os dados de antes desfazíveis numa próxima tentativa.
      if (await staging.exists()) await staging.rename(safety.path);
      rethrow;
    }
  });

  Future<T> _exclusive<T>(Future<T> Function() body) async {
    if (_busy) throw StateError('Restauração já em andamento');
    _busy = true;
    try {
      return await body();
    } finally {
      _busy = false;
    }
  }

  /// Não apaga [path]: quem chama decide.
  Future<void> _restore(String path) async {
    await inspect(path);
    final safety = await _work(safetyName);
    try {
      await _vacuumInto(safety);
    } on Object catch (e) {
      throw BackupException(BackupFailure.failed, e);
    }
    try {
      await _swapIn(path);
    } on Object catch (e) {
      try {
        await _swapIn(safety, ignoreCloseErrors: true);
      } on Object {
        // Sem volta possível agora; a cópia de segurança continua no disco.
      }
      throw BackupException(BackupFailure.failed, e);
    }
  }

  /// Fecha o banco, põe [source] no lugar do arquivo e reabre, forçando a
  /// abertura (e as migrações) com uma consulta.
  Future<void> _swapIn(String source, {bool ignoreCloseErrors = false}) async {
    try {
      await _database().close();
    } on Object {
      if (!ignoreCloseErrors) rethrow;
    }
    final dbPath = await _databasePath();
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final file = File('$dbPath$suffix');
      if (await file.exists()) await file.delete();
    }
    final tmp = await File(source).copy('$dbPath.tmp');
    await tmp.rename(dbPath);
    await _reopen();
    await _database().customSelect('SELECT COUNT(*) FROM companies').get();
  }
}

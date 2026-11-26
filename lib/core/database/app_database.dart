import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/companies/data/company_tables.dart';
import '../../features/deadlines/data/deadline_tables.dart';
import 'app_database.steps.dart';
import 'converters.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Companies,
    CompanyModules,
    CompanyAuthorities,
    Deadlines,
    DeadlineReminders,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Versão do schema deste app. Backups com versão maior são recusados.
  static const currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  Future<void>? _closing;

  /// Idempotente: a restauração fecha o banco antes de trocar o arquivo, e o
  /// `onDispose` do provider fecha de novo.
  @override
  Future<void> close() => _closing ??= super.close();

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      // Task 006: prazos e lembretes.
      from1To2: (m, schema) async {
        await m.createTable(schema.deadlines);
        await m.createTable(schema.deadlineReminders);
        await m.createIndex(schema.deadlinesCompanyDue);
        await m.createIndex(schema.deadlinesStatusDue);
        await m.createIndex(schema.deadlinesPreviousLive);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Nome do arquivo do banco, na pasta de documentos do app.
const databaseFileName = 'normatrack.sqlite';

/// Caminho do banco: o mesmo que o `driftDatabase(name: 'normatrack')` usa por
/// padrão, explícito para a restauração (RNF-04) poder trocar o arquivo.
Future<String> appDatabasePath() async =>
    p.join((await getApplicationDocumentsDirectory()).path, databaseFileName);

/// Caminho do banco. Sobrescrito nos testes.
final databasePathProvider = Provider<Future<String> Function()>(
  (ref) => appDatabasePath,
);

/// Abre um [AppDatabase] novo. Sobrescrito nos testes.
final databaseOpenerProvider = Provider<AppDatabase Function()>((ref) {
  final path = ref.watch(databasePathProvider);
  return () => AppDatabase(
    driftDatabase(
      name: 'normatrack',
      native: DriftNativeOptions(databasePath: path),
    ),
  );
});

/// "Época" do banco: cada [DatabaseEpoch.reopen] faz o [appDatabaseProvider]
/// abrir um banco novo, e tudo que depende dele (repositórios, telas,
/// notificações) se reconstrói. Usado depois de restaurar um backup.
final databaseEpochProvider = NotifierProvider<DatabaseEpoch, int>(
  DatabaseEpoch.new,
);

class DatabaseEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void reopen() => state++;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(databaseEpochProvider);
  final db = ref.watch(databaseOpenerProvider)();
  ref.onDispose(db.close);
  return db;
});

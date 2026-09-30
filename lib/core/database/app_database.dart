import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  int get schemaVersion => 2;

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

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'normatrack'));
  ref.onDispose(db.close);
  return db;
});

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';

// Testes do schema além das migrações (`app/migration_test.dart`, gerado pelo
// `make-migrations`): o schema criado pelo app bate com o código, e os índices
// parciais e as FKs existem.
void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('banco novo bate com o código gerado', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.validateDatabaseSchema();
  });

  test('cria os índices parciais e liga as foreign keys', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    for (final name in [
      'companies_cnpj_active',
      'deadlines_company_due',
      'deadlines_status_due',
      'deadlines_previous_live',
    ]) {
      final index = await db
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE name = ?',
            variables: [Variable.withString(name)],
          )
          .getSingle();
      expect(index.read<String>('sql'), contains('WHERE'), reason: name);
    }

    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.read<int>('foreign_keys'), 1);
  });
}

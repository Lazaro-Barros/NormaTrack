import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';

import 'generated/schema.dart';

// `make-migrations` só gera testes de migração a partir de duas versões de
// schema. Enquanto só existe a v1, este teste garante que o schema criado pelo
// app bate com `drift_schemas/app/drift_schema_v1.json`.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('schema v1 bate com o dump', () async {
    final db = AppDatabase(await verifier.startAt(1));
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
  });

  test('banco novo bate com o código gerado', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.validateDatabaseSchema();
  });

  test('cria o índice único de CNPJ e liga as foreign keys', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final index = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name = 'companies_cnpj_active'",
        )
        .getSingle();
    expect(index.read<String>('sql'), contains('WHERE'));

    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.read<int>('foreign_keys'), 1);
  });
}

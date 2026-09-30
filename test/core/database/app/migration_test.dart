// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // A v2 só cria tabelas; este teste garante que empresas, módulos e
  // registros gravados na v1 continuam iguais depois da migração.
  test('migration from v1 to v2 does not corrupt data', () async {
    const at = '2026-01-01T00:00:00.000Z';
    final oldCompaniesData = [
      const v1.CompaniesData(
        id: 'c1',
        createdAt: at,
        updatedAt: at,
        legalName: 'Indústria Alfa Ltda',
        cnpj: '11222333000181',
      ),
    ];
    final expectedNewCompaniesData = [
      const v2.CompaniesData(
        id: 'c1',
        createdAt: at,
        updatedAt: at,
        legalName: 'Indústria Alfa Ltda',
        cnpj: '11222333000181',
      ),
    ];

    final oldCompanyModulesData = [
      const v1.CompanyModulesData(
        id: 'm1',
        createdAt: at,
        updatedAt: at,
        companyId: 'c1',
        moduleType: 'environmental',
        enabled: 1,
      ),
    ];
    final expectedNewCompanyModulesData = [
      const v2.CompanyModulesData(
        id: 'm1',
        createdAt: at,
        updatedAt: at,
        companyId: 'c1',
        moduleType: 'environmental',
        enabled: 1,
      ),
    ];

    final oldCompanyAuthoritiesData = [
      const v1.CompanyAuthoritiesData(
        id: 'a1',
        createdAt: at,
        updatedAt: at,
        companyId: 'c1',
        authority: 'semace',
        status: 'registered',
        validUntil: '2027-03-31',
      ),
    ];
    final expectedNewCompanyAuthoritiesData = [
      const v2.CompanyAuthoritiesData(
        id: 'a1',
        createdAt: at,
        updatedAt: at,
        companyId: 'c1',
        authority: 'semace',
        status: 'registered',
        validUntil: '2027-03-31',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.companies, oldCompaniesData);
        batch.insertAll(oldDb.companyModules, oldCompanyModulesData);
        batch.insertAll(oldDb.companyAuthorities, oldCompanyAuthoritiesData);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.deadlines).get(), isEmpty);
        expect(
          expectedNewCompaniesData,
          await newDb.select(newDb.companies).get(),
        );
        expect(
          expectedNewCompanyModulesData,
          await newDb.select(newDb.companyModules).get(),
        );
        expect(
          expectedNewCompanyAuthoritiesData,
          await newDb.select(newDb.companyAuthorities).get(),
        );
      },
    );
  });
}

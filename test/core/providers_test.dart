import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';

void main() {
  test(
    'companyRepositoryProvider usa banco, relógio e ids injetados',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 1, 1)),
          idGeneratorProvider.overrideWithValue(() => 'id-fixo'),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final company = await container
          .read(companyRepositoryProvider)
          .create(const CompanyInput(legalName: 'Alfa'));

      expect(company.id, 'id-fixo');
      expect(company.createdAt, DateTime.utc(2026, 1, 1));
    },
  );

  test('idGeneratorProvider padrão gera UUID v7', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final id = container.read(idGeneratorProvider)();
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-')));
    expect(container.read(clockProvider)().isUtc, isTrue);
  });
}

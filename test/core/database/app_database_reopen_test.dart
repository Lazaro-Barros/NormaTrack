import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/database/app_database.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_repository.dart';
import 'package:normatrack/features/companies/presentation/company_providers.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('close() duas vezes não lança', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    await db.close();
    await db.close();
  });

  test('reopen() abre um banco novo, fecha o antigo e reconstrói os '
      'dependentes', () async {
    final dir = Directory.systemTemp.createTempSync('normatrack_reopen');
    addTearDown(() => dir.deleteSync(recursive: true));
    var file = File('${dir.path}/a.sqlite');
    final opened = <AppDatabase>[];
    final container = ProviderContainer(
      overrides: [
        databaseOpenerProvider.overrideWithValue(() {
          final db = AppDatabase(NativeDatabase(file));
          opened.add(db);
          return db;
        }),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 26)),
      ],
    );
    addTearDown(container.dispose);

    final names = <List<String>>[];
    final sub = container.listen(companiesProvider(const CompanyFilter()), (
      _,
      next,
    ) {
      final list = next.value;
      if (list != null) names.add([for (final c in list) c.legalName]);
    }, fireImmediately: true);
    addTearDown(sub.close);

    await container
        .read(companyRepositoryProvider)
        .create(const CompanyInput(legalName: 'Alfa'));
    await pumpEventQueue();
    expect(names.last, ['Alfa']);

    final first = container.read(appDatabaseProvider);
    file = File('${dir.path}/b.sqlite');
    container.read(databaseEpochProvider.notifier).reopen();
    final second = container.read(appDatabaseProvider);

    expect(identical(first, second), isFalse);
    expect(opened, hasLength(2));
    await pumpEventQueue();
    expect(names.last, isEmpty);
    // O antigo foi fechado pelo onDispose.
    await expectLater(first.customSelect('SELECT 1').get(), throwsA(anything));
  });
}

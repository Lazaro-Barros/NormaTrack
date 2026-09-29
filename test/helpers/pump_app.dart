import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/main.dart';

import 'fake_company_repository.dart';

/// "Hoje" nos testes: 29/09/2026 em qualquer fuso do Brasil.
final testNow = DateTime.utc(2026, 9, 29, 12);

/// Monta o app inteiro numa tela de 390 × 844, com relógio fixo e o
/// repositório em memória. Devolve o repositório usado.
Future<FakeCompanyRepository> pumpApp(
  WidgetTester tester, {
  FakeCompanyRepository? repository,
  String initialLocation = AppRoutes.dashboard,
}) async {
  final repo = repository ?? FakeCompanyRepository(now: testNow);
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        companyRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => testNow),
        routerProvider.overrideWith((ref) {
          final router = createAppRouter(initialLocation: initialLocation);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const NormaTrackApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

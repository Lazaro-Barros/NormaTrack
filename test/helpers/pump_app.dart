import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/core/providers.dart';
import 'package:normatrack/main.dart';

/// "Hoje" nos testes: 29/09/2026 em qualquer fuso do Brasil.
final testNow = DateTime.utc(2026, 9, 29, 12);

/// Monta o app inteiro numa tela de 390 × 844, com relógio fixo.
Future<void> pumpApp(
  WidgetTester tester, {
  List overrides = const [],
  String initialLocation = AppRoutes.dashboard,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => testNow),
        routerProvider.overrideWith((ref) {
          final router = createAppRouter(initialLocation: initialLocation);
          ref.onDispose(router.dispose);
          return router;
        }),
        ...overrides,
      ],
      child: const NormaTrackApp(),
    ),
  );
  await tester.pumpAndSettle();
}

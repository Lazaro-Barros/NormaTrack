import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'placeholder_screens.dart';
import 'widgets/band_title.dart';

abstract final class AppRoutes {
  static const dashboard = '/painel';
  static const companies = '/empresas';
  static const newCompany = '/empresas/nova';
  static String company(String id) => '/empresas/$id';
  static String editCompany(String id) => '/empresas/$id/editar';
  static const settings = '/ajustes';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Barra inferior com três ramos. Telas internas usam o navigator raiz e
/// cobrem a barra.
GoRouter createAppRouter({String initialLocation = AppRoutes.dashboard}) {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.companies,
                builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    title: const BandTitle(title: 'Empresas', large: true),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/companies/presentation/company_detail_screen.dart';
import '../features/companies/presentation/company_form_screen.dart';
import '../features/companies/presentation/company_list_screen.dart';
import 'app_shell.dart';
import 'placeholder_screens.dart';

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
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        navigatorContainerBuilder: (context, shell, branches) =>
            AppShell(shell: shell, branches: branches),
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
                builder: (context, state) => const CompanyListScreen(),
                // `nova` antes de `:id`. No navigator raiz: cobrem a barra.
                routes: [
                  GoRoute(
                    path: 'nova',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const CompanyFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => CompanyDetailScreen(
                      companyId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        parentNavigatorKey: rootKey,
                        builder: (context, state) => CompanyFormScreen(
                          companyId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
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

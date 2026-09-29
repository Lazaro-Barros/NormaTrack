import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';

/// Telas da barra inferior: Painel, Empresas e Ajustes.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              label: 'Painel',
            ),
            NavigationDestination(
              icon: Icon(Icons.apartment_outlined),
              label: 'Empresas',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

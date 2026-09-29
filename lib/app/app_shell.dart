import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';

/// Telas da barra inferior: Painel, Empresas e Ajustes. É o
/// `navigatorContainerBuilder` do `StatefulShellRoute` (ver `router.dart`).
///
/// Sem `Scaffold` próprio: com dois `Scaffold`s aninhados, o SnackBar aparece
/// só no de fora, que não tem o FAB da tela, e o cobre. Assim o `Scaffold` de
/// cada tela é o raiz e posiciona o SnackBar acima do próprio FAB.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell, required this.branches});

  final StatefulNavigationShell shell;

  /// Um navigator por ramo, na ordem da barra.
  final List<Widget> branches;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            // A barra já trata a área de gestos embaixo; as telas não.
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: _branches(),
            ),
          ),
          // Como no Scaffold: sem o padding da barra de status, que o
          // SafeArea da NavigationBar aplicaria em cima dela.
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ClipRRect(
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
          ),
        ],
      ),
    );
  }

  /// Como o `IndexedStack` do `go_router`, com `HeroMode` desligado nos ramos
  /// fora da tela. Cada ramo visitado continua montado e o `Scaffold` dele
  /// também mostra o SnackBar; sem isso, o SnackBar vira Hero repetido na
  /// transição de volta de uma tela interna.
  Widget _branches() => IndexedStack(
    index: shell.currentIndex,
    children: [
      for (var i = 0; i < branches.length; i++)
        Offstage(
          offstage: i != shell.currentIndex,
          child: TickerMode(
            enabled: i == shell.currentIndex,
            child: HeroMode(
              enabled: i == shell.currentIndex,
              child: branches[i],
            ),
          ),
        ),
    ],
  );
}

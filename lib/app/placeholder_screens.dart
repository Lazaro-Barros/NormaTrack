import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'widgets/band_title.dart';
import 'widgets/empty_state.dart';

// TODO(RF-PRZ-05): Painel com contagem por situação e próximos vencimentos.
class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BandTitle(title: 'Painel', large: true)),
      body: EmptyState(
        icon: Icons.space_dashboard_outlined,
        title: 'Painel em construção',
        message:
            'Os próximos vencimentos aparecem aqui quando os prazos forem '
            'cadastrados.',
        actionLabel: 'Ver empresas',
        onAction: () => context.go(AppRoutes.companies),
      ),
    );
  }
}

// TODO(RF-PRZ-03): Ajustes com notificações, antecedência padrão e backup.
class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BandTitle(title: 'Ajustes', large: true)),
      body: const EmptyState(
        icon: Icons.settings_outlined,
        title: 'Ajustes em construção',
        message: 'Notificações, antecedência padrão e backup ficam aqui.',
      ),
    );
  }
}

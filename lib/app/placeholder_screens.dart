import 'package:flutter/material.dart';

import 'widgets/band_title.dart';
import 'widgets/empty_state.dart';

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

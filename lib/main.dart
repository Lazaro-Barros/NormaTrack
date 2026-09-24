import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(const NormaTrackApp());
}

class NormaTrackApp extends StatelessWidget {
  const NormaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NormaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const _HomePlaceholder(),
    );
  }
}

// TODO(RF-PRZ-05): substituir pelo Painel quando as rotas forem criadas.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NormaTrack')),
      body: const Center(child: Text('Painel')),
    );
  }
}

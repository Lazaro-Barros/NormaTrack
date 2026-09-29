import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rodapé das telas internas, no lugar da barra inferior. Usar em
/// `Scaffold.bottomNavigationBar`. Sobe junto com o teclado, para a ação
/// principal continuar visível enquanto se digita.
class AppActionBar extends StatelessWidget {
  const AppActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // O Scaffold não levanta o bottomNavigationBar com o teclado. Com o
    // padding, a altura da barra inclui o teclado e o corpo termina acima dela.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

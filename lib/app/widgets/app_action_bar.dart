import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rodapé das telas internas, no lugar da barra inferior. Usar em
/// `Scaffold.bottomNavigationBar`.
class AppActionBar extends StatelessWidget {
  const AppActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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

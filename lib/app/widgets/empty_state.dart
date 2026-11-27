import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Lista ou tela sem conteúdo: explica o próximo passo e oferece a ação,
/// dentro de um card (onde o botão tonal tem contraste).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.inline = false,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel e onAction vêm juntos',
       );

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Só o card, sem centralizar nem rolar: para ficar dentro de uma lista
  /// junto de outras seções.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionLabel = this.actionLabel;
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
    if (inline) return card;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: card,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'status_chip.dart';

/// Situação em texto colorido com ícone, à direita de uma linha. Sem tom, é
/// só texto neutro (ex.: "Não se aplica").
class StatusText extends StatelessWidget {
  const StatusText({super.key, required this.label, this.tone});

  final String label;
  final StatusTone? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = this.tone;
    if (tone == null) {
      return Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final color = StatusColors.of(context).resolve(tone).foreground;
    return Semantics(
      label: 'Situação: $label',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(StatusChip.iconFor(tone), size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.tabular(theme.textTheme.labelMedium)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

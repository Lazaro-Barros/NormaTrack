import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'status_text.dart';

/// Lançamento periódico a fazer: ícone na cor suave da situação, título,
/// subtítulo (período), situação em texto com ícone e o botão tonal "Lançar".
/// O card não é tocável; a ação é só o botão.
class PendingRow extends StatelessWidget {
  const PendingRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.statusLabel,
    required this.tone,
    required this.onLaunch,
    this.actionLabel = 'Lançar',
  });

  /// Acima desta escala de fonte, o botão desce para baixo dos textos.
  static const stackedTextScale = 1.3;

  final IconData icon;
  final String title;
  final String? subtitle;
  final String statusLabel;
  final StatusTone tone;
  final VoidCallback onLaunch;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final style = StatusColors.of(context).resolve(tone);
    final subtitle = this.subtitle;
    final stacked =
        MediaQuery.textScalerOf(context).scale(16) > 16 * stackedTextScale;
    final button = FilledButton.tonal(
      onPressed: onLaunch,
      child: Text(actionLabel),
    );
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleSmall),
        if (subtitle != null) ...[
          Text(
            subtitle,
            style: AppTypography.tabular(text.bodySmall)
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        StatusText(label: statusLabel, tone: tone),
      ],
    );
    final row = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: style.foreground),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: texts),
        if (!stacked) ...[const SizedBox(width: AppSpacing.sm), button],
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  row,
                  const SizedBox(height: AppSpacing.sm),
                  button,
                ],
              )
            : row,
      ),
    );
  }
}

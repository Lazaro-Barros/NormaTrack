import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Situação de um prazo: ícone + texto sobre o fundo da situação.
/// Nunca representar situação só com cor.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.tone,
    required this.label,
    this.compact = false,
  });

  final StatusTone tone;
  final String label;
  final bool compact;

  static IconData iconFor(StatusTone tone) => switch (tone) {
    StatusTone.overdue => Icons.cancel_outlined,
    StatusTone.dueSoon => Icons.schedule_outlined,
    StatusTone.ok => Icons.check_circle_outline,
    StatusTone.closed => Icons.autorenew,
  };

  @override
  Widget build(BuildContext context) {
    final style = StatusColors.of(context).resolve(tone);
    return Semantics(
      label: 'Situação: $label',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.pillAll,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : 10,
            vertical: compact ? 2 : AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconFor(tone), size: 16, color: style.foreground),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: style.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

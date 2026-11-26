import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'status_chip.dart';

/// Contagem de uma situação na faixa do Painel: número grande e rótulo com o
/// ícone do tom, sobre a cor suave da situação. Tocar filtra; o selecionado
/// ganha um anel na cor forte (sem mudar o tamanho).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.tone,
    required this.count,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final StatusTone tone;
  final int count;

  /// Rótulo no plural, ex.: "Vencidos".
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Altura fixa, para uso em `AppBar.bottom`: 12 + 36 + 18 + 12.
  static const double height = 78;

  @override
  Widget build(BuildContext context) {
    final style = StatusColors.of(context).resolve(tone);
    final labelStyle = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: style.foreground);
    return Semantics(
      button: true,
      selected: selected,
      label: '$count $label',
      excludeSemantics: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.lgAll,
        ),
        foregroundDecoration: selected
            ? BoxDecoration(
                borderRadius: AppRadius.lgAll,
                border: Border.all(width: 2, color: style.foreground),
              )
            : null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.lgAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    maxLines: 1,
                    style: AppTypography.number.copyWith(
                      color: style.foreground,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        StatusChip.iconFor(tone),
                        size: 16,
                        color: style.foreground,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

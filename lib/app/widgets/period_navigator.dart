import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Navegação entre períodos na faixa de cabeçalho (`AppBar.bottom`): botão
/// anterior, título e subtítulo do período, botão próximo. `onNext == null`
/// desabilita o próximo (ex.: período atual, sem lançamento futuro).
class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPrevious,
    required this.onNext,
    this.previousTooltip = 'Período anterior',
    this.nextTooltip = 'Próximo período',
  });

  /// Maior escala de texto aplicada dentro do componente.
  static const maxTextScale = 1.5;

  final String title;
  final String subtitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  static TextScaler _scalerOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxTextScale);

  /// Altura do componente na escala de texto de [context] (56 na escala 1).
  static double heightOf(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = _scalerOf(context);
    final lines =
        AppTypography.lineHeight(text.titleMedium, s) +
        AppTypography.lineHeight(text.bodyMedium, s);
    return 2 * AppSpacing.xs + math.max(AppSpacing.minTouch, lines);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final band = BandColors.of(context);
    final white = theme.colorScheme.onPrimary;
    Widget arrow(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          icon: Icon(icon),
          tooltip: tooltip,
          color: white,
          disabledColor: band.muted.withValues(alpha: 0.38),
          onPressed: onPressed,
        );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: _scalerOf(context)),
      child: Container(
        height: heightOf(context),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: band.segment,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          children: [
            arrow(Icons.chevron_left, previousTooltip, onPrevious),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.tabular(text.titleMedium)
                          .copyWith(color: white),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.tabular(text.bodyMedium)
                          .copyWith(color: band.muted),
                    ),
                  ],
                ),
              ),
            ),
            arrow(Icons.chevron_right, nextTooltip, onNext),
          ],
        ),
      ),
    );
  }
}

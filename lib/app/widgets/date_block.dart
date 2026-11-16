import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../theme/app_theme.dart';

/// Bloco de data na cor forte da situação: dia e mês abreviado. Sem semântica
/// própria: quem o usa descreve a data.
class DateBlock extends StatelessWidget {
  const DateBlock({
    super.key,
    required this.date,
    this.showYear = false,
    required this.tone,
  });

  final DateTime date;

  /// Ano (dois dígitos) ao lado do mês, para datas fora do ano corrente.
  final bool showYear;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final onBlock = theme.colorScheme.onPrimary;
    final year = (date.year % 100).toString().padLeft(2, '0');
    final month = showYear
        ? '${formatMonthAbbr(date)} $year'
        : formatMonthAbbr(date);
    return Container(
      width: AppSpacing.minTouch,
      height: 52,
      decoration: BoxDecoration(
        color: StatusColors.of(context).resolve(tone).foreground,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}'.padLeft(2, '0'),
            style: AppTypography.tabular(text.titleLarge)
                .copyWith(color: onBlock),
          ),
          Text(
            month,
            maxLines: 1,
            style: AppTypography.tabular(text.labelSmall)
                .copyWith(color: onBlock),
          ),
        ],
      ),
    );
  }
}

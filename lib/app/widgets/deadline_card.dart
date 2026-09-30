import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../theme/app_theme.dart';

/// Prazo numa lista: bloco de data na cor forte da situação, título, linha de
/// contexto e texto relativo na mesma cor. A situação nunca fica só na cor: o
/// texto relativo a descreve.
class DeadlineCard extends StatelessWidget {
  const DeadlineCard({
    super.key,
    required this.date,
    this.showYear = false,
    required this.title,
    this.subtitle,
    required this.tone,
    this.statusLead,
    required this.statusText,
    this.onTap,
  });

  /// Vencimento.
  final DateTime date;

  /// Ano (dois dígitos) ao lado do mês, para datas fora do ano corrente.
  final bool showYear;
  final String title;

  /// Linha de contexto: categoria · órgão, ou a empresa.
  final String? subtitle;
  final StatusTone tone;

  /// Primeira linha do texto relativo ("Venceu"). `null` = uma linha só.
  final String? statusLead;
  final String statusText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = StatusColors.of(context).resolve(tone).foreground;
    final onBlock = theme.colorScheme.onPrimary;
    final subtitle = this.subtitle;
    final statusLead = this.statusLead;
    final year = (date.year % 100).toString().padLeft(2, '0');
    final month = showYear
        ? '${formatMonthAbbr(date)} $year'
        : formatMonthAbbr(date);
    final statusStyle = AppTypography.tabular(text.labelMedium)
        .copyWith(color: color);

    return Semantics(
      button: onTap != null,
      excludeSemantics: true,
      label: [
        title,
        'vence em ${formatDate(date)}',
        [?statusLead, statusText].join(' '),
      ].join(', '),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSpacing.minTouch,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
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
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge?.copyWith(
                            fontWeight: text.labelLarge?.fontWeight,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusLead != null)
                        Text(statusLead, style: statusStyle),
                      Text(statusText, style: statusStyle),
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

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'date_block.dart';

/// Situação em destaque no topo do detalhe: bloco de data, título (a situação
/// em texto) e mensagem de apoio, sobre o fundo suave do tom.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.tone,
    required this.date,
    this.showYear = false,
    required this.title,
    this.message,
  });

  /// Altura fixa, para uso em `AppBar.bottom`.
  static const double height = 76;

  final StatusTone tone;
  final DateTime date;
  final bool showYear;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final style = StatusColors.of(context).resolve(tone);
    final message = this.message;
    return Semantics(
      label: [title, ?message].join('. '),
      excludeSemantics: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.lgAll,
        ),
        child: Row(
          children: [
            DateBlock(date: date, showYear: showYear, tone: tone),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(color: style.foreground),
                  ),
                  if (message != null)
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.tabular(text.bodyMedium)
                          .copyWith(color: theme.colorScheme.onSurface),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

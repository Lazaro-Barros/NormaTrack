import 'dart:math' as math;

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

  /// Altura com o texto na escala 1: 12 + 52 (bloco de data) + 12.
  static const double height = 76;

  /// Altura do banner na escala de texto de [context], para o
  /// `AppBar.bottom`: cresce com a fonte do sistema até
  /// [DateBlock.maxTextScale]. Conta sempre a linha da mensagem, para a
  /// altura não depender dela.
  static double heightOf(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = DateBlock.scalerOf(context);
    final lines =
        AppTypography.lineHeight(text.titleLarge, s) +
        AppTypography.lineHeight(text.bodyMedium, s);
    return 2 * AppSpacing.md +
        math.max(DateBlock.sizeOf(context).height, lines);
  }

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
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: DateBlock.scalerOf(context)),
        child: Container(
          height: heightOf(context),
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
      ),
    );
  }
}

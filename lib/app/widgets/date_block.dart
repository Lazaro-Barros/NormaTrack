import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../theme/app_theme.dart';

/// Bloco de data na cor forte da situação: dia e mês abreviado. Sem semântica
/// própria: quem o usa descreve a data.
///
/// 48 × 52 na escala 1; cresce com a fonte do sistema até [maxTextScale].
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

  /// Largura com o texto na escala 1.
  static const double width = AppSpacing.minTouch;

  /// Altura com o texto na escala 1: 4 + 28 (dia) + 16 (mês) + 4.
  static const double height = 52;

  /// Escala máxima do texto dentro do bloco.
  static const double maxTextScale = 1.5;

  /// Folga vertical, constante em qualquer escala.
  static const double _verticalSlack = 2 * AppSpacing.xs;

  /// Escala do texto do sistema, limitada a [maxTextScale].
  static TextScaler scalerOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxTextScale);

  /// Tamanho do bloco na escala de texto de [context].
  static Size sizeOf(BuildContext context) =>
      _sizeFor(Theme.of(context).textTheme, scalerOf(context));

  /// Altura: folga + linha do dia + linha do mês. Largura: cresce na
  /// proporção do mês, o texto mais largo e o que mais cresce na escala não
  /// linear do Android 14+.
  static Size _sizeFor(TextTheme text, TextScaler s) {
    final month = text.labelSmall;
    final monthSize = month?.fontSize ?? 12;
    return Size(
      math.max(width, (width * s.scale(monthSize) / monthSize).ceilToDouble()),
      _verticalSlack +
          AppTypography.lineHeight(text.titleLarge, s) +
          AppTypography.lineHeight(month, s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final onBlock = theme.colorScheme.onPrimary;
    final scaler = scalerOf(context);
    final size = _sizeFor(text, scaler);
    final year = (date.year % 100).toString().padLeft(2, '0');
    final month = showYear
        ? '${formatMonthAbbr(date)} $year'
        : formatMonthAbbr(date);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: StatusColors.of(context).resolve(tone).foreground,
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}'.padLeft(2, '0'),
              maxLines: 1,
              softWrap: false,
              style: AppTypography.tabular(text.titleLarge)
                  .copyWith(color: onBlock),
            ),
            Text(
              month,
              maxLines: 1,
              softWrap: false,
              style: AppTypography.tabular(text.labelSmall)
                  .copyWith(color: onBlock),
            ),
          ],
        ),
      ),
    );
  }
}

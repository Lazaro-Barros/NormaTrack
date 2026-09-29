import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografia do design system (docs/07-design-system.md).
///
/// Manrope para títulos e números de destaque, IBM Plex Sans para o resto.
// TODO(RNF-01): embarcar os arquivos das fontes em assets/fonts e declará-los
// no pubspec.yaml. Enquanto não existirem, o Flutter usa a fonte padrão.
abstract final class AppTypography {
  static const display = 'Manrope';
  static const body = 'IBMPlexSans';

  static const _tabular = [FontFeature.tabularFigures()];

  static const textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontFamily: display,
      fontSize: 26,
      height: 32 / 26,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    // Título da faixa de cabeçalho.
    titleLarge: TextStyle(
      fontFamily: display,
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    // Título de seção, em frase normal (não caixa alta).
    titleMedium: TextStyle(
      fontFamily: display,
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: body,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: body,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w400,
      color: AppColors.ink2,
    ),
    bodySmall: TextStyle(
      fontFamily: body,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: AppColors.ink3,
    ),
    labelLarge: TextStyle(
      fontFamily: body,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontFamily: body,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w600,
      color: AppColors.ink2,
    ),
    labelSmall: TextStyle(
      fontFamily: body,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Número de destaque (contagens do Painel).
  static const number = TextStyle(
    fontFamily: display,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );

  /// Aplica algarismos tabulares: datas, quantidades, CNPJ.
  static TextStyle tabular(TextStyle? style) =>
      (style ?? const TextStyle()).copyWith(fontFeatures: _tabular);
}

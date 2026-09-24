import 'package:flutter/widgets.dart';

/// Espaçamento em grade de 4 (docs/07-design-system.md).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Margem lateral padrão das telas.
  static const screen = EdgeInsets.symmetric(horizontal: lg);

  /// Área mínima de toque.
  static const minTouch = 48.0;
}

/// Raios de canto.
abstract final class AppRadius {
  /// Bloco de data, ícones.
  static const sm = 8.0;

  /// Botões, campos, cards de lista.
  static const md = 12.0;

  /// Cards de seção, FAB.
  static const lg = 16.0;

  /// Chips, indicador da navegação.
  static const pill = 999.0;

  static final smAll = BorderRadius.circular(sm);
  static final mdAll = BorderRadius.circular(md);
  static final lgAll = BorderRadius.circular(lg);
  static final pillAll = BorderRadius.circular(pill);
}

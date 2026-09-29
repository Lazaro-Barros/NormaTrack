import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Cores de texto sobre a faixa de cabeçalho que não estão no `ColorScheme`.
/// Acessíveis via [BandColors.of].
@immutable
class BandColors extends ThemeExtension<BandColors> {
  const BandColors({required this.muted});

  static const light = BandColors(muted: AppColors.onBandMuted);

  /// Texto secundário sobre a faixa (subtítulo).
  final Color muted;

  static BandColors of(BuildContext context) =>
      Theme.of(context).extension<BandColors>() ?? light;

  @override
  BandColors copyWith({Color? muted}) => BandColors(muted: muted ?? this.muted);

  @override
  BandColors lerp(BandColors? other, double t) {
    if (other == null) return this;
    return BandColors(muted: Color.lerp(muted, other.muted, t)!);
  }
}

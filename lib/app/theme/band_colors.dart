import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Cores de texto sobre a faixa de cabeçalho que não estão no `ColorScheme`.
/// Acessíveis via [BandColors.of].
@immutable
class BandColors extends ThemeExtension<BandColors> {
  const BandColors({required this.muted, required this.segment});

  static const light = BandColors(
    muted: AppColors.onBandMuted,
    segment: AppColors.onBandSegment,
  );

  /// Texto secundário sobre a faixa (subtítulo).
  final Color muted;

  /// Fundo do segmento não selecionado de `BandSegmentedButton`.
  final Color segment;

  static BandColors of(BuildContext context) =>
      Theme.of(context).extension<BandColors>() ?? light;

  @override
  BandColors copyWith({Color? muted, Color? segment}) =>
      BandColors(muted: muted ?? this.muted, segment: segment ?? this.segment);

  @override
  BandColors lerp(BandColors? other, double t) {
    if (other == null) return this;
    return BandColors(
      muted: Color.lerp(muted, other.muted, t)!,
      segment: Color.lerp(segment, other.segment, t)!,
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'status_chip.dart';

/// Contagem de uma situação na faixa do Painel: número grande e rótulo com o
/// ícone do tom, sobre a cor suave da situação. Tocar filtra; o selecionado
/// ganha um anel na cor forte (sem mudar o tamanho).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.tone,
    required this.count,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final StatusTone tone;
  final int count;

  /// Rótulo no plural, ex.: "Vencidos".
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Altura com o texto na escala 1: 12 + 36 + 18 + 12.
  static const double height = 78;

  /// Escala máxima do texto dentro do tile; acima disso o rótulo encurta com
  /// reticências (a semântica mantém o rótulo inteiro).
  static const double maxTextScale = 1.5;

  /// Altura do tile na escala de texto de [context], para o `AppBar.bottom`:
  /// cresce com a fonte do sistema até [maxTextScale].
  static double heightOf(BuildContext context) =>
      _heightFor(context, _scaler(context));

  static TextScaler _scaler(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxTextScale);

  /// Padding mais as linhas do número e do rótulo
  /// (ver [AppTypography.lineHeight]).
  static double _heightFor(BuildContext context, TextScaler s) =>
      2 * AppSpacing.md +
      AppTypography.lineHeight(AppTypography.number, s) +
      AppTypography.lineHeight(Theme.of(context).textTheme.labelMedium, s);

  @override
  Widget build(BuildContext context) {
    final style = StatusColors.of(context).resolve(tone);
    final labelStyle = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: style.foreground);
    final scaler = _scaler(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$count $label',
      excludeSemantics: true,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: scaler),
        child: Container(
          height: _heightFor(context, scaler),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: AppRadius.lgAll,
          ),
          foregroundDecoration: selected
              ? BoxDecoration(
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(width: 2, color: style.foreground),
                )
              : null,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadius.lgAll,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      maxLines: 1,
                      style: AppTypography.number.copyWith(
                        color: style.foreground,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          StatusChip.iconFor(tone),
                          size: 16,
                          color: style.foreground,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Segmentado claro para a faixa de cabeçalho (`AppBar.bottom`): segmentos
/// translúcidos com texto branco; o selecionado é branco com texto petróleo.
class BandSegmentedButton<T> extends StatelessWidget {
  const BandSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<(T value, String label)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SegmentedButton<T>(
      expandedInsets: EdgeInsets.zero,
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: BandColors.of(context).segment,
        foregroundColor: colors.onPrimary,
        selectedBackgroundColor: colors.surface,
        selectedForegroundColor: colors.primary,
        side: BorderSide.none,
      ),
      segments: [
        for (final (value, label) in segments)
          ButtonSegment(value: value, label: Text(label)),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.single),
    );
  }
}

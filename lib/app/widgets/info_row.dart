import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dado cadastral: rótulo à esquerda e uma ou mais linhas à direita.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.lines});

  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final strong = AppTypography.tabular(text.bodyLarge)
        .copyWith(fontWeight: text.labelLarge?.fontWeight);
    final weak = AppTypography.tabular(text.bodyMedium);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodyMedium),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < lines.length; i++)
                  Text(
                    lines[i],
                    textAlign: TextAlign.end,
                    style: i == 0 ? strong : weak,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

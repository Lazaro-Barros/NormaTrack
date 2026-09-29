import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Título (e subtítulo opcional) da faixa de cabeçalho, para o `title:` do
/// `AppBar`. `large` só nas telas da barra inferior.
class BandTitle extends StatelessWidget {
  const BandTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.large = false,
  });

  final String title;
  final String? subtitle;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final subtitle = this.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (large ? text.headlineMedium : text.titleLarge)?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.tabular(text.bodyMedium)
                .copyWith(color: BandColors.of(context).muted),
          ),
      ],
    );
  }
}

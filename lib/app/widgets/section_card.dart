import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Seção de uma tela: título (e legenda) acima de um card com os itens
/// separados por divisória.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.caption,
    this.description,
    required this.children,
  });

  final String title;
  final String? caption;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final caption = this.caption;
    final description = this.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                // Com legenda, o título fica no tamanho natural e a legenda
                // quebra linha se não couber (em vez de estourar).
                children: caption == null
                    ? [Expanded(child: Text(title, style: text.titleMedium))]
                    : [
                        Text(title, style: text.titleMedium),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            caption,
                            textAlign: TextAlign.end,
                            style: AppTypography.tabular(text.bodyMedium),
                          ),
                        ),
                      ],
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: text.bodyMedium),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

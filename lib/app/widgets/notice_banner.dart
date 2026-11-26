import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Aviso em destaque dentro de uma tela (ex.: "Nenhum backup feito ainda"),
/// na cor suave de um tom, com ícone e texto na cor forte. A situação nunca
/// vai só na cor: o texto diz o que é. Sem altura fixa.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.tone,
    required this.icon,
    required this.message,
    this.emphasis,
  });

  final StatusTone tone;
  final IconData icon;
  final String message;

  /// Trecho em negrito depois da mensagem.
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = StatusColors.of(context).resolve(tone);
    final emphasis = this.emphasis;
    final iconSize = IconTheme.of(context).size ?? 24;
    final line = AppTypography.lineHeight(
      text.bodyMedium,
      MediaQuery.textScalerOf(context),
    );
    return Semantics(
      container: true,
      label: [message, ?emphasis].join(' '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.lgAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: iconSize, color: style.foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                // Centraliza a 1ª linha do texto com o ícone.
                padding: EdgeInsets.only(
                  top: ((iconSize - line) / 2).clamp(0, double.infinity),
                ),
                child: Text.rich(
                  TextSpan(
                    text: message,
                    style: text.bodyMedium?.copyWith(color: style.foreground),
                    children: [
                      if (emphasis != null)
                        TextSpan(
                          text: ' $emphasis',
                          style: text.labelMedium?.copyWith(
                            color: style.foreground,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

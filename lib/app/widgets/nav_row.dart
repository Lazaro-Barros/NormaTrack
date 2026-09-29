import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Linha dentro de um card: ícone opcional, título, subtítulo, situação à
/// direita e chevron quando é navegável.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: RowLayout(
        minHeight: 52,
        leadingIcon: leadingIcon,
        title: title,
        subtitle: subtitle,
        trailing: [
          ?trailing,
          if (onTap != null)
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// Layout comum de [NavRow] e `SwitchRow`. Não usar fora de `lib/app/widgets/`.
class RowLayout extends StatelessWidget {
  const RowLayout({
    super.key,
    required this.minHeight,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing = const [],
  });

  final double minHeight;
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final leadingIcon = this.leadingIcon;
    final subtitle = this.subtitle;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(leadingIcon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: text.labelLarge?.fontWeight,
                    ),
                  ),
                  if (subtitle != null) Text(subtitle, style: text.bodyMedium),
                ],
              ),
            ),
            for (final widget in trailing) ...[
              const SizedBox(width: AppSpacing.sm),
              widget,
            ],
          ],
        ),
      ),
    );
  }
}

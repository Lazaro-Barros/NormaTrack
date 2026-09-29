import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rótulo acima de um campo (`AppTextField`, `AppDropdownField`), com `*` se
/// obrigatório, e a mensagem de erro com ícone para `InputDecoration.error`.
/// Não usar fora de `lib/app/widgets/`.
abstract final class FieldParts {
  static Widget label(BuildContext context, String label, bool required) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
      style: theme.textTheme.labelMedium,
    );
  }

  static Widget? error(BuildContext context, String? errorText) {
    if (errorText == null) return null;
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    return Row(
      children: [
        Icon(Icons.error_outline, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  static Widget column(Widget label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      label,
      const SizedBox(height: AppSpacing.xs),
      field,
    ],
  );
}

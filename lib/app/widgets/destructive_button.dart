import 'package:flutter/material.dart';

/// Ação destrutiva: contorno vermelho. Sempre pedir confirmação antes de
/// executar (`showConfirmDialog`).
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final style = OutlinedButton.styleFrom(
      foregroundColor: error,
      side: BorderSide(color: error),
    );
    final icon = this.icon;
    if (icon == null) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

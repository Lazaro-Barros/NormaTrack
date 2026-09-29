import 'package:flutter/material.dart';

import 'nav_row.dart';

/// Linha com interruptor dentro de um card. Tocar na linha inteira alterna.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: RowLayout(
          minHeight: 64,
          leadingIcon: leadingIcon,
          title: title,
          subtitle: subtitle,
          trailing: [Switch(value: value, onChanged: onChanged)],
        ),
      ),
    );
  }
}

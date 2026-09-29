import 'package:flutter/material.dart';

import 'field_parts.dart';

/// Lista de opções com o layout do `AppTextField`. O primeiro item,
/// "Nenhuma", limpa o valor.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.selectedLabel,
    this.hint,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;

  /// Texto do valor escolhido no campo fechado. Padrão: [itemLabel].
  final String Function(T)? selectedLabel;
  final String? hint;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selectedLabel ?? itemLabel;
    Text ellipsis(String text) =>
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
    final hint = this.hint;
    return FieldParts.column(
      FieldParts.label(context, label, false),
      DropdownButtonFormField<T?>(
        // initialValue só vale na criação: a chave recria com o valor novo.
        key: ValueKey(value),
        initialValue: value,
        isExpanded: true,
        hint: hint == null ? null : ellipsis(hint),
        items: [
          DropdownMenuItem<T?>(value: null, child: ellipsis('Nenhuma')),
          for (final item in items)
            DropdownMenuItem<T?>(value: item, child: ellipsis(itemLabel(item))),
        ],
        selectedItemBuilder: (context) => [
          ellipsis(hint ?? ''),
          for (final item in items) ellipsis(selected(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

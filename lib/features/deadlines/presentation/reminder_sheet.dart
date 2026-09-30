import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../core/utils/date_format.dart';
import '../domain/deadline.dart';

/// Atalhos do sheet, em dias antes do vencimento.
const reminderShortcuts = [60, 30, 15, 7, 1, 0];

/// Escolhe um lembrete novo (dias antes do vencimento). Devolve `null` se
/// fechou sem adicionar.
Future<int?> showReminderSheet(
  BuildContext context, {
  required List<int> existing,
  DateTime? dueDate,
}) => showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _ReminderSheet(existing: existing, dueDate: dueDate),
);

String _shortcutLabel(int days) => switch (days) {
  0 => 'No dia',
  1 => '1 dia',
  _ => '$days dias',
};

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.existing, required this.dueDate});

  final List<int> existing;
  final DateTime? dueDate;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  final _days = TextEditingController();
  String? _error;

  int? get _value => int.tryParse(_days.text);

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  void _pick(int days) => setState(() {
    _days.text = '$days';
    _error = null;
  });

  void _add() {
    final value = _value;
    if (value == null) {
      setState(() => _error = 'Informe os dias');
    } else if (widget.existing.contains(value)) {
      setState(() => _error = 'Este lembrete já está na lista');
    } else {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dueDate = widget.dueDate;
    final value = _value;
    final shortcuts = [
      for (final d in reminderShortcuts)
        if (!widget.existing.contains(d)) d,
    ];
    final helper = dueDate != null && value != null
        ? 'Aviso em ${formatDate(reminderDate(dueDate, value))}. '
              'Use 0 para avisar no dia.'
        : 'Use 0 para avisar no dia.';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Adicionar lembrete', style: text.titleMedium),
                    if (dueDate != null)
                      Text(
                        'Vencimento em ${formatDate(dueDate)}',
                        style: AppTypography.tabular(text.bodyMedium),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          if (shortcuts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Atalhos', style: text.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final d in shortcuts)
                  ChoiceChip(
                    label: Text(_shortcutLabel(d)),
                    selected: value == d,
                    onSelected: (_) => _pick(d),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Dias antes do vencimento',
            required: true,
            controller: _days,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            tabular: true,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('dias', style: text.bodyLarge),
            ),
            helperText: helper,
            errorText: _error,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _add, child: const Text('Adicionar')),
        ],
      ),
    );
  }
}

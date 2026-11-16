import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../core/utils/date_format.dart';
import '../domain/deadline.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Sheet de renovação: pede o novo vencimento, já sugerido. Devolve `null` se
/// fechou sem confirmar. Só aceita datas depois do vencimento atual.
Future<DateTime?> showRenewSheet(
  BuildContext context, {
  required Deadline deadline,
  required DateTime suggested,
}) => _show(
  context,
  _DateSheet(
    title: 'Registrar renovação',
    description:
        'O ciclo atual será encerrado e um novo ciclo será aberto com os '
        'mesmos lembretes.',
    fieldLabel: 'Novo vencimento',
    initial: suggested,
    firstDate: DateTime(
      deadline.dueDate.year,
      deadline.dueDate.month,
      deadline.dueDate.day + 1,
    ),
    lastDate: DateTime(2100),
    helper: (date) =>
        'Alertas a partir de '
        '${formatDate(reminderDate(date, deadline.alertDaysBefore))}',
    confirmLabel: 'Renovar',
  ),
);

/// Sheet de conclusão: pede "Concluído em" (padrão hoje, nunca no futuro).
Future<DateTime?> showCompleteSheet(
  BuildContext context, {
  required DateTime today,
}) => _show(
  context,
  _DateSheet(
    title: 'Concluir prazo',
    description:
        'Registre quando foi feito. O prazo sai da lista de em aberto e '
        'pode ser reaberto.',
    fieldLabel: 'Concluído em',
    initial: _dateOnly(today),
    firstDate: DateTime(2000),
    lastDate: _dateOnly(today),
    confirmLabel: 'Concluir',
  ),
);

Future<DateTime?> _show(BuildContext context, Widget sheet) =>
    showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => sheet,
    );

class _DateSheet extends StatefulWidget {
  const _DateSheet({
    required this.title,
    required this.description,
    required this.fieldLabel,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    required this.confirmLabel,
    this.helper,
  });

  final String title;
  final String description;
  final String fieldLabel;
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  final String confirmLabel;
  final String Function(DateTime date)? helper;

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime _date = widget.initial;
  late final _text = TextEditingController(text: formatDate(widget.initial));

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      helpText: widget.fieldLabel,
    );
    if (picked == null) return;
    setState(() {
      _date = _dateOnly(picked);
      _text.text = formatDate(_date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
          Text(widget.title, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.description, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: widget.fieldLabel,
            required: true,
            controller: _text,
            readOnly: true,
            tabular: true,
            onTap: _pick,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            helperText: widget.helper?.call(_date),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_date),
            child: Text(widget.confirmLabel),
          ),
        ],
      ),
    );
  }
}

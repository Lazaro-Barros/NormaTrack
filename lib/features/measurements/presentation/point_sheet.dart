import 'package:flutter/material.dart';

import '../../../app/formatters/decimal_input_formatter.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/destructive_button.dart';
import '../domain/measurement_parameter.dart';

/// Como a sheet do ponto fechou: salvou (pelo `onSave`) ou pediu uma ação.
enum PointSheetAction { saved, archive, unarchive, delete }

/// Cadastra ([current] nulo) ou edita um ponto de medição: nome e limite
/// máximo. [onSave] grava e devolve a mensagem de erro do nome (a sheet fica
/// aberta) ou `null` (a sheet fecha com [PointSheetAction.saved]). Desativar,
/// reativar e excluir fecham a sheet e quem chamou executa.
Future<PointSheetAction?> showPointSheet(
  BuildContext context, {
  MeasurementParameter? current,
  required String unit,
  required Future<String?> Function(String name, double? limitMax) onSave,
}) => showModalBottomSheet<PointSheetAction>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) =>
      _PointSheet(current: current, unit: unit, onSave: onSave),
);

class _PointSheet extends StatefulWidget {
  const _PointSheet({
    required this.current,
    required this.unit,
    required this.onSave,
  });

  final MeasurementParameter? current;
  final String unit;
  final Future<String?> Function(String name, double? limitMax) onSave;

  @override
  State<_PointSheet> createState() => _PointSheetState();
}

class _PointSheetState extends State<_PointSheet> {
  late final _name = TextEditingController(text: widget.current?.name);
  late final _limit = TextEditingController(
    text: switch (widget.current?.limitMax) {
      final max? => formatDecimal(max),
      null => '',
    },
  );
  String? _nameError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Informe o nome');
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSave(_name.text, parseDecimal(_limit.text));
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(PointSheetAction.saved);
    } else {
      setState(() {
        _saving = false;
        _nameError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final current = widget.current;
    void close(PointSheetAction action) => Navigator.of(context).pop(action);
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
          Text(
            current == null ? 'Novo ponto' : 'Editar ponto',
            style: text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Nome',
            required: true,
            controller: _name,
            hint: 'Ex.: Portão principal',
            textCapitalization: TextCapitalization.sentences,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Limite máximo',
            controller: _limit,
            tabular: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalInputFormatter()],
            helperText:
                'Opcional. Valores acima aparecem como "Acima do limite".',
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(widget.unit, style: text.bodyMedium),
            ),
          ),
          if (current != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => close(
                      current.isArchived
                          ? PointSheetAction.unarchive
                          : PointSheetAction.archive,
                    ),
                    child: Text(current.isArchived ? 'Reativar' : 'Desativar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DestructiveButton(
                    label: 'Excluir',
                    onPressed: () => close(PointSheetAction.delete),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_text_field.dart';

/// Pede o motivo de "sem medição" (C26). Devolve o motivo sem espaços sobrando
/// ou `null` se fechou sem aplicar.
Future<String?> showSkipReasonSheet(
  BuildContext context, {
  required String title,
  String? description,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) =>
      _SkipReasonSheet(title: title, description: description),
);

class _SkipReasonSheet extends StatefulWidget {
  const _SkipReasonSheet({required this.title, this.description});

  final String title;
  final String? description;

  @override
  State<_SkipReasonSheet> createState() => _SkipReasonSheetState();
}

class _SkipReasonSheetState extends State<_SkipReasonSheet> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _apply() {
    final reason = _reason.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (reason.isEmpty) {
      setState(() => _error = 'Informe o motivo');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final description = widget.description;
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
          Text(widget.title, style: text.titleMedium),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: text.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Motivo',
            required: true,
            controller: _reason,
            hint: 'Ex.: fábrica parada',
            textCapitalization: TextCapitalization.sentences,
            errorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _apply, child: const Text('Aplicar')),
        ],
      ),
    );
  }
}

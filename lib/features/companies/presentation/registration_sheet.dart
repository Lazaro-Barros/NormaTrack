import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../core/utils/date_format.dart';
import '../domain/authority.dart';

class RegistrationSheetResult {
  const RegistrationSheetResult(this.registration);

  /// `null` = não se aplica.
  final AuthorityRegistration? registration;
}

/// Situação, nº, validade e observações do registro da empresa num órgão
/// (RF-EMP-05). Devolve `null` se fechou sem aplicar (nada muda).
Future<RegistrationSheetResult?> showRegistrationSheet(
  BuildContext context, {
  required Authority authority,
  AuthorityRegistration? current,
  required DateTime today,
}) => showModalBottomSheet<RegistrationSheetResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) =>
      _RegistrationSheet(authority: authority, current: current, today: today),
);

enum _Choice { notApplicable, registered, required }

class _RegistrationSheet extends StatefulWidget {
  const _RegistrationSheet({
    required this.authority,
    required this.current,
    required this.today,
  });

  final Authority authority;
  final AuthorityRegistration? current;
  final DateTime today;

  @override
  State<_RegistrationSheet> createState() => _RegistrationSheetState();
}

class _RegistrationSheetState extends State<_RegistrationSheet> {
  late _Choice _choice = switch (widget.current?.status) {
    null => _Choice.notApplicable,
    RegistrationStatus.registered => _Choice.registered,
    RegistrationStatus.required => _Choice.required,
  };
  late final _number = TextEditingController(
    text: widget.current?.registrationNumber,
  );
  late final _notes = TextEditingController(text: widget.current?.notes);
  late DateTime? _validUntil = widget.current?.validUntil;
  late final _validText = TextEditingController(text: _dateText(_validUntil));

  static String _dateText(DateTime? d) => d == null ? '' : formatDate(d);

  void _setValidUntil(DateTime? value) => setState(() {
    _validUntil = value;
    _validText.text = _dateText(value);
  });

  @override
  void dispose() {
    _number.dispose();
    _notes.dispose();
    _validText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? widget.today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Validade',
    );
    if (picked != null) _setValidUntil(picked);
  }

  void _apply() {
    final authority = widget.authority;
    final registration = switch (_choice) {
      _Choice.notApplicable => null,
      _Choice.registered => AuthorityRegistration(
        authority: authority,
        status: RegistrationStatus.registered,
        registrationNumber: _number.text,
        validUntil: _validUntil,
        notes: _notes.text,
      ),
      // Nº e validade só existem com "possui registro" (critério de aceite).
      _Choice.required => AuthorityRegistration(
        authority: authority,
        status: RegistrationStatus.required,
        notes: _notes.text,
      ),
    };
    Navigator.of(context).pop(RegistrationSheetResult(registration));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final validUntil = _validUntil;
    final expired =
        validUntil != null &&
        AuthorityRegistration(
          authority: widget.authority,
          status: RegistrationStatus.registered,
          validUntil: validUntil,
        ).isExpiredOn(widget.today);
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
                    Text(widget.authority.label, style: text.titleMedium),
                    Text(
                      'Registro da empresa neste órgão',
                      style: text.bodyMedium,
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
          const SizedBox(height: AppSpacing.lg),
          Text('Situação', style: text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<_Choice>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _Choice.notApplicable,
                label: Text('Não se aplica'),
              ),
              ButtonSegment(value: _Choice.registered, label: Text('Possui')),
              ButtonSegment(
                value: _Choice.required,
                label: Text('Precisa obter'),
              ),
            ],
            selected: {_choice},
            onSelectionChanged: (s) => setState(() => _choice = s.single),
          ),
          if (_choice == _Choice.registered) ...[
            const SizedBox(height: AppSpacing.lg),
            AppTextField(label: 'Nº do registro', controller: _number),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Validade',
              controller: _validText,
              hint: 'dd/mm/aaaa',
              readOnly: true,
              tabular: true,
              onTap: _pickDate,
              errorText: expired
                  ? 'Validade vencida em ${formatDate(validUntil)}'
                  : null,
              suffixIcon: validUntil == null
                  ? const Icon(Icons.calendar_today_outlined)
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Remover validade',
                      onPressed: () => _setValidUntil(null),
                    ),
            ),
          ],
          if (_choice != _Choice.notApplicable) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Observações',
              controller: _notes,
              hint: 'Opcional',
              maxLines: 3,
              minLines: 2,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _apply, child: const Text('Aplicar')),
        ],
      ),
    );
  }
}

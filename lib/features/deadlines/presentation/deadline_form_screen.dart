import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_action_bar.dart';
import '../../../app/widgets/app_dropdown_field.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/band_segmented_button.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/field_error_text.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_format.dart';
import '../../companies/data/local_company_repository.dart'
    show companyRepositoryProvider;
import '../../companies/domain/authority.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/company_repository.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/company_labels.dart';
import '../data/local_deadline_repository.dart' show deadlineRepositoryProvider;
import '../domain/deadline.dart';
import '../domain/deadline_category.dart';
import '../domain/deadline_repository.dart';
import '../domain/deadline_validation.dart';
import 'deadline_labels.dart';
import 'reminder_sheet.dart';

enum _Field { title, dueDate, reminders }

/// O que faltou ao abrir a tela.
enum _Missing { module, company, deadline }

/// Valores comparados para saber se o formulário foi alterado.
typedef _Snapshot = ({
  DeadlineCategory category,
  Authority? authority,
  String title,
  DateTime? dueDate,
  List<int> reminders,
});

/// Criar (`deadlineId == null`) ou editar prazo (RF-PRZ-01/02).
class DeadlineFormScreen extends ConsumerStatefulWidget {
  const DeadlineFormScreen({
    super.key,
    required this.companyId,
    required this.slug,
    this.deadlineId,
  });

  final String companyId;
  final String slug;
  final String? deadlineId;

  @override
  ConsumerState<DeadlineFormScreen> createState() => _DeadlineFormScreenState();
}

class _DeadlineFormScreenState extends ConsumerState<DeadlineFormScreen> {
  final _title = TextEditingController();
  late final _dueText = TextEditingController();
  final Map<_Field, String> _errors = {};
  final _fieldKeys = {for (final f in _Field.values) f: GlobalKey()};

  Company? _company;
  ModuleType? _module;
  DeadlineCategory _category = DeadlineCategory.license;
  Authority? _authority;
  DateTime? _dueDate;
  List<int> _reminders = DeadlineCategory.license.defaultReminderDays;
  bool _remindersEdited = false;
  late _Snapshot _initial = _snapshot();

  bool _loading = true;
  _Missing? _missing;
  bool _saving = false;
  bool _saved = false;

  bool get _isEditing => widget.deadlineId != null;

  DateTime get _today => ref.read(clockProvider)().toLocal();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _dueText.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    var module = moduleFromSlug(widget.slug);
    final company = await ref
        .read(companyRepositoryProvider)
        .findById(widget.companyId);
    final id = widget.deadlineId;
    final deadline = id == null
        ? null
        : await ref.read(deadlineRepositoryProvider).findById(id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (module == null) {
        _missing = _Missing.module;
      } else if (company == null) {
        _missing = _Missing.company;
      } else if (id != null && deadline == null) {
        _missing = _Missing.deadline;
      }
      if (_missing != null) return;
      if (deadline != null) {
        // O módulo gravado vale mais que o da rota.
        module = deadline.module;
        _category = deadline.category;
        _authority = deadline.authority;
        _title.text = deadline.title;
        _setDueDate(deadline.dueDate);
        _reminders = deadline.reminderDays;
        _remindersEdited = true;
      }
      _company = company;
      _module = module;
      _initial = _snapshot();
    });
  }

  _Snapshot _snapshot() => (
    category: _category,
    authority: _authority,
    title: _title.text.trim(),
    dueDate: _dueDate,
    reminders: _reminders,
  );

  bool get _isDirty {
    final now = _snapshot();
    return now.category != _initial.category ||
        now.authority != _initial.authority ||
        now.title != _initial.title ||
        now.dueDate != _initial.dueDate ||
        !const ListEquality<int>().equals(now.reminders, _initial.reminders);
  }

  void _setDueDate(DateTime value) {
    _dueDate = DateTime(value.year, value.month, value.day);
    _dueText.text = formatDate(value);
  }

  void _setCategory(DeadlineCategory category) => setState(() {
    _category = category;
    if (!_remindersEdited) _reminders = category.defaultReminderDays;
  });

  void _setReminders(List<int> reminders) => setState(() {
    _reminders = List.unmodifiable(reminders..sort((a, b) => b - a));
    _remindersEdited = true;
    _errors.remove(_Field.reminders);
  });

  /// Tira o foco antes de abrir sheet, diálogo ou seletor: senão, ao fechar,
  /// a rota devolve o foco ao campo e o teclado reabre sozinho.
  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _pickDueDate() async {
    _unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Vencimento',
    );
    if (picked == null) return;
    setState(() {
      _setDueDate(picked);
      _errors.remove(_Field.dueDate);
    });
  }

  Future<void> _addReminder() async {
    _unfocus();
    final days = await showReminderSheet(
      context,
      existing: _reminders,
      dueDate: _dueDate,
    );
    if (days != null) _setReminders([..._reminders, days]);
  }

  void _showErrors(Map<_Field, String> errors) {
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    final first = _Field.values.firstWhere(_errors.containsKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _fieldKeys[first]!.currentContext;
      if (context == null || !context.mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.1,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  Future<void> _save() async {
    final dueDate = _dueDate;
    final errors = {
      if (_title.text.trim().isEmpty) _Field.title: 'Informe o título',
      if (dueDate == null) _Field.dueDate: 'Informe o vencimento',
      if (_reminders.isEmpty) _Field.reminders: 'Adicione ao menos um lembrete',
    };
    if (errors.isNotEmpty) return _showErrors(errors);

    final module = _module!;
    final input = DeadlineInput(
      module: module,
      category: _category,
      authority: _authority,
      title: _title.text,
      dueDate: dueDate!,
      reminderDays: _reminders,
    );
    setState(() => _saving = true);
    final repo = ref.read(deadlineRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final companyId = widget.companyId;
    void leave(String message, String route) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      context.go(route);
    }

    try {
      final id = widget.deadlineId;
      if (id == null) {
        await repo.create(companyId, input);
      } else {
        await repo.update(id, input);
      }
      if (!mounted) return;
      setState(() => _saved = true);
      messenger.showSnackBar(const SnackBar(content: Text('Prazo salvo')));
      context.canPop()
          ? context.pop()
          : context.go(AppRoutes.module(companyId, module));
    } on DeadlineValidationException catch (e) {
      if (!mounted) return;
      _showErrors({
        for (final error in e.errors)
          switch (error.field) {
            DeadlineField.title => _Field.title,
            DeadlineField.dueDate => _Field.dueDate,
            DeadlineField.reminderDays => _Field.reminders,
          }: deadlineFieldMessage(
            error,
          ),
      });
    } on ModuleNotEnabledException {
      if (!mounted) return;
      _saved = true;
      leave(
        'O módulo foi desligado nesta empresa',
        AppRoutes.company(companyId),
      );
    } on CompanyNotFoundException {
      if (!mounted) return;
      _saved = true;
      leave('Empresa não encontrada', AppRoutes.companies);
    } on DeadlineNotFoundException {
      if (!mounted) return;
      _saved = true;
      leave('Prazo não encontrado', AppRoutes.module(companyId, module));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDiscard() async {
    _unfocus();
    final discard = await showConfirmDialog(
      context,
      title: 'Descartar alterações?',
      message: 'O que foi preenchido nesta tela será perdido.',
      confirmLabel: 'Descartar',
      destructive: true,
    );
    if (!discard || !mounted) return;
    setState(() => _saved = true);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final company = _company;
    final module = _module;
    final ready = !_loading && _missing == null;
    final title = _isEditing ? 'Editar prazo' : 'Novo prazo';
    return PopScope(
      canPop: _saved || !ready || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () => Navigator.maybePop(context),
          ),
          title: BandTitle(
            title: title,
            subtitle: company == null || module == null
                ? null
                : '${company.displayName} · ${module.label}',
          ),
          bottom: ready
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(
                    AppSpacing.minTouch + AppSpacing.lg,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: BandSegmentedButton<DeadlineCategory>(
                      segments: [
                        for (final c in DeadlineCategory.values) (c, c.label),
                      ],
                      selected: _category,
                      onChanged: _setCategory,
                    ),
                  ),
                )
              : null,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _missing != null
            ? _missingState(context, _missing!)
            : _form(context),
        bottomNavigationBar: ready
            ? AppActionBar(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Cancelar'),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Salvar prazo'),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _missingState(BuildContext context, _Missing missing) {
    final companyId = widget.companyId;
    final (title, message, route) = switch (missing) {
      _Missing.module => (
        'Módulo não encontrado',
        'Volte e escolha o módulo de novo.',
        AppRoutes.company(companyId),
      ),
      _Missing.company => (
        'Empresa não encontrada',
        'Ela pode ter sido excluída.',
        AppRoutes.companies,
      ),
      _Missing.deadline => (
        'Prazo não encontrado',
        'Ele pode ter sido excluído.',
        AppRoutes.module(companyId, moduleFromSlug(widget.slug)!),
      ),
    };
    return EmptyState(
      icon: Icons.event_busy_outlined,
      title: title,
      message: message,
      actionLabel: 'Voltar',
      onAction: () => context.go(route),
    );
  }

  Widget _form(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dueDate = _dueDate;
    final reminders = _reminders;
    final remindersError = _errors[_Field.reminders];
    return SingleChildScrollView(
      padding: AppSpacing.screen.copyWith(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: 'Dados do prazo',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      key: _fieldKeys[_Field.title],
                      label: 'Título',
                      required: true,
                      controller: _title,
                      hint: 'Ex.: Licença de Operação',
                      errorText: _errors[_Field.title],
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) =>
                          setState(() => _errors.remove(_Field.title)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdownField<Authority>(
                      label: 'Órgão',
                      value: _authority,
                      items: Authority.values,
                      itemLabel: (a) => a.label,
                      noneLabel: 'Nenhum',
                      onChanged: (a) => setState(() => _authority = a),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: _fieldKeys[_Field.dueDate],
                      label: 'Vencimento',
                      required: true,
                      controller: _dueText,
                      hint: 'dd/mm/aaaa',
                      readOnly: true,
                      tabular: true,
                      onTap: _pickDueDate,
                      errorText: _errors[_Field.dueDate],
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            key: _fieldKeys[_Field.reminders],
            title: 'Lembretes',
            caption: dueDate == null || reminders.isEmpty
                ? null
                : 'Alertas a partir de '
                      '${formatDate(reminderDate(dueDate, reminders.first))}',
            children: [
              for (final (i, days) in reminders.indexed)
                NavRow(
                  leadingIcon: Icons.notifications_none_outlined,
                  title: reminderLabel(days),
                  subtitle: dueDate == null
                      ? null
                      : formatDate(reminderDate(dueDate, days)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i == 0)
                        Text(
                          'Primeiro alerta',
                          style: text.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Remover lembrete: ${reminderLabel(days)}',
                        onPressed: () => _setReminders([
                          for (final d in reminders)
                            if (d != days) d,
                        ]),
                      ),
                    ],
                  ),
                ),
              NavRow(
                leadingIcon: Icons.add,
                title: 'Adicionar lembrete',
                onTap: _addReminder,
              ),
            ],
          ),
          if (remindersError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            FieldErrorText(remindersError),
          ],
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'O prazo fica "a vencer" a partir do primeiro alerta. Os outros '
              'lembretes são avisos no celular.',
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

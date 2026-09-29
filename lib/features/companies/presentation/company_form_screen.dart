import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/formatters/br_input_formatters.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_action_bar.dart';
import '../../../app/widgets/app_dropdown_field.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../app/widgets/status_text.dart';
import '../../../app/widgets/switch_row.dart';
import '../../../core/providers.dart';
import '../../../core/utils/br_documents.dart';
import '../data/local_company_repository.dart' show companyRepositoryProvider;
import '../domain/authority.dart';
import '../domain/brazilian_state.dart';
import '../domain/company.dart';
import '../domain/company_repository.dart';
import '../domain/company_validation.dart';
import '../domain/module_type.dart';
import 'company_labels.dart';
import 'registration_sheet.dart';

/// Criar (`companyId == null`) ou editar empresa (RF-EMP-01/02/04/05).
class CompanyFormScreen extends ConsumerStatefulWidget {
  const CompanyFormScreen({super.key, this.companyId});

  final String? companyId;

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final _legalName = TextEditingController();
  final _tradeName = TextEditingController();
  final _cnpj = TextEditingController();
  final _stateRegistration = TextEditingController();
  final _postalCode = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _complement = TextEditingController();
  final _district = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _repName = TextEditingController();
  final _repCpf = TextEditingController();
  final _repPhone = TextEditingController();
  final _repEmail = TextEditingController();

  BrazilianState? _state;
  final Set<ModuleType> _modules = {};
  final Map<Authority, AuthorityRegistration> _registrations = {};
  final Map<CompanyField, String> _errors = {};
  final _fieldKeys = {for (final f in CompanyField.values) f: GlobalKey()};

  CompanyInput _initial = const CompanyInput(legalName: '');
  bool _loading = false;
  bool _notFound = false;
  bool _saving = false;
  bool _saved = false;

  bool get _isEditing => widget.companyId != null;

  List<TextEditingController> get _controllers => [
    _legalName,
    _tradeName,
    _cnpj,
    _stateRegistration,
    _postalCode,
    _street,
    _number,
    _complement,
    _district,
    _city,
    _phone,
    _email,
    _repName,
    _repCpf,
    _repPhone,
    _repEmail,
  ];

  DateTime get _today => ref.read(clockProvider)().toLocal();

  @override
  void initState() {
    super.initState();
    final id = widget.companyId;
    if (id != null) {
      _loading = true;
      _load(id);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load(String id) async {
    final company = await ref.read(companyRepositoryProvider).findById(id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (company == null) {
        _notFound = true;
        return;
      }
      _fill(company.toInput());
    });
  }

  /// Preenche os campos com os documentos formatados, para bater com as
  /// máscaras.
  void _fill(CompanyInput input) {
    _initial = input;
    final address = input.address;
    final rep = input.legalRepresentative;
    String? fmt(String? v, String Function(String) format) =>
        v == null ? null : format(v);
    _legalName.text = input.legalName;
    _tradeName.text = input.tradeName ?? '';
    _cnpj.text = fmt(input.cnpj, formatCnpj) ?? '';
    _stateRegistration.text = input.stateRegistration ?? '';
    _postalCode.text = fmt(address.postalCode, formatPostalCode) ?? '';
    _street.text = address.street ?? '';
    _number.text = address.number ?? '';
    _complement.text = address.complement ?? '';
    _district.text = address.district ?? '';
    _city.text = address.city ?? '';
    _state = address.state;
    _phone.text = fmt(input.phone, formatPhone) ?? '';
    _email.text = input.email ?? '';
    _repName.text = rep.name ?? '';
    _repCpf.text = fmt(rep.cpf, formatCpf) ?? '';
    _repPhone.text = fmt(rep.phone, formatPhone) ?? '';
    _repEmail.text = rep.email ?? '';
    _modules
      ..clear()
      ..addAll(input.enabledModules);
    _registrations
      ..clear()
      ..addAll(input.registrations);
  }

  /// Texto com máscara: o repositório normaliza.
  CompanyInput _currentInput() => CompanyInput(
    legalName: _legalName.text,
    tradeName: _tradeName.text,
    cnpj: _cnpj.text,
    stateRegistration: _stateRegistration.text,
    address: Address(
      street: _street.text,
      number: _number.text,
      complement: _complement.text,
      district: _district.text,
      city: _city.text,
      state: _state,
      postalCode: _postalCode.text,
    ),
    phone: _phone.text,
    email: _email.text,
    legalRepresentative: LegalRepresentative(
      name: _repName.text,
      cpf: _repCpf.text,
      phone: _repPhone.text,
      email: _repEmail.text,
    ),
    enabledModules: {..._modules},
    registrations: {..._registrations},
  );

  bool get _isDirty =>
      normalizeCompanyInput(_currentInput()) != normalizeCompanyInput(_initial);

  /// Qualquer edição: recalcula `_isDirty` e tira o erro do campo.
  void _changed([CompanyField? field]) => setState(() => _errors.remove(field));

  void _showErrors(List<CompanyFieldError> errors, CompanyInput normalized) {
    setState(() {
      _errors
        ..clear()
        ..addAll({
          for (final e in errors) e.field: companyFieldMessage(e, normalized),
        });
    });
    _scrollToFirstError();
  }

  void _scrollToFirstError() {
    final first = CompanyField.values.firstWhere(_errors.containsKey);
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
    final input = _currentInput();
    final normalized = normalizeCompanyInput(input);
    final errors = validateCompany(normalized);
    if (errors.isNotEmpty) return _showErrors(errors, normalized);

    setState(() => _saving = true);
    final repo = ref.read(companyRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = widget.companyId;
      final company = id == null
          ? await repo.create(input)
          : await repo.update(id, input);
      if (!mounted) return;
      setState(() => _saved = true);
      messenger.showSnackBar(const SnackBar(content: Text('Empresa salva')));
      if (id == null) {
        context.go(AppRoutes.company(company.id));
      } else {
        context.pop();
      }
    } on DuplicateCnpjException {
      if (!mounted) return;
      setState(() => _errors[CompanyField.cnpj] = duplicateCnpjMessage);
      _scrollToFirstError();
    } on CompanyValidationException catch (e) {
      if (!mounted) return;
      _showErrors(e.errors, normalized);
    } on CompanyNotFoundException {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Empresa não encontrada')),
      );
      context.go(AppRoutes.companies);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDiscard() async {
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

  Future<void> _editRegistration(Authority authority) async {
    final result = await showRegistrationSheet(
      context,
      authority: authority,
      current: _registrations[authority],
      today: _today,
    );
    if (result == null) return;
    setState(() {
      final registration = result.registration;
      if (registration == null) {
        _registrations.remove(authority);
      } else {
        _registrations[authority] = registration;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar empresa' : 'Nova empresa';
    final ready = !_loading && !_notFound;
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
          title: BandTitle(title: title),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notFound
            ? EmptyState(
                icon: Icons.apartment_outlined,
                title: 'Empresa não encontrada',
                message: 'Ela pode ter sido excluída.',
                actionLabel: 'Voltar',
                onAction: () => context.go(AppRoutes.companies),
              )
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
                      child: const Text('Salvar empresa'),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _form(BuildContext context) {
    final today = _today;
    // Todos os campos são montados de uma vez (não é ListView) para que
    // `Scrollable.ensureVisible` alcance o primeiro campo com erro.
    return SingleChildScrollView(
      padding: AppSpacing.screen.copyWith(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Só a razão social é obrigatória. O resto pode ser preenchido '
            'depois.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _section('Identificação', [
            _field(
              CompanyField.legalName,
              label: 'Razão social',
              controller: _legalName,
              required: true,
              hint: 'Ex.: Indústria Alfa Ltda',
              capitalization: TextCapitalization.words,
            ),
            _field(
              null,
              label: 'Nome fantasia',
              controller: _tradeName,
              hint: 'Como aparece nas listas',
              capitalization: TextCapitalization.words,
            ),
            _field(
              CompanyField.cnpj,
              label: 'CNPJ',
              controller: _cnpj,
              formatter: CnpjInputFormatter(),
              capitalization: TextCapitalization.characters,
              tabular: true,
            ),
            _field(
              null,
              label: 'Inscrição estadual',
              controller: _stateRegistration,
              hint: 'Opcional',
              capitalization: TextCapitalization.characters,
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _section('Endereço', [
            _field(
              CompanyField.postalCode,
              label: 'CEP',
              controller: _postalCode,
              hint: '00000-000',
              keyboardType: TextInputType.number,
              formatter: PostalCodeInputFormatter(),
              tabular: true,
            ),
            _field(
              null,
              label: 'Logradouro',
              controller: _street,
              hint: 'Rua, avenida…',
            ),
            _pair(
              _field(null, label: 'Número', controller: _number, hint: 'Nº'),
              _field(
                null,
                label: 'Complemento',
                controller: _complement,
                hint: 'Sala, galpão…',
              ),
              1,
              2,
            ),
            _field(null, label: 'Bairro', controller: _district),
            _pair(
              _field(null, label: 'Cidade', controller: _city),
              // TODO(RF-EMP-04): UF sem valor padrão (não pré-selecionar CE).
              AppDropdownField<BrazilianState>(
                label: 'UF',
                value: _state,
                items: BrazilianState.values,
                itemLabel: (s) => '${s.code} · ${s.label}',
                selectedLabel: (s) => s.code,
                onChanged: (s) => setState(() => _state = s),
              ),
              3,
              1,
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _section('Contato', [
            _phoneField(CompanyField.phone, _phone),
            _field(
              CompanyField.email,
              label: 'E-mail',
              controller: _email,
              hint: 'contato@empresa.com.br',
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _section('Responsável legal', [
            _field(
              null,
              label: 'Nome',
              controller: _repName,
              capitalization: TextCapitalization.words,
            ),
            _field(
              CompanyField.legalRepCpf,
              label: 'CPF',
              controller: _repCpf,
              hint: '000.000.000-00',
              keyboardType: TextInputType.number,
              formatter: CpfInputFormatter(),
              tabular: true,
            ),
            _phoneField(CompanyField.legalRepPhone, _repPhone),
            _field(
              CompanyField.legalRepEmail,
              label: 'E-mail',
              controller: _repEmail,
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          // Módulos e órgãos são independentes (C15).
          SectionCard(
            title: 'Módulos',
            description: 'Só os módulos ligados aparecem para a empresa.',
            children: [
              for (final module in ModuleType.values)
                SwitchRow(
                  leadingIcon: module.icon,
                  title: module.label,
                  subtitle: module.description,
                  value: _modules.contains(module),
                  onChanged: (on) => setState(
                    () => on ? _modules.add(module) : _modules.remove(module),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Órgãos',
            description: 'Toque em um órgão para informar o registro.',
            children: [
              for (final authority in Authority.values)
                _registrationRow(authority, today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registrationRow(Authority authority, DateTime today) {
    final display = registrationDisplay(_registrations[authority], today);
    return NavRow(
      title: authority.label,
      trailing: StatusText(label: display.label, tone: display.tone),
      onTap: () => _editRegistration(authority),
    );
  }

  /// Seção com os campos num card, com espaço entre eles.
  Widget _section(String title, List<Widget> fields) => SectionCard(
    title: title,
    children: [
      Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              fields[i],
            ],
          ],
        ),
      ),
    ],
  );

  Widget _pair(Widget a, Widget b, int flexA, int flexB) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: flexA, child: a),
      const SizedBox(width: AppSpacing.md),
      Expanded(flex: flexB, child: b),
    ],
  );

  Widget _phoneField(CompanyField field, TextEditingController controller) =>
      _field(
        field,
        label: 'Telefone',
        controller: controller,
        hint: '(00) 00000-0000',
        keyboardType: TextInputType.phone,
        formatter: PhoneInputFormatter(),
        tabular: true,
      );

  /// `field != null`: campo validável, com erro e chave para rolar até ele.
  Widget _field(
    CompanyField? field, {
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    TextInputFormatter? formatter,
    TextCapitalization capitalization = TextCapitalization.none,
    bool tabular = false,
  }) => AppTextField(
    key: field == null ? null : _fieldKeys[field],
    label: label,
    controller: controller,
    hint: hint,
    required: required,
    errorText: field == null ? null : _errors[field],
    keyboardType: keyboardType,
    inputFormatters: formatter == null ? null : [formatter],
    textCapitalization: capitalization,
    textInputAction: TextInputAction.next,
    tabular: tabular,
    onChanged: (_) => _changed(field),
  );
}

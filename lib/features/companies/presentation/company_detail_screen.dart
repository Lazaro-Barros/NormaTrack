import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/destructive_button.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/info_row.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../app/widgets/status_text.dart';
import '../../../core/providers.dart';
import '../../../core/utils/br_documents.dart';
import '../../deadlines/domain/deadline.dart';
import '../../deadlines/presentation/deadline_labels.dart';
import '../../deadlines/presentation/deadline_providers.dart';
import '../data/local_company_repository.dart' show companyRepositoryProvider;
import '../domain/authority.dart';
import '../domain/company.dart';
import '../domain/company_repository.dart';
import '../domain/module_type.dart';
import 'company_labels.dart';
import 'company_providers.dart';

/// Detalhe da empresa: módulos, órgãos, dados e arquivar (RF-EMP-01/03/05).
class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(companyProvider(companyId));
    return switch (company) {
      AsyncValue(value: final Company company) => _Detail(company: company),
      AsyncValue(hasValue: true) => _missing(context, 'Empresa não encontrada'),
      AsyncValue(hasError: true) => _missing(
        context,
        'Não foi possível carregar a empresa',
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _missing(BuildContext context, String title) => Scaffold(
    appBar: AppBar(),
    body: EmptyState(
      icon: Icons.apartment_outlined,
      title: title,
      message: 'Ela pode ter sido excluída.',
      actionLabel: 'Voltar',
      onAction: () => context.go(AppRoutes.companies),
    ),
  );
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.read(clockProvider)().toLocal();
    final cnpj = company.cnpj;
    final subtitle = [
      if (cnpj != null) 'CNPJ ${formatCnpj(cnpj)}',
      if (company.isArchived) 'Arquivada',
    ].join(' · ');
    void edit() => context.go(AppRoutes.editCompany(company.id));
    final deadlines =
        ref.watch(companyDeadlinesProvider(company.id)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        // TODO(RF-PRZ-05): resumo de situação (pílulas) na faixa.
        title: BandTitle(
          title: company.displayName,
          subtitle: subtitle.isEmpty ? null : subtitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar empresa',
            onPressed: edit,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screen.copyWith(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        children: [
          _modules(context, deadlines, today, edit),
          const SizedBox(height: AppSpacing.lg),
          _authorities(today, edit),
          const SizedBox(height: AppSpacing.lg),
          _data(context),
          const SizedBox(height: AppSpacing.lg),
          // TODO(RF-REL-01): botão "Gerar relatório" (tonal) quando houver
          // relatórios.
          if (company.isArchived)
            OutlinedButton.icon(
              icon: const Icon(Icons.unarchive_outlined),
              label: const Text('Desarquivar'),
              onPressed: () => _unarchive(context, ref),
            )
          else
            DestructiveButton(
              icon: Icons.archive_outlined,
              label: 'Arquivar',
              onPressed: () => _archive(context, ref),
            ),
        ],
      ),
    );
  }

  /// Cada módulo abre a tela dele e mostra a pior situação dos prazos em
  /// aberto (RF-EMP-03).
  Widget _modules(
    BuildContext context,
    List<Deadline> deadlines,
    DateTime today,
    VoidCallback edit,
  ) {
    final modules = ModuleType.values.where(company.hasModule).toList();
    return SectionCard(
      title: 'Módulos',
      children: [
        for (final module in modules)
          _moduleRow(context, module, deadlines, today),
        if (modules.isEmpty) NavRow(title: 'Habilitar módulos', onTap: edit),
      ],
    );
  }

  Widget _moduleRow(
    BuildContext context,
    ModuleType module,
    List<Deadline> deadlines,
    DateTime today,
  ) {
    final pending = modulePending(
      deadlines.where((d) => d.module == module),
      today,
    );
    return NavRow(
      leadingIcon: module.icon,
      title: module.label,
      trailing: pending == null
          ? null
          : StatusText(label: pending.label, tone: pending.tone),
      onTap: () => context.go(AppRoutes.module(company.id, module)),
    );
  }

  Widget _authorities(DateTime today, VoidCallback edit) {
    final registrations = [
      for (final a in Authority.values) ?company.registrationFor(a),
    ];
    final n = registrations.length;
    final total = Authority.values.length;
    return SectionCard(
      title: 'Órgãos',
      caption: '$n de $total se aplicam',
      children: [
        for (final r in registrations) _registrationRow(r, today),
        NavRow(
          title: n > 0 ? 'Ver todos os $total órgãos' : 'Informar órgãos',
          onTap: edit,
        ),
      ],
    );
  }

  Widget _registrationRow(AuthorityRegistration r, DateTime today) {
    final number = r.registrationNumber;
    final subtitle = [if (number != null) 'Nº $number', ?r.notes].join(' · ');
    final display = registrationDisplay(r, today);
    return NavRow(
      title: r.authority.label,
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailing: StatusText(label: display.label, tone: display.tone),
    );
  }

  Widget _data(BuildContext context) {
    final address = company.address;
    final rep = company.legalRepresentative;
    final postalCode = address.postalCode;
    final repCpf = rep.cpf;
    String? phone(String? p) => p == null ? null : formatPhone(p);
    String? nonEmpty(String s) => s.isEmpty ? null : s;

    final street = [?address.street, ?address.number].join(', ');
    final complement = address.complement;
    final addressLines = [
      ?nonEmpty(complement == null ? street : '$street - $complement'),
      ?nonEmpty([?address.district, ?cityState(address)].join(' · ')),
      if (postalCode != null) 'CEP ${formatPostalCode(postalCode)}',
    ];
    final repLines = [
      ?rep.name,
      if (repCpf != null) 'CPF ${formatCpf(repCpf)}',
      ?phone(rep.phone),
      ?rep.email,
    ];
    final tradeName = company.tradeName;
    final stateRegistration = company.stateRegistration;
    final companyPhone = phone(company.phone);
    final email = company.email;

    final rows = [
      // O título já mostra o displayName: a razão social só se repete aqui
      // quando há nome fantasia.
      if (tradeName != null)
        InfoRow(label: 'Razão social', lines: [company.legalName]),
      if (stateRegistration != null)
        InfoRow(label: 'Inscrição estadual', lines: [stateRegistration]),
      if (addressLines.isNotEmpty)
        InfoRow(label: 'Endereço', lines: addressLines),
      if (companyPhone != null)
        InfoRow(label: 'Telefone', lines: [companyPhone]),
      if (email != null) InfoRow(label: 'E-mail', lines: [email]),
      if (repLines.isNotEmpty)
        InfoRow(label: 'Responsável legal', lines: repLines),
    ];
    return SectionCard(
      title: 'Dados da empresa',
      children: rows.isNotEmpty
          ? rows
          : [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Só a razão social foi informada.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Arquivar empresa?',
      message:
          'Ela sai da lista de ativas e pode ser desarquivada depois, em '
          'Arquivadas.',
      confirmLabel: 'Arquivar',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    // Pegos antes do pop: depois dele esta tela não existe mais.
    final repo = ref.read(companyRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final id = company.id;
    try {
      await repo.archive(id);
    } on CompanyNotFoundException {
      _notFound(messenger);
      return;
    }
    if (!context.mounted) return;
    context.canPop() ? context.pop() : context.go(AppRoutes.companies);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Empresa arquivada'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => repo.unarchive(id),
        ),
      ),
    );
  }

  Future<void> _unarchive(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(companyRepositoryProvider).unarchive(company.id);
    } on CompanyNotFoundException {
      _notFound(messenger);
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Empresa desarquivada')),
    );
  }

  void _notFound(ScaffoldMessengerState messenger) => messenger.showSnackBar(
    const SnackBar(
      content: Text('Não foi possível concluir. A empresa não foi encontrada.'),
    ),
  );
}

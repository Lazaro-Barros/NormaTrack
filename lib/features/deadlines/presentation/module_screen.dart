import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/deadline_card.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../core/providers.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/company_labels.dart';
import '../../companies/presentation/company_providers.dart';
import '../domain/deadline.dart';
import '../domain/deadline_category.dart';
import 'deadline_labels.dart';
import 'deadline_providers.dart';

/// Tela de um módulo da empresa: prazos em aberto por categoria
/// (RF-AMB-01/05/06, RF-PCT-01). Lançamentos e relatórios entram nas fases 2
/// e 3.
class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.companyId, required this.slug});

  final String companyId;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = moduleFromSlug(slug);
    if (module == null) {
      return _message(
        icon: Icons.help_outline,
        title: 'Módulo não encontrado',
        message: 'Volte e escolha o módulo de novo.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.company(companyId)),
      );
    }
    return switch (ref.watch(companyProvider(companyId))) {
      AsyncValue(value: final Company company) =>
        company.hasModule(module)
            ? _Deadlines(company: company, module: module)
            : _message(
                icon: module.icon,
                title: 'Módulo desligado',
                message:
                    'Ligue o módulo no cadastro da empresa para ver os '
                    'prazos.',
                actionLabel: 'Editar empresa',
                onAction: () => context.go(AppRoutes.editCompany(companyId)),
              ),
      AsyncValue(hasValue: true) || AsyncValue(hasError: true) => _message(
        icon: Icons.apartment_outlined,
        title: 'Empresa não encontrada',
        message: 'Ela pode ter sido excluída.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.companies),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) => Scaffold(
    appBar: AppBar(),
    body: EmptyState(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

class _Deadlines extends ConsumerWidget {
  const _Deadlines({required this.company, required this.module});

  final Company company;
  final ModuleType module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.read(clockProvider)().toLocal();
    final deadlines = ref.watch(
      moduleDeadlinesProvider((companyId: company.id, module: module)),
    );
    void create() => context.go(AppRoutes.newDeadline(company.id, module));
    final list = deadlines.value;

    return Scaffold(
      appBar: AppBar(
        title: BandTitle(title: module.label, subtitle: company.displayName),
      ),
      body: switch (deadlines) {
        _ when list != null && list.isEmpty => EmptyState(
          icon: module.icon,
          title: 'Nenhum prazo em aberto',
          message:
              'Cadastre licenças, laudos e manutenções para receber os '
              'alertas.',
          actionLabel: 'Cadastrar prazo',
          onAction: create,
        ),
        _ when list != null => _list(context, list, today),
        AsyncValue(hasError: true) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os prazos',
          message: 'Tente abrir a tela de novo.',
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novo prazo'),
        onPressed: create,
      ),
    );
  }

  Widget _list(BuildContext context, List<Deadline> list, DateTime today) {
    final text = Theme.of(context).textTheme;
    final byCategory = list.groupListsBy((d) => d.category);
    final categories = DeadlineCategory.values.where(byCategory.containsKey);
    return ListView(
      padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: 88),
      children: [
        for (final (i, category) in categories.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(categoryPluralLabel(category), style: text.titleMedium),
          ),
          for (final d in byCategory[category]!) ...[
            const SizedBox(height: AppSpacing.sm),
            _card(context, d, today),
          ],
        ],
      ],
    );
  }

  Widget _card(BuildContext context, Deadline d, DateTime today) {
    final display = deadlineDisplay(d, today);
    return DeadlineCard(
      date: d.dueDate,
      showYear: d.dueDate.year != today.year,
      title: d.title,
      subtitle: deadlineSubtitle(d),
      tone: display.tone,
      statusLead: display.lead,
      statusText: display.text,
      // TODO(RF-PRZ-04): abrir o detalhe do prazo (task 008).
      onTap: () => context.go(AppRoutes.editDeadline(company.id, module, d.id)),
    );
  }
}

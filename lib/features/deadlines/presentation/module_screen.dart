import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_segmented_button.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/deadline_card.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../core/today.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/company_labels.dart';
import '../../companies/presentation/module_gate.dart';
import '../../measurements/presentation/monitoring_section.dart';
import '../domain/deadline.dart';
import '../domain/deadline_category.dart';
import 'deadline_labels.dart';
import 'deadline_providers.dart';

/// Tela de um módulo da empresa: prazos em aberto por categoria
/// (RF-AMB-01/05/06, RF-PCT-01). Lançamentos e relatórios entram nas fases 2
/// e 3.
class ModuleScreen extends StatelessWidget {
  const ModuleScreen({super.key, required this.companyId, required this.slug});

  final String companyId;
  final String slug;

  @override
  Widget build(BuildContext context) => ModuleGate(
    companyId: companyId,
    slug: slug,
    builder: (context, company, module) =>
        _Deadlines(company: company, module: module),
  );
}

class _Deadlines extends ConsumerStatefulWidget {
  const _Deadlines({required this.company, required this.module});

  final Company company;
  final ModuleType module;

  @override
  ConsumerState<_Deadlines> createState() => _DeadlinesState();
}

class _DeadlinesState extends ConsumerState<_Deadlines> {
  bool _closed = false;

  Company get company => widget.company;
  ModuleType get module => widget.module;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final key = (companyId: company.id, module: module);
    final deadlines = _closed
        ? ref.watch(moduleClosedDeadlinesProvider(key))
        : ref.watch(moduleDeadlinesProvider(key));
    void create() => context.go(AppRoutes.newDeadline(company.id, module));
    // Encerrados: do vencimento mais recente para o mais antigo.
    final list = _closed ? deadlines.value?.reversed.toList() : deadlines.value;

    return Scaffold(
      appBar: AppBar(
        title: BandTitle(title: module.label, subtitle: company.displayName),
        bottom: PreferredSize(
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
            child: BandSegmentedButton<bool>(
              segments: const [(false, 'Em aberto'), (true, 'Encerrados')],
              selected: _closed,
              onChanged: (v) => setState(() => _closed = v),
            ),
          ),
        ),
      ),
      body: switch (deadlines) {
        _ when list != null && list.isEmpty && _closed => const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Nenhum prazo encerrado',
          message: 'Prazos concluídos ou cancelados aparecem aqui.',
        ),
        _ when list != null && list.isEmpty && !_hasMonitoring => EmptyState(
          icon: module.icon,
          title: 'Nenhum prazo em aberto',
          message:
              'Cadastre licenças, laudos e manutenções para receber os '
              'alertas.',
          actionLabel: 'Cadastrar prazo',
          onAction: create,
        ),
        _ when list != null && _closed => _flat(context, list, today),
        _ when list != null => _list(context, list, today),
        AsyncValue(hasError: true) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os prazos',
          message: 'Tente abrir a tela de novo.',
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: _closed
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Novo prazo'),
              onPressed: create,
            ),
    );
  }

  Widget _flat(BuildContext context, List<Deadline> list, DateTime today) =>
      ListView(
        padding: AppSpacing.screen.copyWith(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        children: [
          for (final (i, d) in list.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _card(context, d, today),
          ],
        ],
      );

  /// Só o Ambiental tem automonitoramento (RF-AMB-02), na vista "Em aberto".
  bool get _hasMonitoring => module == ModuleType.environmental && !_closed;

  Widget _list(BuildContext context, List<Deadline> list, DateTime today) {
    final text = Theme.of(context).textTheme;
    final byCategory = list.groupListsBy((d) => d.category);
    final categories = DeadlineCategory.values.where(byCategory.containsKey);
    return ListView(
      padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: 88),
      children: [
        if (_hasMonitoring) ...[
          MonitoringSection(companyId: company.id, today: today),
          const SizedBox(height: AppSpacing.lg),
          if (list.isEmpty)
            EmptyState(
              icon: module.icon,
              title: 'Nenhum prazo em aberto',
              message:
                  'Cadastre licenças, laudos e manutenções para receber os '
                  'alertas.',
              actionLabel: 'Cadastrar prazo',
              onAction: () =>
                  context.go(AppRoutes.newDeadline(company.id, module)),
              inline: true,
            ),
        ],
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
      onTap: () => context.go(AppRoutes.deadline(company.id, module, d.id)),
    );
  }
}

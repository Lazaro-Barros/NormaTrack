import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/deadline_card.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/stat_tile.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../core/providers.dart';
import '../domain/deadline.dart';
import '../domain/deadline_status.dart';
import '../domain/deadline_summary.dart';
import 'deadline_labels.dart';
import 'deadline_providers.dart';

/// Painel (aba inicial): contagem por situação e próximos vencimentos de todas
/// as empresas (RF-PRZ-05). Tocar num tile filtra a lista; tocar de novo limpa.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _situations = [
    DeadlineSituation.overdue,
    DeadlineSituation.dueSoon,
    DeadlineSituation.current,
  ];

  DeadlineSituation? _filter;

  void _toggle(DeadlineSituation s) =>
      setState(() => _filter = _filter == s ? null : s);

  @override
  Widget build(BuildContext context) {
    final today = ref.read(clockProvider)().toLocal();
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final names = ref.watch(companyNamesProvider);
    final all = deadlines.value;
    final counts = all == null
        ? const SituationCounts()
        : SituationCounts.of(all, today);

    return Scaffold(
      appBar: AppBar(
        title: const BandTitle(title: 'Painel', large: true),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(StatTile.height + AppSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                for (final (i, s) in _situations.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatTile(
                      tone: deadlineTone(s),
                      count: counts.of(s),
                      label: situationPluralLabel(s),
                      selected: _filter == s,
                      onTap: () => _toggle(s),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: switch ((deadlines, names)) {
        (AsyncValue(hasError: true), _) ||
        (_, AsyncValue(hasError: true)) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os prazos',
          message: 'Tente abrir a tela de novo.',
        ),
        (
          AsyncValue(value: final List<Deadline> list),
          AsyncValue(value: final Map<String, String> names),
        ) =>
          _body(context, list, names, today),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(
    BuildContext context,
    List<Deadline> all,
    Map<String, String> names,
    DateTime today,
  ) {
    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.space_dashboard_outlined,
        title: 'Nenhum prazo em aberto',
        message:
            'Cadastre prazos no módulo de uma empresa para acompanhar os '
            'vencimentos aqui.',
        actionLabel: 'Ver empresas',
        onAction: () => context.go(AppRoutes.companies),
      );
    }
    final filter = _filter;
    final list = filterBySituation(all, today, filter);
    if (list.isEmpty && filter != null) {
      return EmptyState(
        icon: StatusChip.iconFor(deadlineTone(filter)),
        title: _emptyFilterTitle(filter),
        message: 'Toque de novo no filtro para ver todos os prazos.',
      );
    }
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: AppSpacing.screen.copyWith(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('Próximos vencimentos', style: text.titleMedium),
        ),
        for (final d in list) ...[
          const SizedBox(height: AppSpacing.sm),
          _card(context, d, names, today),
        ],
      ],
    );
  }

  Widget _card(
    BuildContext context,
    Deadline d,
    Map<String, String> names,
    DateTime today,
  ) {
    final display = deadlineDisplay(d, today);
    return DeadlineCard(
      date: d.dueDate,
      showYear: d.dueDate.year != today.year,
      title: d.title,
      // TODO(RF-PRZ-05): contexto do card = nome da empresa, sem categoria nem
      // órgão (C23).
      subtitle: names[d.companyId],
      tone: display.tone,
      statusLead: display.lead,
      statusText: display.text,
      // TODO(RF-PRZ-05): `push` para voltar ao Painel com o filtro (C23).
      onTap: () =>
          context.push(AppRoutes.deadline(d.companyId, d.module, d.id)),
    );
  }

  static String _emptyFilterTitle(DeadlineSituation s) => switch (s) {
    DeadlineSituation.overdue => 'Nenhum prazo vencido',
    DeadlineSituation.dueSoon => 'Nenhum prazo a vencer',
    _ => 'Nenhum prazo vigente',
  };
}

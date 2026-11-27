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
import '../../../core/today.dart';
import '../../measurements/domain/pending_launch.dart';
import '../../measurements/presentation/measurement_providers.dart';
import '../../measurements/presentation/pending_section.dart';
import '../domain/deadline.dart';
import '../domain/deadline_status.dart';
import '../domain/deadline_summary.dart';
import 'deadline_labels.dart';
import 'deadline_providers.dart';

/// Painel (aba inicial): contagem por situação, lançamentos pendentes e
/// próximos vencimentos de todas as empresas (RF-PRZ-05, RF-AMB-02). Tocar num
/// tile filtra os prazos e esconde as pendências; tocar de novo limpa.
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
    final today = ref.watch(todayProvider);
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final names = ref.watch(companyNamesProvider);
    final pending = ref.watch(pendingLaunchesProvider(today));
    final all = deadlines.value;
    final counts = all == null
        ? const SituationCounts()
        : SituationCounts.of(all, today);

    return Scaffold(
      appBar: AppBar(
        title: const BandTitle(title: 'Painel', large: true),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            StatTile.heightOf(context) + AppSpacing.lg,
          ),
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
      body: switch ((deadlines, names, pending)) {
        (AsyncValue(hasError: true), _, _) ||
        (_, AsyncValue(hasError: true), _) ||
        (_, _, AsyncValue(hasError: true)) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar o Painel',
          message: 'Tente abrir a tela de novo.',
        ),
        (
          AsyncValue(value: final List<Deadline> list),
          AsyncValue(value: final Map<String, String> names),
          AsyncValue(value: final List<PendingLaunch> pending),
        ) =>
          _body(context, list, _groups(pending, names), names, today),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  /// Grupos de empresas conhecidas, da pendência mais antiga para a mais nova;
  /// no mesmo período, pelo nome da empresa.
  static List<PendingGroup> _groups(
    List<PendingLaunch> pending,
    Map<String, String> names,
  ) {
    final groups = [
      for (final g in groupPendingLaunches(pending))
        if (names.containsKey(g.companyId)) g,
    ];
    // `sort` não é estável: desempata pelo contexto depois do nome.
    groups.sort((a, b) {
      final byStart = a.oldest.period.start.compareTo(b.oldest.period.start);
      if (byStart != 0) return byStart;
      final byName = names[a.companyId]!.compareTo(names[b.companyId]!);
      if (byName != 0) return byName;
      final byContext = a.context.index.compareTo(b.context.index);
      return byContext != 0
          ? byContext
          : a.frequency.index.compareTo(b.frequency.index);
    });
    return groups;
  }

  EmptyState _noDeadlines(BuildContext context, {bool inline = false}) =>
      EmptyState(
        icon: Icons.space_dashboard_outlined,
        title: 'Nenhum prazo em aberto',
        message:
            'Cadastre prazos no módulo de uma empresa para acompanhar os '
            'vencimentos aqui.',
        actionLabel: 'Ver empresas',
        onAction: () => context.go(AppRoutes.companies),
        inline: inline,
      );

  Widget _body(
    BuildContext context,
    List<Deadline> all,
    List<PendingGroup> groups,
    Map<String, String> names,
    DateTime today,
  ) {
    final filter = _filter;
    if (all.isEmpty && (groups.isEmpty || filter != null)) {
      return _noDeadlines(context);
    }
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
        if (filter == null && groups.isNotEmpty) ...[
          ...pendingSection(context, groups, names),
          const SizedBox(height: AppSpacing.lg),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('Próximos vencimentos', style: text.titleMedium),
        ),
        if (list.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _noDeadlines(context, inline: true),
        ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/info_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../app/widgets/status_banner.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_format.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/company_labels.dart';
import '../../companies/presentation/company_providers.dart';
import '../domain/deadline.dart';
import 'deadline_labels.dart';
import 'deadline_providers.dart';

/// Detalhe do prazo: situação em destaque, dados, histórico de ciclos e ações
/// (RF-PRZ-01/04, RF-AMB-06).
class DeadlineDetailScreen extends ConsumerWidget {
  const DeadlineDetailScreen({
    super.key,
    required this.companyId,
    required this.slug,
    required this.deadlineId,
  });

  final String companyId;
  final String slug;
  final String deadlineId;

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
    final company = ref.watch(companyProvider(companyId));
    if (company case AsyncValue(value: final Company c)) {
      return _Loaded(company: c, module: module, deadlineId: deadlineId);
    }
    if (company.hasValue || company.hasError) {
      return _message(
        icon: Icons.apartment_outlined,
        title: 'Empresa não encontrada',
        message: 'Ela pode ter sido excluída.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.companies),
      );
    }
    return const _Loading();
  }
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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: const Center(child: CircularProgressIndicator()),
  );
}

class _Loaded extends ConsumerWidget {
  const _Loaded({
    required this.company,
    required this.module,
    required this.deadlineId,
  });

  final Company company;
  final ModuleType module;
  final String deadlineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deadlineProvider(deadlineId));
    final d = async.value;
    if (d == null) {
      if (async.hasError) {
        return _message(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar o prazo',
          message: 'Tente abrir a tela de novo.',
          actionLabel: 'Voltar',
          onAction: () => context.go(AppRoutes.module(company.id, module)),
        );
      }
      if (!async.hasValue) return const _Loading();
    }
    if (d == null || d.companyId != company.id || d.module != module) {
      return _message(
        icon: Icons.event_busy_outlined,
        title: 'Prazo não encontrado',
        message: 'Ele pode ter sido excluído.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.module(company.id, module)),
      );
    }
    return _Detail(company: company, module: module, deadline: d);
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({
    required this.company,
    required this.module,
    required this.deadline,
  });

  final Company company;
  final ModuleType module;
  final Deadline deadline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.read(clockProvider)().toLocal();
    final d = deadline;
    final banner = deadlineBanner(d, today);
    final history = ref.watch(deadlineHistoryProvider(d.id)).value;

    return Scaffold(
      appBar: AppBar(
        title: BandTitle(
          title: d.title,
          subtitle: '${company.displayName} · ${module.label}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            StatusBanner.height + AppSpacing.lg,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: StatusBanner(
              tone: banner.tone,
              date: d.dueDate,
              showYear: d.dueDate.year != today.year,
              title: banner.title,
              message: banner.message,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: AppSpacing.screen.copyWith(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        children: [
          _dataCard(d),
          if (history != null && history.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Histórico',
              children: [
                for (final (i, cycle) in history.indexed)
                  _CycleTile(
                    index: i,
                    cycle: cycle,
                    previousDueDate: i + 1 < history.length
                        ? history[i + 1].dueDate
                        : null,
                    today: today,
                    isLast: i == history.length - 1,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dataCard(Deadline d) {
    final authority = d.authority;
    final dates = d.reminderDates;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: 'Categoria', lines: [d.category.label]),
          if (authority != null) ...[
            const Divider(),
            InfoRow(label: 'Órgão', lines: [authority.label]),
          ],
          const Divider(),
          InfoRow(
            label: 'Lembretes',
            lines: [
              for (final (i, days) in d.reminderDays.indexed)
                '${formatDate(dates[i])} · ${reminderLabel(days)}',
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleTile extends StatelessWidget {
  const _CycleTile({
    required this.index,
    required this.cycle,
    required this.previousDueDate,
    required this.today,
    required this.isLast,
  });

  final int index;
  final Deadline cycle;
  final DateTime? previousDueDate;
  final DateTime today;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final situation = cycle.situationOn(today);
    final tone = deadlineTone(situation);
    final style = StatusColors.of(context).resolve(tone);
    final title = cycleTitle(index);
    final range = cycleRangeLabel(cycle, previousDueDate);
    final label = situationLabel(situation);
    return Semantics(
      excludeSemantics: true,
      label: '$title, $range, $label',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: style.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                situationIcon(situation),
                size: 16,
                color: style.foreground,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: text.labelLarge?.fontWeight,
                    ),
                  ),
                  Text(range, style: AppTypography.tabular(text.bodyMedium)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(
              compact: true,
              tone: tone,
              label: label,
              icon: situationIcon(situation),
            ),
          ],
        ),
      ),
    );
  }
}

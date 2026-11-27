import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/pending_row.dart';
import '../domain/measurement_context.dart';
import '../domain/pending_launch.dart';
import 'measurement_labels.dart';

/// Tela que "Lançar" abre: o período pendente mais antigo do grupo.
String launchRouteFor(PendingGroup g) => switch (g.context) {
  MeasurementContext.noise => AppRoutes.noise(
    g.companyId,
    week: g.oldest.period.start,
  ),
  // TODO(RF-AMB-07): tela de lançamento da ETE/ETA na task 017.
  MeasurementContext.effluent ||
  MeasurementContext.water => AppRoutes.module(g.companyId, g.context.module),
};

IconData _iconFor(MeasurementContext c) => switch (c) {
  MeasurementContext.noise => Icons.graphic_eq,
  MeasurementContext.effluent ||
  MeasurementContext.water => Icons.water_drop_outlined,
};

/// Seção "Lançamentos pendentes" do Painel (RF-AMB-02, RF-PRZ-05): contagem no
/// título e uma `PendingRow` por grupo, na ordem recebida. Devolve os filhos
/// para entrar direto numa lista.
List<Widget> pendingSection(
  BuildContext context,
  List<PendingGroup> groups,
  Map<String, String> names,
) {
  final theme = Theme.of(context);
  final text = theme.textTheme;
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text('Lançamentos pendentes', style: text.titleMedium),
          ),
          Text(
            '${groups.length}',
            style: AppTypography.tabular(text.bodyMedium)
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    ),
    for (final g in groups) ...[
      const SizedBox(height: AppSpacing.sm),
      _row(context, g, names[g.companyId] ?? ''),
    ],
  ];
}

Widget _row(BuildContext context, PendingGroup g, String company) {
  final status = pendingGroupStatus(g);
  return PendingRow(
    icon: _iconFor(g.context),
    title: '${g.context.label} · $company',
    subtitle: pendingPeriodLabel(g.oldest.period),
    statusLabel: status.label,
    tone: status.tone,
    // `push`: voltar retorna ao Painel com o filtro (como os prazos, C23).
    onLaunch: () => context.push(launchRouteFor(g)),
  );
}

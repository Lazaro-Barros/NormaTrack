import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../app/widgets/status_text.dart';
import '../domain/measurement_context.dart';
import 'measurement_labels.dart';
import 'measurement_providers.dart';

/// Seção "Automonitoramento" do módulo Ambiental (RF-AMB-02): a linha
/// "Ruídos" com a situação dos lançamentos. Tocar abre a semana pendente mais
/// antiga, ou a atual.
class MonitoringSection extends ConsumerWidget {
  const MonitoringSection({
    super.key,
    required this.companyId,
    required this.today,
  });

  final String companyId;

  /// Data local, sem hora.
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(noisePointsProvider(companyId)).value;
    final pending = ref
        .watch(
          companyPendingLaunchesProvider((companyId: companyId, today: today)),
        )
        .value;
    final active = points?.where((p) => !p.isArchived).length;
    final noise = [
      ...?pending?.where((p) => p.context == MeasurementContext.noise),
    ];
    final status = active == null || pending == null
        ? null
        : monitoringStatus(noise, active);
    final oldest = noise
        .map((p) => p.period)
        .sortedBy((p) => p.start)
        .firstOrNull;
    return SectionCard(
      title: 'Automonitoramento',
      children: [
        NavRow(
          leadingIcon: Icons.graphic_eq,
          title: 'Ruídos',
          subtitle: active == null || active == 0
              ? null
              : pointsSubtitle(active),
          // Até 40% da tela: a situação longa ("2 semanas atrasadas") quebra
          // a linha em vez de estourar com a fonte do sistema grande.
          trailing: status == null
              ? null
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.4,
                  ),
                  child: StatusText(label: status.label, tone: status.tone),
                ),
          onTap: () =>
              context.go(AppRoutes.noise(companyId, week: oldest?.start)),
        ),
      ],
    );
  }
}

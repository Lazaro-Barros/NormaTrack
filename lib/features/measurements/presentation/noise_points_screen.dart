import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../core/providers.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/module_gate.dart';
import '../data/local_measurement_repository.dart';
import '../domain/measurement_context.dart';
import '../domain/measurement_frequency.dart';
import '../domain/measurement_parameter.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_validation.dart';
import 'measurement_labels.dart';
import 'measurement_providers.dart';
import 'point_sheet.dart';

/// Pontos de medição de ruído da empresa (RF-AMB-02): ativos e desativados,
/// cadastro e edição numa sheet.
class NoisePointsScreen extends StatelessWidget {
  const NoisePointsScreen({
    super.key,
    required this.companyId,
    required this.slug,
  });

  final String companyId;
  final String slug;

  @override
  Widget build(BuildContext context) => ModuleGate(
    companyId: companyId,
    slug: slug,
    only: ModuleType.environmental,
    builder: (context, company, _) => _NoisePoints(company: company),
  );
}

class _NoisePoints extends ConsumerWidget {
  const _NoisePoints({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(noisePointsProvider(company.id));
    final list = points.value;
    final active = [...?list?.where((p) => !p.isArchived)];
    final archived = [...?list?.where((p) => p.isArchived)];
    void create() => openPointSheet(context, ref, company.id);

    return Scaffold(
      appBar: AppBar(
        title: BandTitle(
          title: 'Pontos de medição',
          subtitle: company.displayName,
        ),
      ),
      body: switch (points) {
        _ when list != null && list.isEmpty => EmptyState(
          icon: Icons.graphic_eq,
          title: 'Nenhum ponto de medição',
          message:
              'Cadastre os lugares onde o ruído é medido, como o portão ou '
              'a divisa do terreno.',
          actionLabel: 'Cadastrar ponto',
          onAction: create,
        ),
        _ when list != null => ListView(
          padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: 88),
          children: [
            if (active.isNotEmpty)
              SectionCard(
                title: 'Ativos',
                caption: '${active.length}',
                children: [
                  for (final p in active)
                    NavRow(
                      title: p.name,
                      subtitle: pointLimitLabel(p),
                      onTap: () =>
                          openPointSheet(context, ref, company.id, current: p),
                    ),
                ],
              ),
            if (active.isNotEmpty && archived.isNotEmpty)
              const SizedBox(height: AppSpacing.lg),
            if (archived.isNotEmpty)
              SectionCard(
                title: 'Desativados',
                children: [
                  for (final p in archived)
                    NavRow(
                      title: p.name,
                      subtitle: 'Desativado',
                      onTap: () =>
                          openPointSheet(context, ref, company.id, current: p),
                    ),
                ],
              ),
          ],
        ),
        AsyncValue(hasError: true) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os pontos',
          message: 'Tente abrir a tela de novo.',
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: active.isEmpty && archived.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Novo ponto'),
              onPressed: create,
            ),
    );
  }
}

/// Abre a sheet do ponto e executa o que ela pedir, com SnackBar. Usado pela
/// tela de pontos e pelo lançamento (cadastro do primeiro ponto).
Future<void> openPointSheet(
  BuildContext context,
  WidgetRef ref,
  String companyId, {
  MeasurementParameter? current,
}) async {
  final repo = ref.read(measurementRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  const noise = MeasurementContext.noise;
  void snack(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  Future<String?> save(String name, double? limitMax) async {
    try {
      if (current == null) {
        final today = ref.read(clockProvider)().toLocal();
        // TODO(RF-AMB-02): o ponto cobra a partir da semana do cadastro (C26).
        await repo.createParameter(
          companyId,
          noise,
          MeasurementParameterInput(
            name: name,
            unit: noise.defaultUnit,
            frequency: MeasurementFrequency.weekly,
            startDate: DateTime(today.year, today.month, today.day),
            limitMax: limitMax,
          ),
        );
      } else {
        final input = current.toInput();
        await repo.updateParameter(
          current.id,
          MeasurementParameterInput(
            name: name,
            unit: input.unit,
            frequency: input.frequency,
            startDate: input.startDate,
            limitMin: input.limitMin,
            limitMax: limitMax,
          ),
        );
      }
      return null;
    } on MeasurementValidationException catch (e) {
      final nameError = e.parameterErrors
          .where((x) => x.field == ParameterField.name)
          .firstOrNull;
      return switch (nameError?.type) {
        ParameterFieldErrorType.duplicate => 'Já existe um ponto com esse nome',
        ParameterFieldErrorType.required => 'Informe o nome',
        _ => 'Confira os dados do ponto',
      };
    } on MeasurementException {
      return 'Não foi possível salvar. Tente de novo.';
    }
  }

  final action = await showPointSheet(
    context,
    current: current,
    unit: noise.defaultUnit ?? '',
    onSave: save,
  );
  if (action == null || current == null && action != PointSheetAction.saved) {
    return;
  }
  switch (action) {
    case PointSheetAction.saved:
      snack(current == null ? 'Ponto cadastrado' : 'Ponto atualizado');
    case PointSheetAction.archive:
      await repo.archiveParameter(current!.id);
      snack('Ponto desativado');
    case PointSheetAction.unarchive:
      await repo.unarchiveParameter(current!.id);
      snack('Ponto reativado');
    case PointSheetAction.delete:
      if (!context.mounted) return;
      final confirmed = await showConfirmDialog(
        context,
        title: 'Excluir ponto?',
        message:
            'As medições deste ponto também serão excluídas. Isso não pode '
            'ser desfeito.',
        confirmLabel: 'Excluir',
        destructive: true,
      );
      if (!confirmed) return;
      await repo.deleteParameter(current!.id);
      snack('Ponto excluído');
  }
}

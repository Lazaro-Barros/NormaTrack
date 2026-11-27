import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/formatters/decimal_input_formatter.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/app_action_bar.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/measurement_input_row.dart';
import '../../../app/widgets/period_navigator.dart';
import '../../../app/widgets/section_card.dart';
import '../../../core/today.dart';
import '../../../core/utils/date_format.dart';
import '../../companies/domain/company.dart';
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/module_gate.dart';
import '../data/local_measurement_repository.dart';
import '../domain/measurement.dart';
import '../domain/measurement_context.dart';
import '../domain/measurement_frequency.dart';
import '../domain/measurement_parameter.dart';
import '../domain/measurement_period.dart';
import '../domain/measurement_repository.dart';
import '../domain/measurement_validation.dart';
import 'measurement_labels.dart';
import 'measurement_providers.dart';
import 'noise_points_screen.dart';
import 'skip_reason_sheet.dart';

/// Lançamento semanal de ruídos (RF-AMB-02): um campo por ponto, valor
/// anterior, aviso de limite, "sem medição" e navegação entre semanas.
class NoiseLaunchScreen extends StatelessWidget {
  const NoiseLaunchScreen({
    super.key,
    required this.companyId,
    required this.slug,
    this.week,
  });

  final String companyId;
  final String slug;

  /// `AAAA-MM-DD` de um dia da semana a abrir (query `semana`).
  final String? week;

  @override
  Widget build(BuildContext context) => ModuleGate(
    companyId: companyId,
    slug: slug,
    only: ModuleType.environmental,
    builder: (context, company, _) =>
        _NoiseLaunch(company: company, week: week),
  );
}

/// O que está digitado para um ponto na semana exibida.
class _Draft {
  _Draft(Measurement? saved)
    : controller = TextEditingController(
        text: switch (saved?.value) {
          final v? => formatDecimal(v),
          null => '',
        },
      ),
      skipReason = saved != null && saved.value == null ? saved.note : null;

  final TextEditingController controller;
  String? skipReason;
  String? error;

  bool get isEmpty => skipReason == null && controller.text.trim().isEmpty;

  /// `null` = vazio; texto que não é número fica com valor `NaN`.
  MeasurementEntry? get entry {
    final skip = skipReason;
    if (skip != null) return MeasurementEntry(note: skip);
    if (controller.text.trim().isEmpty) return null;
    return MeasurementEntry(value: parseDecimal(controller.text) ?? double.nan);
  }
}

/// O que está salvo, no formato comparável com [_Draft.entry] (a observação
/// junto de um valor não aparece na tela e é preservada ao salvar).
MeasurementEntry? _savedEntry(Measurement? m) => switch (m) {
  null => null,
  Measurement(:final value?) => MeasurementEntry(value: value),
  Measurement(:final note) => MeasurementEntry(note: note),
};

class _NoiseLaunch extends ConsumerStatefulWidget {
  const _NoiseLaunch({required this.company, required this.week});

  final Company company;
  final String? week;

  @override
  ConsumerState<_NoiseLaunch> createState() => _NoiseLaunchState();
}

class _NoiseLaunchState extends ConsumerState<_NoiseLaunch> {
  static const _weekly = MeasurementFrequency.weekly;

  /// Semana que contém hoje; acompanha a virada do dia.
  MeasurementPeriod get _current =>
      MeasurementPeriod.containing(_weekly, ref.read(todayProvider));
  late MeasurementPeriod _period;
  final _drafts = <String, _Draft>{};
  bool _saving = false;

  Company get company => widget.company;

  @override
  void initState() {
    super.initState();
    final current = _current;
    final asked = switch (widget.week) {
      final w? => parseIsoDate(w),
      null => null,
    };
    _period = asked == null
        ? current
        : MeasurementPeriod.containing(_weekly, asked);
    if (_period.compareTo(current) > 0) _period = current;
  }

  @override
  void dispose() {
    _clearDrafts();
    super.dispose();
  }

  void _clearDrafts() {
    for (final d in _drafts.values) {
      d.controller.dispose();
    }
    _drafts.clear();
  }

  /// Medição salva de cada ponto nesta semana.
  Map<String, Measurement> _savedIn(List<Measurement> all) => {
    for (final m in all)
      if (m.periodStart == _period.start) m.parameterId: m,
  };

  /// Pontos da semana: ativos que já cobravam, mais qualquer ponto com
  /// medição salva nela.
  List<MeasurementParameter> _rows(
    List<MeasurementParameter> points,
    Map<String, Measurement> saved,
  ) => [
    for (final p in points)
      if ((!p.isArchived && !p.firstPeriod.start.isAfter(_period.start)) ||
          saved.containsKey(p.id))
        p,
  ];

  _Draft _draft(String id, Measurement? saved) =>
      _drafts.putIfAbsent(id, () => _Draft(saved));

  bool _isDirty(
    List<MeasurementParameter> rows,
    Map<String, Measurement> saved,
  ) => rows.any((p) {
    final draft = _drafts[p.id];
    return draft != null && draft.entry != _savedEntry(saved[p.id]);
  });

  /// Medição mais recente do ponto antes da semana exibida.
  Measurement? _previous(List<Measurement> all, String id) => all
      .where(
        (m) => m.parameterId == id && m.periodStart.isBefore(_period.start),
      )
      .sortedBy((m) => m.periodStart)
      .lastOrNull;

  Future<bool> _confirmDiscard() => showConfirmDialog(
    context,
    title: 'Descartar alterações?',
    message: 'O que foi digitado nesta semana não foi salvo.',
    confirmLabel: 'Descartar',
    destructive: true,
  );

  Future<void> _goTo(MeasurementPeriod period, bool dirty) async {
    if (dirty && !await _confirmDiscard()) return;
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _clearDrafts();
      _period = period;
    });
  }

  Future<void> _skip(Iterable<_Draft> drafts, {required bool week}) async {
    final reason = await showSkipReasonSheet(
      context,
      title: week ? 'Sem medição nesta semana' : 'Sem medição neste ponto',
      description: week
          ? 'O motivo vale para os pontos ainda sem valor.'
          : null,
    );
    if (reason == null || !mounted) return;
    setState(() {
      for (final d in drafts) {
        d
          ..skipReason = reason
          ..error = null;
      }
    });
  }

  Future<void> _save(
    List<MeasurementParameter> rows,
    Map<String, Measurement> saved,
  ) async {
    FocusScope.of(context).unfocus();
    final entries = <String, MeasurementEntry?>{};
    var invalid = false;
    for (final p in rows) {
      final draft = _drafts[p.id];
      if (draft == null) continue;
      final entry = draft.entry;
      draft.error = null;
      if (entry?.value case final v? when !v.isFinite) {
        draft.error = 'Valor inválido';
        invalid = true;
        continue;
      }
      if (entry == _savedEntry(saved[p.id])) continue;
      final before = saved[p.id];
      entries[p.id] = switch (entry) {
        // Preserva a observação que já existia junto de um valor.
        MeasurementEntry(:final value?) => MeasurementEntry(
          value: value,
          note: before?.value != null ? before?.note : null,
        ),
        _ => entry,
      };
    }
    if (invalid) {
      setState(() {});
      return;
    }
    if (entries.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final title = periodTitle(_period);
    setState(() => _saving = true);
    try {
      await ref
          .read(measurementRepositoryProvider)
          .savePeriod(_period, entries, today: ref.read(todayProvider));
      messenger.showSnackBar(SnackBar(content: Text('$title salva')));
    } on FuturePeriodException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não dá para lançar uma semana futura')),
      );
    } on MeasurementValidationException catch (e) {
      setState(() {
        for (final MapEntry(key: id, value: errors) in e.entryErrors.entries) {
          _drafts[id]?.error = errors.any((x) => x.field == EntryField.note)
              ? 'Informe o motivo'
              : 'Valor inválido';
        }
      });
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar. Tente de novo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(noisePointsProvider(company.id));
    final measurements = ref.watch(noiseMeasurementsProvider(company.id));
    final pointList = points.value;
    final all = measurements.value;
    final ready = pointList != null && all != null;
    final saved = ready ? _savedIn(all) : const <String, Measurement>{};
    final rows = ready
        ? _rows(pointList, saved)
        : const <MeasurementParameter>[];
    final dirty = ready && _isDirty(rows, saved);
    final today = ref.watch(todayProvider);
    final isCurrent =
        _period.compareTo(MeasurementPeriod.containing(_weekly, today)) >= 0;

    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !await _confirmDiscard() || !context.mounted) return;
        setState(_clearDrafts);
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: BandTitle(title: 'Ruídos', subtitle: company.displayName),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Pontos de medição',
              onPressed: () => context.go(AppRoutes.noisePoints(company.id)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              PeriodNavigator.heightOf(context) + AppSpacing.lg,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PeriodNavigator(
                title: periodTitle(_period),
                subtitle: periodRange(_period),
                previousTooltip: 'Semana anterior',
                nextTooltip: 'Próxima semana',
                onPrevious: () => _goTo(_period.previous, dirty),
                onNext: isCurrent ? null : () => _goTo(_period.next, dirty),
              ),
            ),
          ),
        ),
        body: switch ((points, measurements)) {
          _ when ready && rows.isEmpty && pointList.any((p) => !p.isArchived) =>
            const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Nenhum ponto nesta semana',
              message:
                  'Os pontos de medição foram cadastrados depois desta '
                  'semana.',
            ),
          _ when ready && rows.isEmpty => EmptyState(
            icon: Icons.graphic_eq,
            title: 'Nenhum ponto de medição',
            message:
                'Cadastre os lugares onde o ruído é medido, como o portão ou '
                'a divisa do terreno.',
            actionLabel: 'Cadastrar ponto',
            onAction: () => openPointSheet(context, ref, company.id),
          ),
          _ when ready => _list(rows, saved, all),
          (AsyncValue(hasError: true), _) ||
          (_, AsyncValue(hasError: true)) => const EmptyState(
            icon: Icons.error_outline,
            title: 'Não foi possível carregar os pontos',
            message: 'Tente abrir a tela de novo.',
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
        bottomNavigationBar: ready && rows.isNotEmpty
            ? AppActionBar(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: dirty && !_saving
                          ? () => _save(rows, saved)
                          : null,
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _list(
    List<MeasurementParameter> rows,
    Map<String, Measurement> saved,
    List<Measurement> all,
  ) {
    final drafts = [for (final p in rows) _draft(p.id, saved[p.id])];
    final filled = drafts.where((d) => !d.isEmpty).length;
    final empty = [
      for (final d in drafts)
        if (d.isEmpty) d,
    ];
    final unit = MeasurementContext.noise.defaultUnit ?? '';
    return ListView(
      padding: AppSpacing.screen.copyWith(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      children: [
        SectionCard(
          title: 'Pontos de medição',
          caption: '$filled de ${rows.length}',
          children: [
            for (final (i, p) in rows.indexed)
              MeasurementInputRow(
                number: i + 1,
                name: p.name,
                previousLabel: previousLabel(_previous(all, p.id)),
                controller: drafts[i].controller,
                unit: p.unit ?? unit,
                fieldLabel: 'Valor no ponto ${i + 1}',
                errorText: drafts[i].error,
                limitLabel: limitLabel(
                  p,
                  parseDecimal(drafts[i].controller.text),
                ),
                skippedReason: drafts[i].skipReason,
                menuLabel: 'Sem medição neste ponto',
                onSkip: () => _skip([drafts[i]], week: false),
                onUndoSkip: () => setState(() => drafts[i].skipReason = null),
                onChanged: (_) => setState(() => drafts[i].error = null),
              ),
          ],
        ),
        if (empty.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.block),
              label: const Text('Sem medição nesta semana'),
              onPressed: () => _skip(empty, week: true),
            ),
          ),
        ],
      ],
    );
  }
}

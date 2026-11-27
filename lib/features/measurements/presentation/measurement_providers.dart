import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_measurement_repository.dart'
    show measurementRepositoryProvider;
import '../domain/measurement.dart';
import '../domain/measurement_context.dart';
import '../domain/measurement_parameter.dart';
import '../domain/pending_launch.dart';

/// Pontos de ruído da empresa, desativados incluídos, na ordem de exibição.
final noisePointsProvider = StreamProvider.autoDispose
    .family<List<MeasurementParameter>, String>(
      (ref, companyId) => ref
          .watch(measurementRepositoryProvider)
          .watchParameters(
            companyId,
            MeasurementContext.noise,
            includeArchived: true,
          ),
    );

/// Todas as medições de ruído da empresa, por período.
final noiseMeasurementsProvider = StreamProvider.autoDispose
    .family<List<Measurement>, String>(
      (ref, companyId) => ref
          .watch(measurementRepositoryProvider)
          .watchMeasurements(companyId, MeasurementContext.noise),
    );

/// Pendências de lançamento da empresa em [today] (data local, sem hora).
final companyPendingLaunchesProvider = StreamProvider.autoDispose
    .family<List<PendingLaunch>, ({String companyId, DateTime today})>(
      (ref, key) => ref
          .watch(measurementRepositoryProvider)
          .watchPendingLaunches(today: key.today, companyId: key.companyId),
    );

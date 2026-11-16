import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../companies/domain/module_type.dart';
import '../data/local_deadline_repository.dart' show deadlineRepositoryProvider;
import '../domain/deadline.dart';
import '../domain/deadline_status.dart';

/// Prazos em aberto da empresa (todos os módulos).
final companyDeadlinesProvider = StreamProvider.autoDispose
    .family<List<Deadline>, String>(
      (ref, companyId) =>
          ref.watch(deadlineRepositoryProvider).watchByCompany(companyId),
    );

/// Prazos em aberto de um módulo da empresa.
final moduleDeadlinesProvider = StreamProvider.autoDispose
    .family<List<Deadline>, ({String companyId, ModuleType module})>(
      (ref, key) => ref
          .watch(deadlineRepositoryProvider)
          .watchByCompany(key.companyId, module: key.module),
    );

/// Um prazo pelo id (`null` se não existe ou foi excluído).
final deadlineProvider = StreamProvider.autoDispose.family<Deadline?, String>(
  (ref, id) => ref.watch(deadlineRepositoryProvider).watchById(id),
);

/// Ciclos da cadeia do prazo, do mais novo para o mais antigo.
final deadlineHistoryProvider = StreamProvider.autoDispose
    .family<List<Deadline>, String>(
      (ref, id) => ref.watch(deadlineRepositoryProvider).watchHistory(id),
    );

/// Prazos concluídos e cancelados de um módulo da empresa.
final moduleClosedDeadlinesProvider = StreamProvider.autoDispose
    .family<List<Deadline>, ({String companyId, ModuleType module})>(
      (ref, key) => ref
          .watch(deadlineRepositoryProvider)
          .watchByCompany(
            key.companyId,
            module: key.module,
            statuses: {DeadlineStatus.completed, DeadlineStatus.cancelled},
          ),
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../companies/domain/module_type.dart';
import '../data/local_deadline_repository.dart' show deadlineRepositoryProvider;
import '../domain/deadline.dart';

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

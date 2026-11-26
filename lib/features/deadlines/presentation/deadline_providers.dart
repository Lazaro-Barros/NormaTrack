import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../companies/domain/company_repository.dart' show CompanyFilter;
import '../../companies/domain/module_type.dart';
import '../../companies/presentation/company_providers.dart'
    show companiesProvider;
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

/// Próximos vencimentos de todas as empresas (RF-PRZ-05): em aberto, de
/// empresas não arquivadas com o módulo habilitado, por vencimento.
final upcomingDeadlinesProvider = StreamProvider.autoDispose<List<Deadline>>(
  (ref) => ref.watch(deadlineRepositoryProvider).watchUpcoming(),
);

/// Nome de exibição por id, das empresas não arquivadas.
final companyNamesProvider =
    Provider.autoDispose<AsyncValue<Map<String, String>>>(
      (ref) => ref
          .watch(companiesProvider(const CompanyFilter()))
          .whenData((list) => {for (final c in list) c.id: c.displayName}),
    );

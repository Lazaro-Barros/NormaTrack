import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_company_repository.dart' show companyRepositoryProvider;
import '../domain/company.dart';
import '../domain/company_repository.dart';

/// Empresas não excluídas que atendem ao filtro.
final companiesProvider = StreamProvider.autoDispose
    .family<List<Company>, CompanyFilter>(
      (ref, filter) => ref.watch(companyRepositoryProvider).watchAll(filter),
    );

/// Uma empresa; `null` se não existe ou foi excluída.
final companyProvider = StreamProvider.autoDispose.family<Company?, String>(
  (ref, id) => ref.watch(companyRepositoryProvider).watchById(id),
);

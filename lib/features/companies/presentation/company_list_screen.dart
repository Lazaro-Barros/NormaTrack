import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/nav_row.dart';
import '../domain/company.dart';
import '../domain/company_repository.dart';
import 'company_labels.dart';
import 'company_providers.dart';

/// Lista de empresas com busca e ativas/arquivadas (RF-EMP-01).
class CompanyListScreen extends ConsumerStatefulWidget {
  const CompanyListScreen({super.key});

  @override
  ConsumerState<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends ConsumerState<CompanyListScreen> {
  bool _archived = false;
  String _query = '';

  /// Última lista recebida: mostrada enquanto a próxima carrega, para não
  /// piscar a cada tecla da busca.
  List<Company>? _last;

  @override
  Widget build(BuildContext context) {
    final filter = CompanyFilter(
      archived: _archived,
      query: _query.trim().isEmpty ? null : _query,
    );
    final companies = ref.watch(companiesProvider(filter));
    return Scaffold(
      appBar: AppBar(
        title: const BandTitle(title: 'Empresas', large: true),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            AppSpacing.minTouch + AppSpacing.lg,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: SearchBar(
              hintText: 'Buscar por nome ou CNPJ',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: AppSpacing.screen.copyWith(top: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              expandedInsets: EdgeInsets.zero,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Ativas')),
                ButtonSegment(value: true, label: Text('Arquivadas')),
              ],
              selected: {_archived},
              onSelectionChanged: (s) => setState(() {
                _archived = s.single;
                _last = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _body(companies)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova empresa'),
        onPressed: () => context.go(AppRoutes.newCompany),
      ),
    );
  }

  Widget _body(AsyncValue<List<Company>> companies) {
    if (companies.hasValue) _last = companies.value;
    if (companies.hasError && !companies.hasValue) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Não foi possível carregar as empresas',
        message: 'Tente abrir a tela de novo.',
      );
    }
    final list = _last;
    if (list == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) return _empty();
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final company = list[i];
        return Card(
          // TODO(RF-PRZ-05): pior situação dos prazos à direita.
          child: NavRow(
            title: company.displayName,
            subtitle: cityState(company.address),
            onTap: () => context.go(AppRoutes.company(company.id)),
          ),
        );
      },
    );
  }

  Widget _empty() {
    if (_query.trim().isNotEmpty) {
      return const EmptyState(
        icon: Icons.apartment_outlined,
        title: 'Nenhuma empresa encontrada',
        message: 'Confira o nome ou o CNPJ digitado.',
      );
    }
    if (_archived) {
      return const EmptyState(
        icon: Icons.apartment_outlined,
        title: 'Nenhuma empresa arquivada',
        message: 'Empresas arquivadas aparecem aqui.',
      );
    }
    return EmptyState(
      icon: Icons.apartment_outlined,
      title: 'Nenhuma empresa cadastrada',
      message:
          'Cadastre a primeira empresa para acompanhar prazos e registros.',
      actionLabel: 'Cadastrar empresa',
      onAction: () => context.go(AppRoutes.newCompany),
    );
  }
}

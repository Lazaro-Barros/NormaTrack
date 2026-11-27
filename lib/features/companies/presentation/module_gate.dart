import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/widgets/empty_state.dart';
import '../domain/company.dart';
import '../domain/module_type.dart';
import 'company_labels.dart';
import 'company_providers.dart';

/// Carrega a empresa e confere o módulo da rota antes de montar a tela:
/// "Módulo não encontrado" (slug inválido ou diferente de [only]), "Módulo
/// desligado", "Empresa não encontrada" ou carregando.
class ModuleGate extends ConsumerWidget {
  const ModuleGate({
    super.key,
    required this.companyId,
    required this.slug,
    this.only,
    required this.builder,
  });

  final String companyId;
  final String slug;

  /// Se informado, só esse módulo é aceito (ex.: Ruídos só no Ambiental).
  final ModuleType? only;
  final Widget Function(
    BuildContext context,
    Company company,
    ModuleType module,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = moduleFromSlug(slug);
    if (module == null || (only != null && module != only)) {
      return _message(
        icon: Icons.help_outline,
        title: 'Módulo não encontrado',
        message: 'Volte e escolha o módulo de novo.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.company(companyId)),
      );
    }
    return switch (ref.watch(companyProvider(companyId))) {
      AsyncValue(value: final Company company) =>
        company.hasModule(module)
            ? builder(context, company, module)
            : _message(
                icon: module.icon,
                title: 'Módulo desligado',
                message:
                    'Ligue o módulo no cadastro da empresa para ver os '
                    'prazos.',
                actionLabel: 'Editar empresa',
                onAction: () => context.go(AppRoutes.editCompany(companyId)),
              ),
      AsyncValue(hasValue: true) || AsyncValue(hasError: true) => _message(
        icon: Icons.apartment_outlined,
        title: 'Empresa não encontrada',
        message: 'Ela pode ter sido excluída.',
        actionLabel: 'Voltar',
        onAction: () => context.go(AppRoutes.companies),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) => Scaffold(
    appBar: AppBar(),
    body: EmptyState(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

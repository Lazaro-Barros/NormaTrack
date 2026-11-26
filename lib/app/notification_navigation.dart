import 'package:go_router/go_router.dart';

import '../features/deadlines/domain/deadline_repository.dart';
import 'router.dart';

/// Abre o prazo tocado na notificação: vai ao Painel e empilha o detalhe, para
/// que voltar leve ao Painel. Prazo inexistente ou excluído: só o Painel.
Future<void> openDeadlineFromNotification(
  GoRouter router,
  DeadlineRepository repository,
  String deadlineId,
) async {
  final deadline = await repository.findById(deadlineId);
  router.go(AppRoutes.dashboard);
  if (deadline == null) return;
  router.push(
    AppRoutes.deadline(deadline.companyId, deadline.module, deadline.id),
  );
}

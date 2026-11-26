import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/confirm_dialog.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/notice_banner.dart';
import '../../../app/widgets/progress_dialog.dart';
import '../../../app/widgets/section_card.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_format.dart';
import '../data/local_backup_service.dart';
import '../data/platform_backup_files.dart';
import '../domain/backup.dart';
import 'backup_providers.dart';

/// Mensagem pt-BR de cada falha de restauração.
String restoreFailureMessage(BackupFailure failure) => switch (failure) {
  BackupFailure.notABackup => 'Este arquivo não é um backup do NormaTrack.',
  BackupFailure.newerVersion =>
    'Este backup é de uma versão mais nova do NormaTrack. Atualize o app '
        'para restaurá-lo.',
  BackupFailure.corrupted =>
    'Este backup está danificado e não pode ser restaurado.',
  BackupFailure.failed =>
    'Não foi possível restaurar o backup. Os dados atuais foram mantidos.',
};

/// Texto da confirmação da restauração.
String restoreConfirmMessage(BackupSummary summary) {
  String plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';
  final companies = plural(summary.companyCount, 'empresa', 'empresas');
  final deadlines = plural(summary.deadlineCount, 'prazo', 'prazos');
  final last = summary.lastChangeAt;
  final when = last == null
      ? ''
      : ', com última alteração em ${formatDate(last.toLocal())}';
  return 'Os dados atuais serão substituídos pelos do arquivo: $companies e '
      '$deadlines$when. Os dados atuais ficam guardados neste aparelho até a '
      'próxima restauração.';
}

/// Aviso de Ajustes enquanto nenhum backup foi feito (RNF-04).
class BackupNotice extends ConsumerWidget {
  const BackupNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastBackupAtProvider);
    if (!last.hasValue || last.value != null) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: NoticeBanner(
        tone: StatusTone.dueSoon,
        icon: Icons.warning_amber_rounded,
        message: 'Os dados ficam só neste aparelho.',
        emphasis: 'Nenhum backup feito ainda.',
      ),
    );
  }
}

/// Seção Backup de Ajustes: fazer e restaurar backup (RNF-04).
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          persist: false,
          duration: action == null
              ? const Duration(seconds: 4)
              : const Duration(seconds: 10),
        ),
      );
  }

  Future<void> _backup() async {
    final service = ref.read(backupServiceProvider);
    final files = ref.read(backupFilesProvider);
    try {
      final file = await showProgressDialog(
        context,
        'Gerando backup…',
        service.create(),
      );
      if (!await files.share(file)) return;
      await ref
          .read(lastBackupAtProvider.notifier)
          .record(ref.read(clockProvider)());
      if (mounted) _snack('Backup feito');
    } on Object catch (e) {
      debugPrint('Falha ao fazer backup: $e');
      if (mounted) _snack('Não foi possível fazer o backup.');
    }
  }

  Future<void> _restore() async {
    final service = ref.read(backupServiceProvider);
    final files = ref.read(backupFilesProvider);
    try {
      final staging = await service.stagingPath();
      if (!await files.pick(staging) || !mounted) return;
      final summary = await showProgressDialog(
        context,
        'Conferindo o arquivo…',
        service.inspect(staging),
      );
      if (!mounted) return;
      final confirmed = await showConfirmDialog(
        context,
        title: 'Restaurar backup?',
        message: restoreConfirmMessage(summary),
        confirmLabel: 'Restaurar',
        destructive: true,
      );
      if (!confirmed || !mounted) return;
      await showProgressDialog(
        context,
        'Restaurando…',
        service.restore(staging),
      );
      if (!mounted) return;
      _snack(
        'Backup restaurado',
        action: SnackBarAction(label: 'Desfazer', onPressed: _undo),
      );
    } on BackupException catch (e) {
      debugPrint('Backup recusado: $e');
      if (mounted) _snack(restoreFailureMessage(e.failure));
    } on Object catch (e) {
      debugPrint('Falha ao restaurar: $e');
      if (mounted) _snack(restoreFailureMessage(BackupFailure.failed));
    }
  }

  Future<void> _undo() async {
    if (!mounted) return;
    try {
      await showProgressDialog(
        context,
        'Desfazendo…',
        ref.read(backupServiceProvider).undoRestore(),
      );
      if (mounted) _snack('Dados anteriores de volta');
    } on Object catch (e) {
      debugPrint('Falha ao desfazer: $e');
      if (mounted) _snack('Não foi possível desfazer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = ref.watch(lastBackupAtProvider).value;
    return SectionCard(
      title: 'Backup',
      children: [
        NavRow(
          leadingIcon: Icons.upload_outlined,
          title: 'Fazer backup',
          subtitle: last == null
              ? 'Exporta um arquivo com todos os dados'
              : 'Último backup em ${formatDate(last.toLocal())}',
          onTap: _backup,
        ),
        NavRow(
          leadingIcon: Icons.download_outlined,
          title: 'Restaurar backup',
          subtitle: 'Substitui os dados atuais',
          onTap: _restore,
        ),
      ],
    );
  }
}

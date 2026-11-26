import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/backup.dart';

/// Compartilhar e escolher arquivos pelo sistema. Sobrescrito nos testes.
final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const PlatformBackupFiles(),
);

/// [BackupFiles] com a folha de compartilhamento (`share_plus`) e o seletor
/// do Android (`file_picker`).
class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  @override
  Future<bool> share(BackupFile file) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'application/octet-stream',
            name: file.name,
          ),
        ],
        fileNameOverrides: [file.name],
        subject: file.name,
      ),
    );
    // TODO(RNF-04): suposição (C25) — `unavailable` (o aparelho não informa o
    // destino) não conta como backup feito. `success` só garante que a pessoa
    // escolheu um app, não que o envio terminou.
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<bool> pick(String destinationPath) async {
    // Sem filtro de extensão: o Android não conhece o MIME de `.ntbackup`.
    // Quem valida o conteúdo é o `BackupService.inspect`.
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return false;
    await file.xFile.saveTo(destinationPath);
    try {
      await FilePicker.clearTemporaryFiles();
    } on Object {
      // Só limpeza do cache do seletor.
    }
    return true;
  }
}

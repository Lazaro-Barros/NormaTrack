import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/features/backup/domain/backup.dart';

import '../../../helpers/fake_backup.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeBackupService service;
  late FakeBackupFiles files;
  late FakeBackupSettings settings;

  const notice = 'Os dados ficam só neste aparelho. Nenhum backup feito ainda.';

  setUp(() {
    service = FakeBackupService();
    files = FakeBackupFiles();
    settings = FakeBackupSettings();
  });

  Future<void> pumpSettings(WidgetTester tester) => pumpApp(
    tester,
    backupService: service,
    backupFiles: files,
    backupSettings: settings,
    initialLocation: AppRoutes.settings,
  );

  Finder noticeFinder() => find.text(notice, findRichText: true);

  group('Fazer backup', () {
    testWidgets('sem backup: aviso e subtítulo padrão', (tester) async {
      await pumpSettings(tester);

      expect(noticeFinder(), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
      expect(
        find.text('Exporta um arquivo com todos os dados'),
        findsOneWidget,
      );
      expect(find.text('Substitui os dados atuais'), findsOneWidget);
    });

    testWidgets('compartilhar grava a data, troca o subtítulo e tira o aviso', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Fazer backup'));
      await tester.pumpAndSettle();

      expect(service.createCalls, 1);
      expect(files.shared.single.name, 'NormaTrack-backup.ntbackup');
      expect(settings.lastAt, testNow);
      expect(find.text('Último backup em 29/09/2026'), findsOneWidget);
      expect(noticeFinder(), findsNothing);
      expect(find.text('Backup feito'), findsOneWidget);
    });

    testWidgets('fechar a folha não grava', (tester) async {
      files.shareResult = false;
      await pumpSettings(tester);

      await tester.tap(find.text('Fazer backup'));
      await tester.pumpAndSettle();

      expect(files.shared, hasLength(1));
      expect(settings.lastAt, isNull);
      expect(noticeFinder(), findsOneWidget);
      expect(find.text('Backup feito'), findsNothing);
    });

    testWidgets('erro ao gerar mostra mensagem', (tester) async {
      service.createFailure = BackupFailure.failed;
      await pumpSettings(tester);

      await tester.tap(find.text('Fazer backup'));
      await tester.pumpAndSettle();

      expect(files.shared, isEmpty);
      expect(find.text('Não foi possível fazer o backup.'), findsOneWidget);
    });

    testWidgets('com backup anterior: sem aviso, com a data', (tester) async {
      settings.lastAt = DateTime.utc(2026, 9, 20, 15);
      await pumpSettings(tester);

      expect(noticeFinder(), findsNothing);
      expect(find.text('Último backup em 20/09/2026'), findsOneWidget);
    });
  });

  group('Restaurar backup', () {
    Future<void> tapRestore(WidgetTester tester) async {
      await tester.tap(find.text('Restaurar backup'));
      await tester.pumpAndSettle();
    }

    testWidgets('cancelar no seletor não confere nada', (tester) async {
      files.pickResult = false;
      await pumpSettings(tester);
      await tapRestore(tester);

      expect(files.picked, [FakeBackupService.staging]);
      expect(service.inspected, isEmpty);
      expect(find.text('Restaurar backup?'), findsNothing);
    });

    for (final (failure, message) in [
      (BackupFailure.notABackup, 'Este arquivo não é um backup do NormaTrack.'),
      (
        BackupFailure.newerVersion,
        'Este backup é de uma versão mais nova do NormaTrack. Atualize o app '
            'para restaurá-lo.',
      ),
      (
        BackupFailure.corrupted,
        'Este backup está danificado e não pode ser restaurado.',
      ),
      (
        BackupFailure.failed,
        'Não foi possível restaurar o backup. Os dados atuais foram mantidos.',
      ),
    ]) {
      testWidgets('arquivo recusado (${failure.name}) mostra a mensagem', (
        tester,
      ) async {
        service.inspectFailure = failure;
        await pumpSettings(tester);
        await tapRestore(tester);

        expect(find.text(message), findsOneWidget);
        expect(find.text('Restaurar backup?'), findsNothing);
        expect(service.restored, isEmpty);
      });
    }

    testWidgets('confirmação mostra contagens, plural e data; cancelar não '
        'restaura', (tester) async {
      service.summary = BackupSummary(
        schemaVersion: 2,
        companyCount: 1,
        deadlineCount: 12,
        lastChangeAt: DateTime.utc(2026, 9, 28, 15),
      );
      await pumpSettings(tester);
      await tapRestore(tester);

      expect(find.text('Restaurar backup?'), findsOneWidget);
      expect(
        find.text(
          'Os dados atuais serão substituídos pelos do arquivo: 1 empresa e '
          '12 prazos, com última alteração em 28/09/2026. Os dados atuais '
          'ficam guardados neste aparelho até a próxima restauração.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(service.restored, isEmpty);
    });

    testWidgets('sem data no resumo', (tester) async {
      await pumpSettings(tester);
      await tapRestore(tester);

      expect(
        find.textContaining('arquivo: 0 empresas e 0 prazos. Os dados'),
        findsOneWidget,
      );
    });

    testWidgets('confirmar restaura e Desfazer volta', (tester) async {
      await pumpSettings(tester);
      await tapRestore(tester);

      await tester.tap(find.text('Restaurar'));
      await tester.pumpAndSettle();

      expect(service.restored, [FakeBackupService.staging]);
      expect(find.text('Backup restaurado'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      expect(service.undoCalls, 1);
      expect(find.text('Dados anteriores de volta'), findsOneWidget);
    });

    testWidgets('falha ao restaurar mostra mensagem', (tester) async {
      service.restoreFailure = BackupFailure.failed;
      await pumpSettings(tester);
      await tapRestore(tester);

      await tester.tap(find.text('Restaurar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Não foi possível restaurar o backup. Os dados atuais foram mantidos.',
        ),
        findsOneWidget,
      );
      expect(find.text('Backup restaurado'), findsNothing);
    });
  });
}

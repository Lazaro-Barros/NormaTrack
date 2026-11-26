import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/backup/domain/backup.dart';

void main() {
  test('backupFileName usa data e hora locais com dois dígitos', () {
    expect(
      backupFileName(DateTime(2026, 11, 26, 14, 5)),
      'NormaTrack-backup-2026-11-26-1405.ntbackup',
    );
    expect(
      backupFileName(DateTime(2027, 1, 2, 9, 0)),
      'NormaTrack-backup-2027-01-02-0900.ntbackup',
    );
  });
}

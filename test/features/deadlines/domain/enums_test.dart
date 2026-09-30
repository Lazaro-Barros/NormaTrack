import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';

void main() {
  void checkCodes<T extends Enum>(
    List<T> values,
    String Function(T) code,
    T Function(String) fromCode,
  ) {
    for (final v in values) {
      expect(fromCode(code(v)), v);
    }
    expect(values.map(code).toSet(), hasLength(values.length));
    expect(() => fromCode('desconhecido'), throwsArgumentError);
  }

  test('DeadlineCategory', () {
    checkCodes(
      DeadlineCategory.values,
      (v) => v.code,
      DeadlineCategory.fromCode,
    );
    expect(DeadlineCategory.values, hasLength(3));
    expect(DeadlineCategory.labReport.code, 'lab_report');
  });

  test('lembretes padrão por categoria', () {
    expect(DeadlineCategory.license.defaultReminderDays, [150, 30, 10, 3, 0]);
    expect(DeadlineCategory.labReport.defaultReminderDays, [30, 10, 3, 0]);
    expect(DeadlineCategory.maintenance.defaultReminderDays, [30, 10, 3, 0]);
  });

  test('só laudo e manutenção podem ser concluídos', () {
    expect(DeadlineCategory.license.canBeCompleted, isFalse);
    expect(DeadlineCategory.labReport.canBeCompleted, isTrue);
    expect(DeadlineCategory.maintenance.canBeCompleted, isTrue);
  });

  test('DeadlineStatus', () {
    checkCodes(DeadlineStatus.values, (v) => v.code, DeadlineStatus.fromCode);
    expect(DeadlineStatus.values, hasLength(4));
  });
}

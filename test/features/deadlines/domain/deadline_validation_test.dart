import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_validation.dart';

void main() {
  DeadlineInput input({
    String title = 'Laudo da ETE',
    DeadlineCategory category = DeadlineCategory.labReport,
    List<int>? reminderDays,
    DateTime? dueDate,
  }) => DeadlineInput(
    module: ModuleType.environmental,
    category: category,
    title: title,
    dueDate: dueDate ?? DateTime(2026, 11, 8),
    reminderDays: reminderDays,
  );

  group('normalizeDeadlineInput', () {
    test('título sem espaços sobrando', () {
      expect(
        normalizeDeadlineInput(input(title: '  Laudo   da\tETE ')).title,
        'Laudo da ETE',
      );
    });

    test('data sem hora', () {
      expect(
        normalizeDeadlineInput(input(dueDate: DateTime(2026, 11, 8, 15, 30)))
            .dueDate,
        DateTime(2026, 11, 8),
      );
    });

    test('lembretes null viram o padrão da categoria', () {
      expect(normalizeDeadlineInput(input()).reminderDays, [30, 10, 3, 0]);
      expect(
        normalizeDeadlineInput(input(category: DeadlineCategory.license))
            .reminderDays,
        [150, 30, 10, 3, 0],
      );
    });

    test('lembretes sem repetição e em ordem decrescente', () {
      expect(
        normalizeDeadlineInput(input(reminderDays: [0, 10, 60, 10]))
            .reminderDays,
        [60, 10, 0],
      );
    });

    test('lista vazia continua vazia', () {
      expect(normalizeDeadlineInput(input(reminderDays: [])).reminderDays, []);
    });
  });

  group('validateDeadline', () {
    List<DeadlineFieldError> validate(DeadlineInput i) =>
        validateDeadline(normalizeDeadlineInput(i));

    test('input mínimo, sem órgão, é válido', () {
      expect(validate(input()), isEmpty);
    });

    test('título vazio', () {
      expect(validate(input(title: '   ')), [
        const DeadlineFieldError(
          DeadlineField.title,
          DeadlineFieldErrorType.required,
        ),
      ]);
    });

    test('sem lembretes', () {
      expect(validate(input(reminderDays: [])), [
        const DeadlineFieldError(
          DeadlineField.reminderDays,
          DeadlineFieldErrorType.required,
        ),
      ]);
    });

    test('lembrete negativo', () {
      expect(validate(input(reminderDays: [30, -1])), [
        const DeadlineFieldError(
          DeadlineField.reminderDays,
          DeadlineFieldErrorType.invalid,
        ),
      ]);
    });

    test('prazo no passado é válido', () {
      expect(validate(input(dueDate: DateTime(2020, 1, 1))), isEmpty);
    });
  });
}

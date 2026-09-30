import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/companies/presentation/company_labels.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';
import 'package:normatrack/features/deadlines/domain/deadline_validation.dart';
import 'package:normatrack/features/deadlines/presentation/deadline_labels.dart';

void main() {
  final today = DateTime(2026, 9, 29);
  final at = DateTime.utc(2026, 1, 1);

  Deadline deadline(
    DateTime due, {
    DeadlineCategory category = DeadlineCategory.license,
    Authority? authority,
    DeadlineStatus status = DeadlineStatus.active,
    List<int>? reminders,
  }) => Deadline(
    id: 'd',
    companyId: 'c',
    module: ModuleType.environmental,
    category: category,
    authority: authority,
    title: 'Prazo',
    dueDate: due,
    reminderDays: reminders ?? category.defaultReminderDays,
    status: status,
    createdAt: at,
    updatedAt: at,
  );

  group('deadlineDisplay', () {
    void check(Deadline d, StatusTone tone, String? lead, String text) {
      final display = deadlineDisplay(d, today);
      expect(display.tone, tone);
      expect(display.lead, lead);
      expect(display.text, text);
    }

    test('vencido', () {
      check(
        deadline(DateTime(2026, 9, 28)),
        StatusTone.overdue,
        'Venceu',
        'ontem',
      );
      check(
        deadline(DateTime(2026, 9, 26)),
        StatusTone.overdue,
        'Venceu',
        'há 3 dias',
      );
    });

    test('a vencer', () {
      check(
        deadline(DateTime(2026, 9, 29)),
        StatusTone.dueSoon,
        'Vence',
        'hoje',
      );
      check(
        deadline(DateTime(2026, 9, 30)),
        StatusTone.dueSoon,
        'Vence',
        'amanhã',
      );
      check(
        deadline(DateTime(2026, 10, 31)),
        StatusTone.dueSoon,
        'Vence',
        'em 32 dias',
      );
    });

    test('vigente em dias e em anos', () {
      check(
        deadline(DateTime(2026, 11, 8), category: DeadlineCategory.labReport),
        StatusTone.ok,
        null,
        'Em 40 dias',
      );
      check(
        deadline(DateTime(2026, 9, 30), reminders: [0]),
        StatusTone.ok,
        null,
        'Em 1 dia',
      );
      check(deadline(DateTime(2028, 3, 15)), StatusTone.ok, null, 'Em 1 ano');
      check(deadline(DateTime(2029, 3, 15)), StatusTone.ok, null, 'Em 2 anos');
    });

    test('fechados usam o rótulo do estado', () {
      check(
        deadline(DateTime(2020, 1, 1), status: DeadlineStatus.renewed),
        StatusTone.closed,
        null,
        'Renovado',
      );
    });
  });

  test('deadlineTone', () {
    expect(deadlineTone(DeadlineSituation.current), StatusTone.ok);
    expect(deadlineTone(DeadlineSituation.completed), StatusTone.closed);
    expect(deadlineTone(DeadlineSituation.cancelled), StatusTone.closed);
  });

  test('reminderLabel', () {
    expect(reminderLabel(0), 'No dia do vencimento');
    expect(reminderLabel(1), '1 dia antes');
    expect(reminderLabel(150), '150 dias antes');
  });

  test('categoryPluralLabel e deadlineSubtitle', () {
    expect(DeadlineCategory.values.map(categoryPluralLabel), [
      'Licenças',
      'Laudos',
      'Manutenções',
    ]);
    expect(
      deadlineSubtitle(
        deadline(DateTime(2026, 10, 31), authority: Authority.semace),
      ),
      'Licença · SEMACE',
    );
    expect(
      deadlineSubtitle(
        deadline(
          DateTime(2026, 10, 31),
          category: DeadlineCategory.maintenance,
        ),
      ),
      'Manutenção',
    );
  });

  test('deadlineFieldMessage', () {
    String msg(DeadlineField f, DeadlineFieldErrorType t) =>
        deadlineFieldMessage(DeadlineFieldError(f, t));
    expect(
      msg(DeadlineField.title, DeadlineFieldErrorType.required),
      'Informe o título',
    );
    expect(
      msg(DeadlineField.reminderDays, DeadlineFieldErrorType.required),
      'Adicione ao menos um lembrete',
    );
    expect(
      msg(DeadlineField.dueDate, DeadlineFieldErrorType.notAfterPrevious),
      'A nova data deve ser depois do vencimento atual',
    );
  });

  group('modulePending', () {
    test('vencidos têm prioridade', () {
      final p = modulePending([
        deadline(DateTime(2026, 9, 26)),
        deadline(DateTime(2026, 10, 31)),
      ], today)!;
      expect(p.label, '1 vencido');
      expect(p.tone, StatusTone.overdue);
      expect(
        modulePending([
          deadline(DateTime(2026, 9, 26)),
          deadline(DateTime(2026, 9, 20)),
        ], today)!.label,
        '2 vencidos',
      );
    });

    test('a vencer', () {
      final p = modulePending([
        deadline(DateTime(2026, 10, 31)),
        deadline(DateTime(2026, 9, 30)),
      ], today)!;
      expect(p.label, '2 a vencer');
      expect(p.tone, StatusTone.dueSoon);
    });

    test('só vigentes ou nada', () {
      expect(modulePending([deadline(DateTime(2028, 3, 15))], today), isNull);
      expect(modulePending(const [], today), isNull);
    });
  });

  test('slug do módulo', () {
    for (final m in ModuleType.values) {
      expect(moduleFromSlug(m.slug), m);
    }
    expect(ModuleType.controlledProducts.slug, 'produtos-controlados');
    expect(moduleFromSlug('nada'), isNull);
  });
}

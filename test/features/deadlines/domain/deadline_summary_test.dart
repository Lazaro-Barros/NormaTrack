import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';
import 'package:normatrack/features/deadlines/domain/deadline_summary.dart';

void main() {
  final today = DateTime(2026, 9, 29);
  final at = DateTime.utc(2026, 1, 1);

  Deadline deadline(
    String id,
    DeadlineCategory category,
    DateTime dueDate, {
    DeadlineStatus status = DeadlineStatus.active,
  }) => Deadline(
    id: id,
    companyId: 'c1',
    module: ModuleType.environmental,
    category: category,
    title: id,
    dueDate: dueDate,
    reminderDays: category.defaultReminderDays,
    status: status,
    createdAt: at,
    updatedAt: at,
  );

  // Mesmos prazos dos testes da tela (plan.md): −3, 12, 45 e 167 dias.
  final operation = deadline(
    'Licença de Operação',
    DeadlineCategory.license,
    DateTime(2026, 9, 26),
  );
  final report = deadline(
    'Laudo da ETE',
    DeadlineCategory.labReport,
    DateTime(2026, 10, 11),
  );
  final installation = deadline(
    'Licença de Instalação',
    DeadlineCategory.license,
    DateTime(2026, 11, 13),
  );
  final pump = deadline(
    'Bomba dosadora',
    DeadlineCategory.maintenance,
    DateTime(2027, 3, 15),
  );
  final all = [operation, report, installation, pump];

  group('SituationCounts.of', () {
    test('conta vencidos, a vencer e vigentes', () {
      final counts = SituationCounts.of(all, today);
      expect(counts, const SituationCounts(overdue: 1, dueSoon: 2, current: 1));
      expect(counts.total, 4);
    });

    test('ignora renovado, concluído e cancelado', () {
      final closed = [
        for (final s in [
          DeadlineStatus.renewed,
          DeadlineStatus.completed,
          DeadlineStatus.cancelled,
        ])
          deadline(
            s.name,
            DeadlineCategory.labReport,
            DateTime(2026, 9, 1),
            status: s,
          ),
      ];
      expect(
        SituationCounts.of([...all, ...closed], today),
        const SituationCounts(overdue: 1, dueSoon: 2, current: 1),
      );
    });

    test('lista vazia dá zeros', () {
      final counts = SituationCounts.of(const [], today);
      expect(counts, const SituationCounts());
      expect(counts.total, 0);
    });

    test('no dia do vencimento conta a vencer; no seguinte, vencido', () {
      final due = deadline('Hoje', DeadlineCategory.labReport, today);
      expect(
        SituationCounts.of([due], today),
        const SituationCounts(dueSoon: 1),
      );
      expect(
        SituationCounts.of([due], DateTime(2026, 9, 30)),
        const SituationCounts(overdue: 1),
      );
    });

    test('of devolve cada contagem e 0 para situação fechada', () {
      const counts = SituationCounts(overdue: 1, dueSoon: 2, current: 3);
      expect(counts.of(DeadlineSituation.overdue), 1);
      expect(counts.of(DeadlineSituation.dueSoon), 2);
      expect(counts.of(DeadlineSituation.current), 3);
      expect(counts.of(DeadlineSituation.renewed), 0);
      expect(counts.of(DeadlineSituation.completed), 0);
      expect(counts.of(DeadlineSituation.cancelled), 0);
    });
  });

  group('filterBySituation', () {
    test('null devolve todos, na ordem', () {
      expect(filterBySituation(all, today, null), all);
    });

    test('mantém a ordem da lista', () {
      expect(filterBySituation(all, today, DeadlineSituation.dueSoon), [
        report,
        installation,
      ]);
      expect(filterBySituation(all, today, DeadlineSituation.overdue), [
        operation,
      ]);
      expect(filterBySituation(all, today, DeadlineSituation.current), [pump]);
    });

    test('sem resultado devolve lista vazia', () {
      expect(filterBySituation([pump], today, DeadlineSituation.overdue), []);
    });
  });
}

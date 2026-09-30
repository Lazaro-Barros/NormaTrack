import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';

void main() {
  final created = DateTime.utc(2026, 1, 1);

  Deadline deadline({
    List<int> reminderDays = const [150, 30, 10, 3, 0],
    DeadlineStatus status = DeadlineStatus.active,
    DateTime? dueDate,
  }) => Deadline(
    id: 'd1',
    companyId: 'c1',
    module: ModuleType.environmental,
    category: DeadlineCategory.license,
    authority: Authority.semace,
    title: 'Licença de Operação',
    dueDate: dueDate ?? DateTime(2026, 10, 31),
    reminderDays: reminderDays,
    status: status,
    createdAt: created,
    updatedAt: created,
  );

  group('situationOn', () {
    final d = deadline();

    test('vigente até a véspera do primeiro alerta', () {
      expect(d.situationOn(DateTime(2026, 6, 2)), DeadlineSituation.current);
    });

    test('a vencer do primeiro alerta até o dia do vencimento', () {
      expect(d.situationOn(DateTime(2026, 6, 3)), DeadlineSituation.dueSoon);
      expect(d.situationOn(DateTime(2026, 10, 31)), DeadlineSituation.dueSoon);
    });

    test('vencido a partir do dia seguinte', () {
      expect(d.situationOn(DateTime(2026, 11, 1)), DeadlineSituation.overdue);
    });

    test('com lembrete só no dia', () {
      final onlyDay = deadline(reminderDays: [0]);
      expect(
        onlyDay.situationOn(DateTime(2026, 10, 30)),
        DeadlineSituation.current,
      );
      expect(
        onlyDay.situationOn(DateTime(2026, 10, 31)),
        DeadlineSituation.dueSoon,
      );
    });

    test('estado fechado vale mesmo vencido', () {
      final late = DateTime(2027, 1, 1);
      expect(
        deadline(status: DeadlineStatus.renewed).situationOn(late),
        DeadlineSituation.renewed,
      );
      expect(
        deadline(status: DeadlineStatus.completed).situationOn(late),
        DeadlineSituation.completed,
      );
      expect(
        deadline(status: DeadlineStatus.cancelled).situationOn(late),
        DeadlineSituation.cancelled,
      );
    });
  });

  test('daysUntilDue ignora a hora', () {
    final d = deadline();
    expect(d.daysUntilDue(DateTime(2026, 6, 2)), 151);
    expect(d.daysUntilDue(DateTime(2026, 6, 3)), 150);
    expect(d.daysUntilDue(DateTime(2026, 10, 31, 23, 59)), 0);
    expect(d.daysUntilDue(DateTime(2026, 11, 1)), -1);
  });

  test('alerta e datas dos lembretes', () {
    final d = deadline();
    expect(d.alertDaysBefore, 150);
    expect(d.alertStartDate, DateTime(2026, 6, 3));
    expect(d.reminderDates, [
      DateTime(2026, 6, 3),
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 21),
      DateTime(2026, 10, 28),
      DateTime(2026, 10, 31),
    ]);
    expect(
      deadline(reminderDays: [30, 10, 3, 0]).alertStartDate,
      DateTime(2026, 10, 1),
    );
  });

  test('reminderDays é imutável', () {
    final days = [30, 0];
    final d = deadline(reminderDays: days);
    days.add(5);
    expect(d.reminderDays, [30, 0]);
    expect(() => d.reminderDays.add(1), throwsUnsupportedError);
  });

  test('igualdade e toInput', () {
    expect(deadline(), deadline());
    expect(deadline().hashCode, deadline().hashCode);
    expect(deadline(), isNot(deadline(reminderDays: [30])));
    expect(
      deadline().toInput(),
      DeadlineInput(
        module: ModuleType.environmental,
        category: DeadlineCategory.license,
        authority: Authority.semace,
        title: 'Licença de Operação',
        dueDate: DateTime(2026, 10, 31),
        reminderDays: const [150, 30, 10, 3, 0],
      ),
    );
    expect(deadline().isOpen, isTrue);
    expect(deadline(status: DeadlineStatus.cancelled).isOpen, isFalse);
  });

  test('reminderDate atravessa mês e ano', () {
    expect(reminderDate(DateTime(2027, 1, 10), 30), DateTime(2026, 12, 11));
    expect(reminderDate(DateTime(2028, 3, 15), 15), DateTime(2028, 2, 29));
  });
}

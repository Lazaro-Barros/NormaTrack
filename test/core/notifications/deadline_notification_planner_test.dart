import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/notifications/deadline_notification_planner.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/features/deadlines/domain/deadline_status.dart';

void main() {
  // "Agora": 29/09/2026 às 9h (local). Datas conferidas por script (plan.md).
  final now = DateTime(2026, 9, 29, 9);
  final at = DateTime.utc(2026, 1, 1);
  const names = {'c1': 'Indústria Alfa Ltda'};

  Deadline deadline(
    String id,
    String title,
    DateTime due, {
    DeadlineCategory category = DeadlineCategory.license,
    List<int>? reminderDays,
    String companyId = 'c1',
    DeadlineStatus status = DeadlineStatus.active,
  }) => Deadline(
    id: id,
    companyId: companyId,
    module: ModuleType.environmental,
    category: category,
    title: title,
    dueDate: due,
    reminderDays: reminderDays ?? category.defaultReminderDays,
    status: status,
    createdAt: at,
    updatedAt: at,
  );

  final installation = deadline(
    'd1',
    'Licença de Instalação',
    DateTime(2026, 11, 13),
  );
  final operation = deadline(
    'd2',
    'Licença de Operação',
    DateTime(2026, 9, 26),
  );
  final oldReport = deadline(
    'd3',
    'Laudo antigo',
    DateTime(2026, 9, 9),
    category: DeadlineCategory.labReport,
  );
  final todayReport = deadline(
    'd4',
    'Laudo de hoje',
    DateTime(2026, 9, 29),
    category: DeadlineCategory.labReport,
  );
  final all = [installation, operation, oldReport, todayReport];

  DateTime at8(int month, int day) => DateTime(2026, month, day, 8);

  group('planDeadlineNotifications', () {
    test('lembretes futuros às 8h e semanal depois do vencimento', () {
      final plan = planDeadlineNotifications(all, names, now);
      expect(
        [for (final p in plan) (p.deadlineId, p.fireAt, p.weekly)],
        [
          ('d3', at8(9, 30), true),
          ('d2', at8(10, 3), true),
          ('d4', at8(10, 6), true),
          ('d1', at8(10, 14), false),
          ('d1', at8(11, 3), false),
          ('d1', at8(11, 10), false),
          ('d1', at8(11, 13), false),
          ('d1', at8(11, 20), true),
        ],
      );
    });

    test('textos com empresa e data do vencimento', () {
      final plan = planDeadlineNotifications(
        [installation, operation],
        names,
        now,
      );
      final bodies = [for (final p in plan) p.body];
      expect(bodies, [
        'Indústria Alfa Ltda · Vencido desde 26/09/2026',
        'Indústria Alfa Ltda · Vence em 30 dias (13/11/2026)',
        'Indústria Alfa Ltda · Vence em 10 dias (13/11/2026)',
        'Indústria Alfa Ltda · Vence em 3 dias (13/11/2026)',
        'Indústria Alfa Ltda · Vence hoje',
        'Indústria Alfa Ltda · Vencido desde 13/11/2026',
      ]);
      expect(plan.first.title, 'Licença de Operação');
      expect(plan.last.title, 'Licença de Instalação');
    });

    test('lembrete de 1 dia: "Vence amanhã"', () {
      final d = deadline(
        'd5',
        'Bomba',
        DateTime(2026, 10, 20),
        category: DeadlineCategory.maintenance,
        reminderDays: [1],
      );
      final plan = planDeadlineNotifications([d], names, now);
      expect(
        plan.first.body,
        'Indústria Alfa Ltda · Vence amanhã (20/10/2026)',
      );
      expect(plan.first.fireAt, at8(10, 19));
    });

    test('sem nome da empresa, texto sem separador', () {
      final d = deadline('d6', 'X', DateTime(2026, 9, 1), companyId: 'cX');
      final plan = planDeadlineNotifications([d], names, now);
      expect(plan.single.body, 'Vencido desde 01/09/2026');
    });

    test('exatamente às 8h do dia do lembrete não agenda', () {
      final d = deadline(
        'd7',
        'Laudo',
        DateTime(2026, 10, 9),
        category: DeadlineCategory.labReport,
      ); // lembrete de 10 dias = 29/09
      final at8now = DateTime(2026, 9, 29, 8);
      final plan = planDeadlineNotifications([d], names, at8now);
      expect(plan.where((p) => p.fireAt == at8now), isEmpty);
      final before = planDeadlineNotifications(
        [d],
        names,
        DateTime(2026, 9, 29, 7, 59),
      );
      expect(before.first.fireAt, at8now);
    });

    test('prazo fora de aberto não entra', () {
      final closed = deadline(
        'd8',
        'Fechado',
        DateTime(2026, 12, 1),
        status: DeadlineStatus.completed,
      );
      expect(planDeadlineNotifications([closed], names, now), isEmpty);
    });

    test('teto mantém os primeiros', () {
      final plan = planDeadlineNotifications(all, names, now, max: 3);
      expect([for (final p in plan) p.deadlineId], ['d3', 'd2', 'd4']);
    });

    test('lista vazia', () {
      expect(planDeadlineNotifications(const [], names, now), isEmpty);
    });
  });

  group('notificationIdFor', () {
    final date = DateTime(2026, 10, 14);

    test('estável e positivo', () {
      final a = notificationIdFor('d1', date, weekly: false);
      expect(
        notificationIdFor('d1', DateTime(2026, 10, 14, 8), weekly: false),
        a,
      );
      expect(a, inInclusiveRange(0, 0x7fffffff));
    });

    test('muda com prazo, data e tipo', () {
      final a = notificationIdFor('d1', date, weekly: false);
      expect(notificationIdFor('d2', date, weekly: false), isNot(a));
      expect(
        notificationIdFor('d1', DateTime(2026, 10, 15), weekly: false),
        isNot(a),
      );
      expect(notificationIdFor('d1', date, weekly: true), isNot(a));
    });

    test('ids do plano não se repetem', () {
      final plan = planDeadlineNotifications(all, names, now);
      expect({for (final p in plan) p.id}.length, plan.length);
    });
  });
}

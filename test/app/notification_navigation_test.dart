import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/app/widgets/status_banner.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../helpers/fake_company_repository.dart';
import '../helpers/fake_deadline_repository.dart';
import '../helpers/fake_notification_scheduler.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeDeadlineRepository deadlines;
  late FakeNotificationScheduler scheduler;
  late Deadline report;

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    deadlines = FakeDeadlineRepository(now: testNow, companies: companies);
    scheduler = FakeNotificationScheduler();
    final alfa = await companies.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    );
    report = await deadlines.seed(
      alfa.id,
      DeadlineInput(
        module: ModuleType.environmental,
        category: DeadlineCategory.labReport,
        title: 'Laudo da ETE',
        dueDate: DateTime(2026, 10, 11),
      ),
    );
  });

  Future<void> pump(WidgetTester tester, {String? initialLocation}) => pumpApp(
    tester,
    repository: companies,
    deadlineRepository: deadlines,
    notificationScheduler: scheduler,
    initialLocation: initialLocation ?? '/empresas',
  );

  testWidgets('tocar abre o detalhe; voltar leva ao Painel', (tester) async {
    await pump(tester);

    scheduler.tap(report.id);
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.widgetWithText(BandTitle, 'Laudo da ETE'), findsOne);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
  });

  testWidgets('prazo inexistente leva só ao Painel', (tester) async {
    await pump(tester);

    scheduler.tap('nao-existe');
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsNothing);
    expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
  });

  testWidgets('notificação que abriu o app abre o detalhe', (tester) async {
    scheduler.launch = report.id;
    await pump(tester);

    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.widgetWithText(BandTitle, 'Laudo da ETE'), findsOne);
  });
}

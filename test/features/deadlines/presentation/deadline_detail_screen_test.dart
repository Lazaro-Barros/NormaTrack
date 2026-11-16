import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/app/widgets/status_banner.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/fake_deadline_repository.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeDeadlineRepository deadlines;
  late String companyId;

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    deadlines = FakeDeadlineRepository(now: testNow, companies: companies);
    companyId = (await companies.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
  });

  Future<Deadline> seed({
    String title = 'Licença de Operação',
    DeadlineCategory category = DeadlineCategory.license,
    Authority? authority = Authority.semace,
    DateTime? due,
  }) => deadlines.seed(
    companyId,
    DeadlineInput(
      module: ModuleType.environmental,
      category: category,
      authority: authority,
      title: title,
      dueDate: due ?? DateTime(2026, 9, 26),
    ),
  );

  Future<void> pumpDetail(WidgetTester tester, String id, {String? company}) =>
      pumpApp(
        tester,
        repository: companies,
        deadlineRepository: deadlines,
        initialLocation: AppRoutes.deadline(
          company ?? companyId,
          ModuleType.environmental,
          id,
        ),
      );

  testWidgets('leitura: faixa, banner, dados e histórico', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);

    expect(find.widgetWithText(BandTitle, 'Licença de Operação'), findsOne);
    expect(find.text('Indústria Alfa Ltda · Ambiental'), findsOneWidget);
    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.text('Venceu há 3 dias'), findsOneWidget);
    expect(find.text('Alertas desde 29/04/2026'), findsOneWidget);
    expect(find.text('Licença'), findsOneWidget);
    expect(find.text('SEMACE'), findsOneWidget);
    expect(find.text('Lembretes'), findsOneWidget);
    expect(find.text('29/04/2026 · 150 dias antes'), findsOneWidget);
    expect(find.text('26/09/2026 · No dia do vencimento'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Ciclo atual'), findsOneWidget);
    expect(find.text('Vencimento em 26/09/2026'), findsOneWidget);
    expect(find.text('Vencido'), findsOneWidget);
  });

  testWidgets('sem órgão, sem a linha Órgão', (tester) async {
    final d = await seed(authority: null);
    await pumpDetail(tester, d.id);
    expect(find.text('Órgão'), findsNothing);
  });

  testWidgets('prazo inexistente', (tester) async {
    await pumpDetail(tester, 'nao-existe');
    expect(find.text('Prazo não encontrado'), findsOneWidget);
  });

  testWidgets('prazo de outra empresa', (tester) async {
    final d = await seed();
    final other = (await companies.seed(
      const CompanyInput(
        legalName: 'Beta',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
    await pumpDetail(tester, d.id, company: other);
    expect(find.text('Prazo não encontrado'), findsOneWidget);
  });

  testWidgets('empresa inexistente', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id, company: 'xx');
    expect(find.text('Empresa não encontrada'), findsOneWidget);
  });

  testWidgets('tocar no card do módulo abre o detalhe', (tester) async {
    await seed();
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      initialLocation: AppRoutes.module(companyId, ModuleType.environmental),
    );
    await tester.tap(find.text('Licença de Operação'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsOneWidget);
  });
}

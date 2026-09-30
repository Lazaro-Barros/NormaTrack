import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/app/widgets/deadline_card.dart';
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

  DeadlineInput input(
    String title,
    DateTime due, {
    DeadlineCategory category = DeadlineCategory.license,
    Authority? authority,
  }) => DeadlineInput(
    module: ModuleType.environmental,
    category: category,
    authority: authority,
    title: title,
    dueDate: due,
  );

  Future<void> pumpModule(WidgetTester tester, [String? location]) => pumpApp(
    tester,
    repository: companies,
    deadlineRepository: deadlines,
    initialLocation:
        location ?? AppRoutes.module(companyId, ModuleType.environmental),
  );

  testWidgets('prazos em seções por categoria, sem seção vazia', (
    tester,
  ) async {
    await deadlines.seed(
      companyId,
      input(
        'Bomba dosadora',
        DateTime(2027, 3, 15),
        category: DeadlineCategory.maintenance,
      ),
    );
    await deadlines.seed(
      companyId,
      input(
        'Licença de Operação',
        DateTime(2026, 9, 26),
        authority: Authority.semace,
      ),
    );
    await pumpModule(tester);

    expect(find.widgetWithText(BandTitle, 'Ambiental'), findsOne);
    expect(find.text('Indústria Alfa Ltda'), findsOneWidget);
    expect(find.text('Licenças'), findsOneWidget);
    expect(find.text('Laudos'), findsNothing);
    expect(find.text('Manutenções'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Licenças')).dy,
      lessThan(tester.getTopLeft(find.text('Manutenções')).dy),
    );
    expect(find.byType(DeadlineCard), findsNWidgets(2));
    expect(find.text('Licença · SEMACE'), findsOneWidget);
    expect(find.text('Venceu'), findsOneWidget);
    expect(find.text('há 3 dias'), findsOneWidget);
    expect(find.text('MAR 27'), findsOneWidget);
  });

  testWidgets('vazio oferece cadastrar prazo', (tester) async {
    await pumpModule(tester);

    expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
    await tester.tap(find.text('Cadastrar prazo'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Novo prazo'), findsOne);
  });

  testWidgets('FAB abre novo prazo e o card abre a edição', (tester) async {
    await deadlines.seed(
      companyId,
      input('Licença de Operação', DateTime(2026, 10, 31)),
    );
    await pumpModule(tester);

    await tester.tap(find.text('Novo prazo'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Novo prazo'), findsOne);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DeadlineCard));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Editar prazo'), findsOne);
  });

  testWidgets('módulo desligado', (tester) async {
    await pumpModule(
      tester,
      AppRoutes.module(companyId, ModuleType.qualityControl),
    );
    expect(find.text('Módulo desligado'), findsOneWidget);
    expect(find.text('Editar empresa'), findsOneWidget);
  });

  testWidgets('módulo inexistente', (tester) async {
    await pumpModule(tester, '/empresas/$companyId/modulos/nada');
    expect(find.text('Módulo não encontrado'), findsOneWidget);
  });

  testWidgets('empresa inexistente', (tester) async {
    await pumpModule(
      tester,
      AppRoutes.module('nada', ModuleType.environmental),
    );
    expect(find.text('Empresa não encontrada'), findsOneWidget);
  });
}

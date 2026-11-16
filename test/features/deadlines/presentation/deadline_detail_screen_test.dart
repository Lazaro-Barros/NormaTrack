import 'package:flutter/material.dart';
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

  // ---- ações ---------------------------------------------------------------

  Finder menuItem(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is PopupMenuItem),
    matching: find.text(label),
  );

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
  }

  testWidgets('licença em aberto: barra e menu', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    expect(find.widgetWithText(OutlinedButton, 'Editar'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Registrar renovação'),
      findsOneWidget,
    );
    expect(find.text('Concluir'), findsNothing);
    await openMenu(tester);
    expect(menuItem('Cancelar prazo'), findsOneWidget);
    expect(menuItem('Excluir prazo'), findsOneWidget);
    expect(menuItem('Registrar renovação'), findsNothing);
  });

  testWidgets('laudo em aberto: Concluir primário, renovar no menu', (
    tester,
  ) async {
    final d = await seed(
      title: 'Laudo da ETE',
      category: DeadlineCategory.labReport,
    );
    await pumpDetail(tester, d.id);
    expect(find.widgetWithText(FilledButton, 'Concluir'), findsOneWidget);
    await openMenu(tester);
    expect(menuItem('Registrar renovação'), findsOneWidget);
  });

  testWidgets('renovar duas vezes, com sugestão e histórico', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar renovação'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Novo vencimento'), findsOneWidget);
    expect(find.text('26/09/2027'), findsOneWidget);
    expect(find.text('Alertas a partir de 29/04/2027'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Renovar'));
    await tester.pumpAndSettle();

    expect(find.text('Prazo renovado'), findsOneWidget);
    expect(find.text('Em 362 dias'), findsOneWidget);
    expect(find.text('Ciclo atual'), findsOneWidget);
    expect(find.text('26/09/2026 → 26/09/2027'), findsOneWidget);
    expect(find.text('Vigente'), findsOneWidget);
    expect(find.text('Ciclo anterior'), findsOneWidget);
    expect(find.text('Vencimento em 26/09/2026'), findsOneWidget);
    expect(find.text('Renovado'), findsOneWidget);

    // Segunda renovação: o intervalo (12 meses) se repete.
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar renovação'));
    await tester.pumpAndSettle();
    expect(find.text('26/09/2028'), findsOneWidget);
  });

  testWidgets('fechar o sheet de renovação não muda nada', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar renovação'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(deadlines.all.length, 1);
    expect(find.text('Venceu há 3 dias'), findsOneWidget);
  });

  testWidgets('concluir e reabrir', (tester) async {
    final d = await seed(
      title: 'Laudo da ETE',
      category: DeadlineCategory.labReport,
    );
    await pumpDetail(tester, d.id);
    await tester.tap(find.widgetWithText(FilledButton, 'Concluir'));
    await tester.pumpAndSettle();
    expect(find.text('Concluir prazo'), findsOneWidget);
    expect(find.text('29/09/2026'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.widgetWithText(FilledButton, 'Concluir'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prazo concluído'), findsOneWidget);
    expect(find.text('Concluído em 29/09/2026'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reabrir'), findsOneWidget);
    await openMenu(tester);
    expect(menuItem('Excluir prazo'), findsOneWidget);
    expect(menuItem('Cancelar prazo'), findsNothing);
    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Reabrir'));
    await tester.pumpAndSettle();
    expect(find.text('Prazo reaberto'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Concluir'), findsOneWidget);
  });

  testWidgets('cancelar: Voltar não muda; confirmar cancela', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    await openMenu(tester);
    await tester.tap(menuItem('Cancelar prazo'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelar este prazo?'), findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Venceu há 3 dias'), findsOneWidget);

    await openMenu(tester);
    await tester.tap(menuItem('Cancelar prazo'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar prazo'));
    await tester.pumpAndSettle();
    expect(find.text('Prazo cancelado'), findsOneWidget);
    expect(find.text('Cancelado'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Reabrir'), findsOneWidget);
  });

  testWidgets('excluir ciclo renovado avisa e reabre o anterior', (
    tester,
  ) async {
    final d = await seed();
    final next = await deadlines.renew(d.id, newDueDate: DateTime(2027, 9, 26));
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      initialLocation: AppRoutes.deadline(
        companyId,
        ModuleType.environmental,
        next.id,
      ),
    );
    await openMenu(tester);
    await tester.tap(menuItem('Excluir prazo'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('O ciclo anterior volta a ficar em aberto.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Prazo excluído'), findsOneWidget);
    expect(find.byType(StatusBanner), findsNothing);
    expect(find.text('Licença de Operação'), findsOneWidget); // na lista
    expect(find.text('Nenhum prazo em aberto'), findsNothing);
  });

  testWidgets('excluir prazo sem anterior não traz o aviso', (tester) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    await openMenu(tester);
    await tester.tap(menuItem('Excluir prazo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ciclo anterior'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
  });

  testWidgets('renovado aberto por URL: somente leitura', (tester) async {
    final d = await seed();
    await deadlines.renew(d.id, newDueDate: DateTime(2027, 9, 26));
    await pumpDetail(tester, d.id);
    expect(find.text('Renovado'), findsWidgets);
    expect(find.byTooltip('Mais opções'), findsNothing);
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('Editar abre o formulário e salvar volta ao detalhe', (
    tester,
  ) async {
    final d = await seed();
    await pumpDetail(tester, d.id);
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Editar prazo'), findsOne);
    await tester.tap(find.text('Salvar prazo'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsOneWidget);
  });
}

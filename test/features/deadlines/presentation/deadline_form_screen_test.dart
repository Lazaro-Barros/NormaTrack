import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/fake_deadline_repository.dart';
import '../../../helpers/finders.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeDeadlineRepository deadlines;
  late String companyId;
  const env = ModuleType.environmental;

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    deadlines = FakeDeadlineRepository(now: testNow, companies: companies);
    companyId = (await companies.seed(
      const CompanyInput(legalName: 'Alfa', enabledModules: {env}),
    )).id;
  });

  /// Abre pelo módulo, para que salvar e fechar voltem para ele.
  Future<void> openNew(WidgetTester tester) async {
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      initialLocation: AppRoutes.module(companyId, env),
    );
    await tester.tap(find.text('Novo prazo'));
    await tester.pumpAndSettle();
  }

  Finder reminderRows() => find.textContaining(RegExp(r'antes$|^No dia do'));

  Future<void> pickDay(WidgetTester tester, String day) async {
    await tester.tap(fieldLabeled('Vencimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(day).last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> removeReminder(WidgetTester tester, String label) async {
    final button = find.byTooltip('Remover lembrete: $label');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> addReminder(
    WidgetTester tester, {
    String? chip,
    String? typed,
  }) async {
    await tester.ensureVisible(find.text('Adicionar lembrete'));
    await tester.tap(find.text('Adicionar lembrete'));
    await tester.pumpAndSettle();
    if (chip != null) await tester.tap(find.widgetWithText(ChoiceChip, chip));
    if (typed != null) {
      await tester.enterText(fieldLabeled('Dias antes do vencimento'), typed);
    }
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
  }

  testWidgets('novo prazo começa com os lembretes da licença', (tester) async {
    await openNew(tester);

    expect(find.widgetWithText(BandTitle, 'Novo prazo'), findsOne);
    expect(find.text('Alfa · Ambiental'), findsOneWidget);
    expect(reminderRows(), findsNWidgets(5));
    expect(find.text('150 dias antes'), findsOneWidget);
    expect(find.text('Primeiro alerta'), findsOneWidget);
    expect(find.textContaining('Alertas a partir de'), findsNothing);

    await pickDay(tester, '30');
    expect(fieldText(tester, fieldLabeled('Vencimento')), '30/09/2026');
    expect(find.text('Alertas a partir de 03/05/2026'), findsOneWidget);
  });

  testWidgets('trocar categoria repõe os lembretes até a usuária mexer', (
    tester,
  ) async {
    await openNew(tester);

    await tester.tap(find.text('Laudo'));
    await tester.pumpAndSettle();
    expect(reminderRows(), findsNWidgets(4));
    expect(find.text('150 dias antes'), findsNothing);

    await removeReminder(tester, '3 dias antes');
    expect(reminderRows(), findsNWidgets(3));

    await tester.tap(find.text('Licença'));
    await tester.pumpAndSettle();
    expect(reminderRows(), findsNWidgets(3));
    expect(find.text('150 dias antes'), findsNothing);
  });

  testWidgets('sheet adiciona por atalho e digitado, e recusa repetido', (
    tester,
  ) async {
    await openNew(tester);
    await tester.tap(find.text('Manutenção'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Adicionar lembrete'));
    await tester.tap(find.text('Adicionar lembrete'));
    await tester.pumpAndSettle();
    // Manutenção já tem 30, 10, 3 e 0: os atalhos escondem 30 e "No dia".
    expect(find.widgetWithText(ChoiceChip, '30 dias'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'No dia'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '60 dias'), findsOneWidget);

    await tester.enterText(fieldLabeled('Dias antes do vencimento'), '10');
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Este lembrete já está na lista'), findsOneWidget);
    await tester.tap(find.byTooltip('Fechar').last);
    await tester.pumpAndSettle();

    await addReminder(tester, chip: '60 dias');
    await addReminder(tester, typed: '45');
    expect(find.text('60 dias antes'), findsOneWidget);
    expect(find.text('45 dias antes'), findsOneWidget);
    expect(reminderRows(), findsNWidgets(6));
    final order = [
      '60 dias antes',
      '45 dias antes',
      '30 dias antes',
    ].map((t) => tester.getTopLeft(find.text(t)).dy).toList();
    expect(order, orderedEquals([...order]..sort()));
  });

  testWidgets('salvar sem título, vencimento e lembretes mostra os erros', (
    tester,
  ) async {
    await openNew(tester);
    for (final days in [150, 30, 10, 3]) {
      await removeReminder(tester, '$days dias antes');
    }
    await removeReminder(tester, 'No dia do vencimento');

    await tester.tap(find.text('Salvar prazo'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o título'), findsOneWidget);
    expect(find.text('Informe o vencimento'), findsOneWidget);
    expect(find.text('Adicione ao menos um lembrete'), findsOneWidget);
    expect(deadlines.all, isEmpty);
  });

  testWidgets('salvar cria o prazo e volta ao módulo', (tester) async {
    await openNew(tester);
    await tester.enterText(fieldLabeled('Título'), '  Licença de Operação ');
    await pickDay(tester, '30');
    await tester.tap(find.text('Salvar prazo'));
    await tester.pumpAndSettle();

    final saved = deadlines.all.single;
    expect(saved.title, 'Licença de Operação');
    expect(saved.dueDate, DateTime(2026, 9, 30));
    expect(saved.category, DeadlineCategory.license);
    expect(saved.reminderDays, [150, 30, 10, 3, 0]);
    expect(find.text('Prazo salvo'), findsOneWidget);
    expect(find.widgetWithText(BandTitle, 'Ambiental'), findsOne);
    expect(find.text('Licença de Operação'), findsOneWidget);
    expect(find.text('amanhã'), findsOneWidget);
  });

  testWidgets('editar carrega os valores e salva', (tester) async {
    final d = await deadlines.seed(
      companyId,
      DeadlineInput(
        module: env,
        category: DeadlineCategory.labReport,
        authority: Authority.semace,
        title: 'Laudo da ETE',
        dueDate: DateTime(2026, 11, 8),
        reminderDays: const [20, 0],
      ),
    );
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      initialLocation: AppRoutes.module(companyId, env),
    );
    await tester.tap(find.text('Laudo da ETE'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(BandTitle, 'Editar prazo'), findsOne);
    expect(fieldText(tester, fieldLabeled('Título')), 'Laudo da ETE');
    expect(fieldText(tester, fieldLabeled('Vencimento')), '08/11/2026');
    expect(find.text('SEMACE'), findsOneWidget);
    expect(reminderRows(), findsNWidgets(2));
    expect(find.text('Alertas a partir de 19/10/2026'), findsOneWidget);

    // Na edição, trocar categoria não mexe nos lembretes.
    await tester.tap(find.text('Manutenção'));
    await tester.enterText(fieldLabeled('Título'), 'Laudo da ETA');
    await tester.tap(find.text('Salvar prazo'));
    await tester.pumpAndSettle();

    final saved = (await deadlines.findById(d.id))!;
    expect(saved.title, 'Laudo da ETA');
    expect(saved.category, DeadlineCategory.maintenance);
    expect(saved.reminderDays, [20, 0]);
  });

  testWidgets('fechar com alterações pede confirmação', (tester) async {
    await openNew(tester);
    await tester.enterText(fieldLabeled('Título'), 'Algo');
    await tester.pump();
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Ambiental'), findsOne);
  });

  testWidgets('prazo inexistente', (tester) async {
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      initialLocation: AppRoutes.editDeadline(companyId, env, 'nada'),
    );
    expect(find.text('Prazo não encontrado'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/app/widgets/deadline_card.dart';
import 'package:normatrack/app/widgets/pending_row.dart';
import 'package:normatrack/app/widgets/stat_tile.dart';
import 'package:normatrack/app/widgets/status_banner.dart';
import 'package:normatrack/app/widgets/status_text.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/fake_deadline_repository.dart';
import '../../../helpers/fake_measurement_repository.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeDeadlineRepository deadlines;
  late String alfa;
  late String beta;

  // "Hoje" = 29/09/2026. Dias até o vencimento: −3, 12, 45 e 167.
  const all = [
    'Licença de Operação',
    'Laudo da ETE',
    'Licença de Instalação',
    'Bomba dosadora',
  ];

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    deadlines = FakeDeadlineRepository(now: testNow, companies: companies);
    alfa = (await companies.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
    beta = (await companies.seed(
      const CompanyInput(
        legalName: 'Beta Indústria de Alimentos S.A.',
        tradeName: 'Beta Alimentos',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
  });

  Future<Deadline> seed(
    String companyId,
    String title,
    DateTime due, {
    DeadlineCategory category = DeadlineCategory.license,
  }) => deadlines.seed(
    companyId,
    DeadlineInput(
      module: ModuleType.environmental,
      category: category,
      title: title,
      dueDate: due,
    ),
  );

  Future<void> seedAll() async {
    // Fora de ordem, para provar a ordenação por vencimento.
    await seed(
      beta,
      'Bomba dosadora',
      DateTime(2027, 3, 15),
      category: DeadlineCategory.maintenance,
    );
    await seed(beta, 'Licença de Instalação', DateTime(2026, 11, 13));
    await seed(
      alfa,
      'Laudo da ETE',
      DateTime(2026, 10, 11),
      category: DeadlineCategory.labReport,
    );
    await seed(alfa, 'Licença de Operação', DateTime(2026, 9, 26));
  }

  Future<void> pumpDashboard(WidgetTester tester) =>
      pumpApp(tester, repository: companies, deadlineRepository: deadlines);

  Finder tile(String label) =>
      find.byWidgetPredicate((w) => w is StatTile && w.label == label);

  Finder card(String title) => find.widgetWithText(DeadlineCard, title);

  /// Títulos dos cards na ordem em que aparecem.
  List<String> cardTitles(WidgetTester tester) => [
    for (final c in tester.widgetList<DeadlineCard>(find.byType(DeadlineCard)))
      c.title,
  ];

  void expectCounts(WidgetTester tester, int overdue, int dueSoon, int ok) {
    expect(tester.widget<StatTile>(tile('Vencidos')).count, overdue);
    expect(tester.widget<StatTile>(tile('A vencer')).count, dueSoon);
    expect(tester.widget<StatTile>(tile('Vigentes')).count, ok);
  }

  testWidgets('tiles com a contagem e lista na ordem de vencimento', (
    tester,
  ) async {
    await seedAll();
    await pumpDashboard(tester);

    expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
    expectCounts(tester, 1, 2, 1);
    expect(find.bySemanticsLabel('1 Vencidos'), findsOneWidget);
    expect(find.bySemanticsLabel('2 A vencer'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Vigentes'), findsOneWidget);
    expect(find.text('Próximos vencimentos'), findsOneWidget);
    expect(cardTitles(tester), all);

    final operation = tester.widget<DeadlineCard>(card('Licença de Operação'));
    expect(operation.subtitle, 'Indústria Alfa Ltda');
    expect(
      (operation.statusLead, operation.statusText),
      ('Venceu', 'há 3 dias'),
    );
    final report = tester.widget<DeadlineCard>(card('Laudo da ETE'));
    expect((report.statusLead, report.statusText), ('Vence', 'em 12 dias'));
    final installation = tester.widget<DeadlineCard>(
      card('Licença de Instalação'),
    );
    expect(installation.subtitle, 'Beta Alimentos');
    expect(
      (installation.statusLead, installation.statusText),
      ('Vence', 'em 45 dias'),
    );
    final pump = tester.widget<DeadlineCard>(card('Bomba dosadora'));
    expect((pump.statusLead, pump.statusText), (null, 'Em 167 dias'));
    expect(pump.showYear, isTrue);
    expect(operation.showYear, isFalse);
  });

  testWidgets('tocar no tile filtra; tocar de novo mostra todos', (
    tester,
  ) async {
    await seedAll();
    await pumpDashboard(tester);

    await tester.tap(tile('A vencer'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), ['Laudo da ETE', 'Licença de Instalação']);
    expect(tester.widget<StatTile>(tile('A vencer')).selected, isTrue);
    expect(tester.widget<StatTile>(tile('Vencidos')).selected, isFalse);
    expectCounts(tester, 1, 2, 1); // os tiles contam a lista inteira

    await tester.tap(tile('Vencidos'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), ['Licença de Operação']);
    expect(tester.widget<StatTile>(tile('A vencer')).selected, isFalse);
    expect(tester.widget<StatTile>(tile('Vencidos')).selected, isTrue);

    await tester.tap(tile('Vigentes'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), ['Bomba dosadora']);

    await tester.tap(tile('Vigentes'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), all);
    expect(tester.widget<StatTile>(tile('Vigentes')).selected, isFalse);
  });

  testWidgets('card abre o detalhe; voltar retorna com o filtro mantido', (
    tester,
  ) async {
    await seedAll();
    await pumpDashboard(tester);
    await tester.tap(tile('A vencer'));
    await tester.pumpAndSettle();

    await tester.tap(card('Laudo da ETE'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsOneWidget);
    expect(find.widgetWithText(BandTitle, 'Laudo da ETE'), findsOne);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(StatusBanner), findsNothing);
    expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
    expect(tester.widget<StatTile>(tile('A vencer')).selected, isTrue);
    expect(cardTitles(tester), ['Laudo da ETE', 'Licença de Instalação']);
  });

  testWidgets('sem prazos: vazio com "Ver empresas"', (tester) async {
    await pumpDashboard(tester);

    expectCounts(tester, 0, 0, 0);
    expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Ver empresas'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Empresas'), findsOne);
  });

  testWidgets('filtro sem resultado: vazio do filtro, sem ação', (
    tester,
  ) async {
    await seed(
      beta,
      'Bomba dosadora',
      DateTime(2027, 3, 15),
      category: DeadlineCategory.maintenance,
    );
    await pumpDashboard(tester);

    await tester.tap(tile('Vencidos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum prazo vencido'), findsOneWidget);
    expect(
      find.text('Toque de novo no filtro para ver todos os prazos.'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(DeadlineCard), findsNothing);

    await tester.tap(tile('A vencer'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum prazo a vencer'), findsOneWidget);
  });

  testWidgets('arquivada, módulo desligado e encerrados não aparecem', (
    tester,
  ) async {
    await seedAll();
    final gama = (await companies.seed(
      const CompanyInput(
        legalName: 'Gama Bebidas Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
    await seed(gama, 'Licença da Gama', DateTime(2026, 10, 1));
    await companies.update(
      gama,
      const CompanyInput(legalName: 'Gama Bebidas Ltda'),
    );
    final delta = (await companies.seed(
      const CompanyInput(
        legalName: 'Delta Química Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
    await seed(delta, 'Licença da Delta', DateTime(2026, 10, 2));
    await companies.archive(delta);
    final done = await seed(
      alfa,
      'Laudo concluído',
      DateTime(2026, 10, 3),
      category: DeadlineCategory.labReport,
    );
    await deadlines.complete(done.id, completedOn: DateTime(2026, 9, 28));
    final cancelled = await seed(
      alfa,
      'Licença cancelada',
      DateTime(2026, 9, 1),
    );
    await deadlines.cancel(cancelled.id);

    await pumpDashboard(tester);
    expect(cardTitles(tester), all);
    expectCounts(tester, 1, 2, 1);
  });

  testWidgets('atualiza sozinha ao criar e ao arquivar', (tester) async {
    await seedAll();
    await pumpDashboard(tester);

    await tester.runAsync(
      () => seed(alfa, 'Licença nova', DateTime(2026, 9, 20)),
    );
    await tester.pumpAndSettle();
    expectCounts(tester, 2, 2, 1);
    expect(cardTitles(tester).first, 'Licença nova');

    await tester.runAsync(() => companies.archive(beta));
    await tester.pumpAndSettle();
    expectCounts(tester, 2, 1, 0);
    expect(cardTitles(tester), [
      'Licença nova',
      'Licença de Operação',
      'Laudo da ETE',
    ]);
  });

  testWidgets('excluir no detalhe aberto pelo Painel volta ao Painel', (
    tester,
  ) async {
    await seedAll();
    await pumpDashboard(tester);

    await tester.tap(card('Laudo da ETE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byWidgetPredicate((w) => w is PopupMenuItem),
        matching: find.text('Excluir prazo'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Prazo excluído'), findsOneWidget);
    expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
    expect(cardTitles(tester), [
      'Licença de Operação',
      'Licença de Instalação',
      'Bomba dosadora',
    ]);
    expectCounts(tester, 1, 1, 1);
  });

  testWidgets('vira o dia ao voltar o app para a frente e à meia-noite', (
    tester,
  ) async {
    await seed(alfa, 'Licença de Operação', DateTime(2026, 9, 26));
    var now = testNow;
    await pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      clock: () => now,
    );
    String status() {
      final c = tester.widget<DeadlineCard>(card('Licença de Operação'));
      return '${c.statusLead} ${c.statusText}';
    }

    expect(status(), 'Venceu há 3 dias');

    // App em segundo plano desde a véspera.
    now = testNow.add(const Duration(days: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(status(), 'Venceu há 4 dias');

    // App aberto na virada: o timer da meia-noite dispara.
    now = testNow.add(const Duration(days: 2));
    await tester.pump(const Duration(days: 1));
    await tester.pumpAndSettle();
    expect(status(), 'Venceu há 5 dias');
  });

  group('lançamentos pendentes', () {
    late FakeMeasurementRepository measurements;
    late List<String> alfaPoints;

    // Hoje = terça 29/09/2026, semana 40. Alfa: pontos desde a semana 38
    // (14 a 20/09) → 38 e 39 atrasadas e 40 a lançar. Beta: desde a 40.
    setUp(() {
      measurements = FakeMeasurementRepository(
        now: testNow,
        companies: companies,
      );
      measurements.seedPoint(beta, 'Divisa', startDate: DateTime(2026, 9, 28));
      alfaPoints = [
        for (final name in ['Portaria', 'Caldeira'])
          measurements
              .seedPoint(alfa, name, startDate: DateTime(2026, 9, 14))
              .id,
      ];
    });

    Future<void> pumpWithPending(WidgetTester tester) => pumpApp(
      tester,
      repository: companies,
      deadlineRepository: deadlines,
      measurementRepository: measurements,
    );

    List<(String, String?, String)> rows(WidgetTester tester) => [
      for (final r in tester.widgetList<PendingRow>(find.byType(PendingRow)))
        (r.title, r.subtitle, r.statusLabel),
    ];

    testWidgets('uma linha por empresa, acima dos vencimentos', (tester) async {
      await seedAll();
      await pumpWithPending(tester);

      expect(find.text('Lançamentos pendentes'), findsOneWidget);
      // Contagem ao lado do título (fora dos tiles da faixa).
      expect(
        find.descendant(of: find.byType(ListView), matching: find.text('2')),
        findsOneWidget,
      );
      expect(rows(tester), [
        (
          'Ruídos · Indústria Alfa Ltda',
          'Semana 38 · 14 a 20/09/2026',
          '2 semanas atrasadas',
        ),
        (
          'Ruídos · Beta Alimentos',
          'Semana 40 · 28/09 a 04/10/2026',
          'A lançar',
        ),
      ]);
      final tones = [
        for (final s in tester.widgetList<StatusText>(
          find.descendant(
            of: find.byType(PendingRow),
            matching: find.byType(StatusText),
          ),
        ))
          s.tone,
      ];
      expect(tones, [StatusTone.overdue, StatusTone.dueSoon]);
      // Seção antes dos vencimentos; tiles só com prazos.
      expect(
        tester.getTopLeft(find.text('Lançamentos pendentes')).dy,
        lessThan(tester.getTopLeft(find.text('Próximos vencimentos')).dy),
      );
      expectCounts(tester, 1, 2, 1);
    });

    testWidgets('"Lançar" abre a semana mais antiga; voltar ao Painel', (
      tester,
    ) async {
      await pumpWithPending(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Lançar').first);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(BandTitle, 'Ruídos'), findsOne);
      expect(find.text('Semana 38'), findsOneWidget);
      expect(find.text('14 a 20/09/2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(BandTitle, 'Painel'), findsOne);
    });

    testWidgets('lançar a mais antiga passa a linha para a seguinte', (
      tester,
    ) async {
      await pumpWithPending(tester);

      final week38 = DateTime(2026, 9, 14);
      await tester.runAsync(() async {
        for (final id in alfaPoints) {
          measurements.seedMeasurement(id, week38, value: 60);
        }
      });
      await tester.pumpAndSettle();
      expect(rows(tester).first, (
        'Ruídos · Indústria Alfa Ltda',
        'Semana 39 · 21 a 27/09/2026',
        '1 semana atrasada',
      ));
    });

    testWidgets('tile selecionado esconde a seção', (tester) async {
      await seedAll();
      await pumpWithPending(tester);

      await tester.tap(tile('A vencer'));
      await tester.pumpAndSettle();
      expect(find.text('Lançamentos pendentes'), findsNothing);
      expect(find.byType(PendingRow), findsNothing);

      await tester.tap(tile('A vencer'));
      await tester.pumpAndSettle();
      expect(find.byType(PendingRow), findsNWidgets(2));
    });

    testWidgets('sem prazos: seção e o vazio dos prazos abaixo', (
      tester,
    ) async {
      await pumpWithPending(tester);

      expect(find.byType(PendingRow), findsNWidgets(2));
      expect(find.text('Próximos vencimentos'), findsOneWidget);
      expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Nenhum prazo em aberto')).dy,
        greaterThan(tester.getTopLeft(find.byType(PendingRow).last).dy),
      );
    });

    testWidgets('arquivada e Ambiental desligado não aparecem', (tester) async {
      await companies.archive(beta);
      await companies.update(
        alfa,
        const CompanyInput(legalName: 'Indústria Alfa Ltda'),
      );
      await pumpWithPending(tester);

      expect(find.text('Lançamentos pendentes'), findsNothing);
      expect(find.text('Nenhum prazo em aberto'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/measurement_input_row.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/measurements/domain/measurement.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/fake_measurement_repository.dart';
import '../../../helpers/finders.dart';
import '../../../helpers/pump_app.dart';

// `testNow` = terça 29/09/2026 → semana 40 (28/09 a 04/10/2026).
void main() {
  late FakeCompanyRepository companies;
  late FakeMeasurementRepository measurements;
  late String companyId;
  final w39 = DateTime(2026, 9, 21);
  final w40 = DateTime(2026, 9, 28);

  setUp(() async {
    companies = FakeCompanyRepository(now: testNow);
    measurements = FakeMeasurementRepository(
      now: testNow,
      companies: companies,
    );
    companyId = (await companies.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        enabledModules: {ModuleType.environmental},
      ),
    )).id;
  });

  Future<void> pumpLaunch(WidgetTester tester, {DateTime? week}) => pumpApp(
    tester,
    repository: companies,
    measurementRepository: measurements,
    initialLocation: AppRoutes.noise(companyId, week: week),
  );

  Finder valueField(int n) => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is MeasurementInputRow && w.number == n,
    ),
    matching: find.byType(TextField),
  );

  Future<void> type(WidgetTester tester, int n, String text) async {
    await tester.enterText(valueField(n), text);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
  }

  Measurement? savedIn(String pointId, DateTime week) => measurements
      .measurements
      .where((m) => m.parameterId == pointId && m.periodStart == week)
      .firstOrNull;

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'))
          .onPressed !=
      null;

  testWidgets('semana atual na faixa; próxima desabilitada; anterior', (
    tester,
  ) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);
    expect(find.text('Ruídos'), findsOneWidget);
    expect(find.text('Semana 40'), findsOneWidget);
    expect(find.text('28/09 a 04/10/2026'), findsOneWidget);
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);

    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    expect(find.text('Semana 39'), findsOneWidget);
    expect(find.text('21 a 27/09/2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(find.text('Semana 40'), findsOneWidget);
  });

  testWidgets('anterior, limite ao digitar e salvar parcial', (tester) async {
    final portao = measurements.seedPoint(companyId, 'Portão', limitMax: 70);
    final divisa = measurements.seedPoint(companyId, 'Divisa');
    measurements
      ..seedMeasurement(portao.id, w39, value: 61.8)
      ..seedMeasurement(divisa.id, DateTime(2026, 9, 14), note: 'Chuva');
    await pumpLaunch(tester);

    expect(find.text('Anterior: 61,8'), findsOneWidget);
    expect(find.text('Anterior: sem medição'), findsOneWidget);
    expect(find.text('0 de 2'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);

    await type(tester, 1, '72.5');
    expect(find.text('Acima do limite (70,0)'), findsOneWidget);
    expect(find.text('1 de 2'), findsOneWidget);
    await type(tester, 1, '70');
    expect(find.text('Acima do limite (70,0)'), findsNothing);

    await save(tester);
    expect(find.text('Semana 40 salva'), findsOneWidget);
    expect(measurements.saved.single.$2, {
      portao.id: const MeasurementEntry(value: 70),
    });
    expect(savedIn(portao.id, w40)!.value, 70);
    expect(savedIn(divisa.id, w40), isNull);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('apagar o valor e salvar remove a medição', (tester) async {
    final portao = measurements.seedPoint(companyId, 'Portão');
    measurements.seedMeasurement(portao.id, w40, value: 61.8, note: 'obs');
    await pumpLaunch(tester);
    expect(tester.widget<TextField>(valueField(1)).controller!.text, '61,8');

    await type(tester, 1, '');
    await save(tester);
    expect(savedIn(portao.id, w40), isNull);
  });

  testWidgets('editar o valor preserva a observação', (tester) async {
    final portao = measurements.seedPoint(companyId, 'Portão');
    measurements.seedMeasurement(portao.id, w40, value: 61.8, note: 'obs');
    await pumpLaunch(tester);
    await type(tester, 1, '62');
    await save(tester);
    expect(savedIn(portao.id, w40)!.note, 'obs');
  });

  testWidgets('sem medição neste ponto, com motivo, e Desfazer', (
    tester,
  ) async {
    final portao = measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);

    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sem medição neste ponto'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o motivo'), findsOneWidget);
    await tester.enterText(fieldLabeled('Motivo'), '  Ponto   inacessível ');
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Sem medição: Ponto inacessível'), findsOneWidget);
    expect(find.text('1 de 1'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));
    await tester.pump();
    expect(find.text('0 de 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sem medição neste ponto'));
    await tester.pumpAndSettle();
    await tester.enterText(fieldLabeled('Motivo'), 'Obra');
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();
    await save(tester);
    final m = savedIn(portao.id, w40)!;
    expect((m.value, m.note), (null, 'Obra'));
  });

  testWidgets('sem medição nesta semana só nos pontos vazios', (tester) async {
    final portao = measurements.seedPoint(companyId, 'Portão');
    final divisa = measurements.seedPoint(companyId, 'Divisa');
    final galpao = measurements.seedPoint(companyId, 'Galpão');
    await pumpLaunch(tester);

    await type(tester, 1, '60');
    await tester.tap(find.text('Sem medição nesta semana'));
    await tester.pumpAndSettle();
    expect(
      find.text('O motivo vale para os pontos ainda sem valor.'),
      findsOneWidget,
    );
    await tester.enterText(fieldLabeled('Motivo'), 'Fábrica parada');
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Sem medição: Fábrica parada'), findsNWidgets(2));
    expect(find.text('3 de 3'), findsOneWidget);
    expect(find.text('Sem medição nesta semana'), findsNothing);
    await save(tester);
    expect(savedIn(portao.id, w40)!.value, 60);
    expect(savedIn(divisa.id, w40)!.note, 'Fábrica parada');
    expect(savedIn(galpao.id, w40)!.note, 'Fábrica parada');
  });

  testWidgets('trocar de semana com alteração pede confirmação', (
    tester,
  ) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);
    await type(tester, 1, '60');

    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Semana 40'), findsOneWidget);
    expect(tester.widget<TextField>(valueField(1)).controller!.text, '60');

    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Semana 39'), findsOneWidget);
    expect(tester.widget<TextField>(valueField(1)).controller!.text, '');
  });

  testWidgets('voltar com alteração pede confirmação', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    // A rota aninhada põe o módulo embaixo do lançamento.
    await pumpLaunch(tester);
    await type(tester, 1, '60');

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Semana 40'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Ambiental'), findsOneWidget);
    expect(measurements.saved, isEmpty);
  });

  testWidgets('voltar sem alteração não pergunta', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsNothing);
    expect(find.text('Ambiental'), findsOneWidget);
  });

  testWidgets('valor inválido não grava', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);
    await type(tester, 1, ',');
    await save(tester);
    expect(find.text('Valor inválido'), findsOneWidget);
    expect(measurements.saved, isEmpty);
  });

  testWidgets('semana pela rota', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester, week: DateTime(2026, 9, 23));
    expect(find.text('Semana 39'), findsOneWidget);
  });

  testWidgets('semana futura pela rota abre a atual', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester, week: DateTime(2026, 10, 20));
    expect(find.text('Semana 40'), findsOneWidget);
  });

  testWidgets('linhas: desativado só com medição; início posterior fora', (
    tester,
  ) async {
    final antigo = measurements.seedPoint(
      companyId,
      'Portaria antiga',
      archived: true,
    );
    measurements
      ..seedPoint(companyId, 'Portão')
      ..seedPoint(companyId, 'Novo', startDate: DateTime(2026, 9, 29))
      ..seedMeasurement(antigo.id, w39, value: 50);
    await pumpLaunch(tester, week: w39);
    expect(find.text('Portaria antiga'), findsOneWidget);
    expect(find.text('Portão'), findsOneWidget);
    expect(find.text('Novo'), findsNothing);

    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(find.text('Portaria antiga'), findsNothing);
    expect(find.text('Novo'), findsOneWidget);
  });

  testWidgets('sem pontos: estado vazio cadastra o primeiro', (tester) async {
    await pumpLaunch(tester);
    expect(find.text('Nenhum ponto de medição'), findsOneWidget);
    expect(find.text('Salvar'), findsNothing);
    await tester.tap(find.text('Cadastrar ponto'));
    await tester.pumpAndSettle();
    await tester.enterText(fieldLabeled('Nome'), 'Portão');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Ponto cadastrado'), findsOneWidget);
    expect(find.text('Portão'), findsOneWidget);
    expect(find.text('0 de 1'), findsOneWidget);
  });

  testWidgets('ação da faixa abre os pontos', (tester) async {
    measurements.seedPoint(companyId, 'Portão');
    await pumpLaunch(tester);
    await tester.tap(find.byTooltip('Pontos de medição'));
    await tester.pumpAndSettle();
    expect(find.text('Ativos'), findsOneWidget);
  });
}

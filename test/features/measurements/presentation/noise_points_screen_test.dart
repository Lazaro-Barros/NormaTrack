import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/measurements/domain/measurement_context.dart';
import 'package:normatrack/features/measurements/domain/measurement_frequency.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/fake_measurement_repository.dart';
import '../../../helpers/finders.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCompanyRepository companies;
  late FakeMeasurementRepository measurements;
  late String companyId;

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

  Future<void> pumpPoints(WidgetTester tester) => pumpApp(
    tester,
    repository: companies,
    measurementRepository: measurements,
    initialLocation: AppRoutes.noisePoints(companyId),
  );

  Future<List<String>> names({bool archived = false}) async => [
    for (final p
        in await measurements
            .watchParameters(
              companyId,
              MeasurementContext.noise,
              includeArchived: true,
            )
            .first)
      if (p.isArchived == archived) p.name,
  ];

  Future<void> fill(WidgetTester tester, String label, String text) async {
    await tester.enterText(fieldLabeled(label), text);
    await tester.pump();
  }

  testWidgets('sem pontos: estado vazio cadastra o primeiro com limite', (
    tester,
  ) async {
    await pumpPoints(tester);
    expect(find.text('Pontos de medição'), findsOneWidget);
    expect(find.text('Nenhum ponto de medição'), findsOneWidget);

    await tester.tap(find.text('Cadastrar ponto'));
    await tester.pumpAndSettle();
    expect(find.text('Novo ponto'), findsOneWidget);
    expect(find.text('Desativar'), findsNothing);

    await fill(tester, 'Nome', 'Portão principal');
    await fill(tester, 'Limite máximo', '70.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Ponto cadastrado'), findsOneWidget);
    expect(find.text('Portão principal'), findsOneWidget);
    expect(find.text('Limite 70,5 dB(A)'), findsOneWidget);
    final point =
        (await measurements
                .watchParameters(companyId, MeasurementContext.noise)
                .first)
            .single;
    expect(point.unit, 'dB(A)');
    expect(point.frequency, MeasurementFrequency.weekly);
    expect(point.startDate, DateTime(2026, 9, 29));
  });

  testWidgets('nome vazio e repetido mostram erro sem fechar a sheet', (
    tester,
  ) async {
    measurements.seedPoint(companyId, 'Galpão B');
    await pumpPoints(tester);
    await tester.tap(find.text('Novo ponto'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome'), findsOneWidget);

    await fill(tester, 'Nome', 'galpao b');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Já existe um ponto com esse nome'), findsOneWidget);
    expect(await names(), ['Galpão B']);
  });

  testWidgets('editar nome e tirar o limite', (tester) async {
    measurements.seedPoint(companyId, 'Divisa', limitMax: 70);
    await pumpPoints(tester);
    expect(find.text('Limite 70,0 dB(A)'), findsOneWidget);

    await tester.tap(find.text('Divisa'));
    await tester.pumpAndSettle();
    expect(find.text('Editar ponto'), findsOneWidget);
    await fill(tester, 'Nome', 'Divisa norte');
    await fill(tester, 'Limite máximo', '');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Ponto atualizado'), findsOneWidget);
    expect(find.text('Divisa norte'), findsOneWidget);
    expect(find.text('Sem limite'), findsOneWidget);
  });

  testWidgets('desativar e reativar mudam de seção', (tester) async {
    measurements
      ..seedPoint(companyId, 'Portão')
      ..seedPoint(companyId, 'Portaria antiga');
    await pumpPoints(tester);

    await tester.tap(find.text('Portaria antiga'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desativar'));
    await tester.pumpAndSettle();
    expect(find.text('Ponto desativado'), findsOneWidget);
    expect(find.text('Desativados'), findsOneWidget);
    expect(await names(archived: true), ['Portaria antiga']);

    await tester.tap(find.text('Portaria antiga'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reativar'));
    await tester.pumpAndSettle();
    expect(find.text('Desativados'), findsNothing);
    expect(await names(), ['Portão', 'Portaria antiga']);
  });

  testWidgets('excluir pede confirmação', (tester) async {
    final p = measurements.seedPoint(companyId, 'Portão');
    measurements.seedMeasurement(p.id, DateTime(2026, 9, 21), value: 61.8);
    await pumpPoints(tester);

    await tester.tap(find.text('Portão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir ponto?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await names(), ['Portão']);

    await tester.tap(find.text('Portão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last); // botão do diálogo
    await tester.pumpAndSettle();
    expect(find.text('Ponto excluído'), findsOneWidget);
    expect(await names(), isEmpty);
    expect(measurements.measurements, isEmpty);
  });

  testWidgets('empresa sem o Ambiental: módulo desligado', (tester) async {
    final semAmbiental = (await companies.seed(
      const CompanyInput(legalName: 'Beta', enabledModules: {}),
    )).id;
    await pumpApp(
      tester,
      repository: companies,
      measurementRepository: measurements,
      initialLocation: AppRoutes.noisePoints(semAmbiental),
    );
    expect(find.text('Módulo desligado'), findsOneWidget);
  });

  testWidgets('ruídos fora do Ambiental: módulo não encontrado', (
    tester,
  ) async {
    await pumpApp(
      tester,
      repository: companies,
      measurementRepository: measurements,
      initialLocation:
          '${AppRoutes.module(companyId, ModuleType.qualityControl)}'
          '/ruidos/pontos',
    );
    expect(find.text('Módulo não encontrado'), findsOneWidget);
  });
}

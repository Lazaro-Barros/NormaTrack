import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/finders.dart';
import '../../../helpers/pump_app.dart';

/// Título na faixa (o FAB da lista também diz "Nova empresa").
Finder bandTitle(String title) => find.widgetWithText(BandTitle, title);

void main() {
  Future<void> type(WidgetTester tester, String label, String text) async {
    final field = fieldLabeled(label).first;
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Salvar empresa'));
    await tester.pumpAndSettle();
  }

  testWidgets('só a razão social: salva e abre o detalhe', (tester) async {
    final repo = await pumpApp(tester, initialLocation: AppRoutes.newCompany);
    expect(bandTitle('Nova empresa'), findsOneWidget);

    await type(tester, 'Razão social', 'Indústria Alfa Ltda');
    await save(tester);

    expect(repo.all, hasLength(1));
    expect(repo.all.single.legalName, 'Indústria Alfa Ltda');
    expect(bandTitle('Nova empresa'), findsNothing);
    expect(find.text('Empresa salva'), findsOneWidget);
  });

  testWidgets('razão social vazia mostra erro e não salva', (tester) async {
    final repo = await pumpApp(tester, initialLocation: AppRoutes.newCompany);

    await save(tester);

    expect(find.text('Informe a razão social'), findsOneWidget);
    expect(repo.all, isEmpty);
  });

  testWidgets('erros de documento, e-mail e CEP', (tester) async {
    final cases = {
      ('CNPJ', '11222333000182'): 'CNPJ inválido',
      ('CNPJ', '1122233300'): 'CNPJ incompleto',
      ('CPF', '12345678900'): 'CPF inválido',
      ('E-mail', 'a@b'): 'E-mail inválido',
      ('CEP', '6193'): 'CEP incompleto',
    };
    for (final MapEntry(key: (label, value), value: message) in cases.entries) {
      final repo = await pumpApp(tester, initialLocation: AppRoutes.newCompany);
      await type(tester, 'Razão social', 'Alfa');
      await type(tester, label, value);
      await save(tester);

      expect(find.text(message), findsOneWidget, reason: '$label $value');
      expect(repo.all, isEmpty);
    }
  });

  testWidgets('editar o campo tira o erro dele', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.newCompany);
    await save(tester);
    expect(find.text('Informe a razão social'), findsOneWidget);

    await type(tester, 'Razão social', 'A');
    expect(find.text('Informe a razão social'), findsNothing);
  });

  testWidgets('CNPJ ganha máscara ao digitar', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.newCompany);

    await type(tester, 'CNPJ', '11222333000181');

    expect(fieldText(tester, fieldLabeled('CNPJ')), '11.222.333/0001-81');
  });

  testWidgets('CNPJ de empresa arquivada é duplicado', (tester) async {
    final repo = FakeCompanyRepository(now: testNow);
    await repo.seed(
      const CompanyInput(legalName: 'Beta', cnpj: '11222333000181'),
      archived: true,
    );
    await pumpApp(
      tester,
      repository: repo,
      initialLocation: AppRoutes.newCompany,
    );

    await type(tester, 'Razão social', 'Alfa');
    await type(tester, 'CNPJ', '11222333000181');
    await save(tester);

    expect(
      find.text('Já existe uma empresa com este CNPJ (ativa ou arquivada)'),
      findsOneWidget,
    );
    expect(repo.all, hasLength(1));
  });

  testWidgets('ligar Ambiental salva o módulo', (tester) async {
    final repo = await pumpApp(tester, initialLocation: AppRoutes.newCompany);

    await type(tester, 'Razão social', 'Alfa');
    await tester.ensureVisible(find.text('Ambiental'));
    await tester.tap(find.text('Ambiental'));
    await tester.pump();
    await save(tester);

    expect(repo.all.single.enabledModules, {ModuleType.environmental});
  });

  testWidgets('órgão: sheet mostra nº e validade só com Possui', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRoutes.newCompany);

    await tester.ensureVisible(find.text('Polícia Federal'));
    await tester.tap(find.text('Polícia Federal'));
    await tester.pumpAndSettle();
    expect(find.text('Registro da empresa neste órgão'), findsOneWidget);

    await tester.tap(find.text('Possui'));
    await tester.pumpAndSettle();
    expect(fieldLabeled('Nº do registro'), findsOneWidget);
    expect(fieldLabeled('Validade'), findsOneWidget);

    await tester.tap(find.text('Precisa obter'));
    await tester.pumpAndSettle();
    expect(fieldLabeled('Nº do registro'), findsNothing);
    expect(fieldLabeled('Validade'), findsNothing);

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.text('Registro da empresa neste órgão'), findsNothing);
    expect(find.text('Precisa obter'), findsOneWidget);
    expect(find.text('Não se aplica'), findsNWidgets(8));
  });

  group('editar', () {
    Future<FakeCompanyRepository> seeded() async {
      final repo = FakeCompanyRepository(now: testNow);
      await repo.seed(
        const CompanyInput(
          legalName: 'Indústria Alfa Ltda',
          cnpj: '11222333000181',
          phone: '8533334444',
        ),
      );
      return repo;
    }

    testWidgets('campos formatados e salvar grava o valor novo', (
      tester,
    ) async {
      final repo = await pumpApp(
        tester,
        repository: await seeded(),
        initialLocation: AppRoutes.editCompany('c1'),
      );

      expect(bandTitle('Editar empresa'), findsOneWidget);
      expect(fieldText(tester, fieldLabeled('CNPJ')), '11.222.333/0001-81');
      expect(
        fieldText(tester, fieldLabeled('Telefone').first),
        '(85) 3333-4444',
      );

      await type(tester, 'Nome fantasia', 'Alfa');
      await save(tester);

      expect(bandTitle('Editar empresa'), findsNothing);
      final company = repo.all.single;
      expect(company.tradeName, 'Alfa');
      expect(company.cnpj, '11222333000181');
    });

    testWidgets('id inexistente', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.editCompany('nada'));

      expect(find.text('Empresa não encontrada'), findsOneWidget);
      expect(find.text('Salvar empresa'), findsNothing);
    });
  });

  group('descartar alterações', () {
    testWidgets('com alteração, Fechar pede confirmação', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.newCompany);
      await type(tester, 'Razão social', 'Alfa');

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Descartar alterações?'), findsOneWidget);

      await tester.tap(find.text('Cancelar').last);
      await tester.pumpAndSettle();
      expect(find.text('Descartar alterações?'), findsNothing);
      expect(bandTitle('Nova empresa'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(bandTitle('Nova empresa'), findsNothing);
      expect(find.text('Nenhuma empresa cadastrada'), findsOneWidget);
    });

    testWidgets('sem alteração, Fechar sai direto', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.newCompany);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Descartar alterações?'), findsNothing);
      expect(bandTitle('Nova empresa'), findsNothing);
    });
  });
}

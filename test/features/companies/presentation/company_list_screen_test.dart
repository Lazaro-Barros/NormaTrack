import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/features/companies/domain/brazilian_state.dart';
import 'package:normatrack/features/companies/domain/company.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/pump_app.dart';

void main() {
  Future<FakeCompanyRepository> seeded() async {
    final repo = FakeCompanyRepository(now: testNow);
    await repo.seed(
      const CompanyInput(
        legalName: 'Indústria Alfa Ltda',
        cnpj: '11222333000181',
        address: Address(city: 'Maracanaú', state: BrazilianState.ce),
      ),
    );
    await repo.seed(
      const CompanyInput(legalName: 'Beta Alimentos S.A.'),
      archived: true,
    );
    return repo;
  }

  testWidgets('vazio mostra o convite para cadastrar', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.companies);

    expect(find.text('Nenhuma empresa cadastrada'), findsOneWidget);
    expect(find.text('Cadastrar empresa'), findsOneWidget);
  });

  testWidgets('ativas e arquivadas', (tester) async {
    await pumpApp(
      tester,
      repository: await seeded(),
      initialLocation: AppRoutes.companies,
    );

    expect(find.text('Indústria Alfa Ltda'), findsOneWidget);
    expect(find.text('Maracanaú/CE'), findsOneWidget);
    expect(find.text('Beta Alimentos S.A.'), findsNothing);

    await tester.tap(find.text('Arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Beta Alimentos S.A.'), findsOneWidget);
    expect(find.text('Indústria Alfa Ltda'), findsNothing);
  });

  testWidgets('arquivadas vazia', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.companies);

    await tester.tap(find.text('Arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma empresa arquivada'), findsOneWidget);
  });

  testWidgets('busca por nome sem acento e por CNPJ', (tester) async {
    await pumpApp(
      tester,
      repository: await seeded(),
      initialLocation: AppRoutes.companies,
    );
    final search = find.byType(SearchBar);

    for (final query in ['alfa', 'industria', '11.222.333']) {
      await tester.enterText(search, query);
      await tester.pumpAndSettle();
      expect(find.text('Indústria Alfa Ltda'), findsOneWidget, reason: query);
    }

    await tester.enterText(search, 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma empresa encontrada'), findsOneWidget);
    expect(find.text('Indústria Alfa Ltda'), findsNothing);
  });
}

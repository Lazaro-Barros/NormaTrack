import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/router.dart';
import 'package:normatrack/app/widgets/band_title.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/brazilian_state.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';

import '../../../helpers/fake_company_repository.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final alfa = CompanyInput(
    legalName: 'Indústria Alfa Ltda',
    cnpj: '11222333000181',
    address: const Address(
      street: 'Av. Industrial',
      number: '1200',
      district: 'Distrito Industrial',
      city: 'Maracanaú',
      state: BrazilianState.ce,
      postalCode: '61939000',
    ),
    phone: '8533334444',
    legalRepresentative: const LegalRepresentative(
      name: 'Maria Souza',
      cpf: '12345678909',
    ),
    enabledModules: const {ModuleType.environmental},
    registrations: {
      Authority.semace: AuthorityRegistration(
        authority: Authority.semace,
        status: RegistrationStatus.registered,
        registrationNumber: '2024/0187',
        validUntil: DateTime(2027, 3, 10),
      ),
      Authority.federalPolice: AuthorityRegistration(
        authority: Authority.federalPolice,
        status: RegistrationStatus.registered,
        validUntil: DateTime(2026, 8, 2),
      ),
      Authority.cityHall: const AuthorityRegistration(
        authority: Authority.cityHall,
        status: RegistrationStatus.required,
      ),
    },
  );

  Future<FakeCompanyRepository> pumpDetail(
    WidgetTester tester, {
    bool archived = false,
    String from = AppRoutes.companies,
  }) async {
    final repo = FakeCompanyRepository(now: testNow);
    await repo.seed(alfa, archived: archived);
    await pumpApp(tester, repository: repo, initialLocation: from);
    if (from == AppRoutes.companies) {
      if (archived) {
        await tester.tap(find.text('Arquivadas'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Indústria Alfa Ltda'));
      await tester.pumpAndSettle();
    }
    return repo;
  }

  testWidgets('módulos habilitados, órgãos que se aplicam e dados', (
    tester,
  ) async {
    await pumpDetail(tester);

    expect(find.widgetWithText(BandTitle, 'Indústria Alfa Ltda'), findsOne);
    expect(find.text('CNPJ 11.222.333/0001-81'), findsOneWidget);

    expect(find.text('Ambiental'), findsOneWidget);
    expect(find.text('Produtos controlados'), findsNothing);

    expect(find.text('3 de 9 se aplicam'), findsOneWidget);
    expect(find.text('Até 10/03/2027'), findsOneWidget);
    expect(find.text('Nº 2024/0187'), findsOneWidget);
    expect(find.text('Venceu 02/08/2026'), findsOneWidget);
    expect(find.text('Precisa obter'), findsOneWidget);
    expect(find.text('ANVISA'), findsNothing);
    expect(find.text('Ver todos os 9 órgãos'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('CPF 123.456.789-09'), 200);
    expect(find.text('Av. Industrial, 1200'), findsOneWidget);
    expect(find.text('Distrito Industrial · Maracanaú/CE'), findsOneWidget);
    expect(find.text('CEP 61939-000'), findsOneWidget);
    expect(find.text('(85) 3333-4444'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);
    // O CNPJ fica só na faixa; a razão social não se repete sem nome fantasia.
    expect(find.text('Razão social'), findsNothing);
  });

  testWidgets('tocar na empresa esconde a barra inferior', (tester) async {
    await pumpDetail(tester);

    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('arquivar pede confirmação e move para Arquivadas', (
    tester,
  ) async {
    final repo = await pumpDetail(tester);
    final archive = find.text('Arquivar');

    await tester.scrollUntilVisible(archive, 200);
    await tester.tap(archive);
    await tester.pumpAndSettle();
    expect(find.text('Arquivar empresa?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.all.single.isArchived, isFalse);
    expect(find.widgetWithText(BandTitle, 'Indústria Alfa Ltda'), findsOne);

    await tester.tap(archive);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arquivar').last);
    await tester.pumpAndSettle();

    expect(repo.all.single.isArchived, isTrue);
    expect(find.text('Empresa arquivada'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    // O SnackBar aparece na lista, acima do FAB, sem cobri-lo nem a barra.
    final snackBar = tester.getRect(find.byType(SnackBar));
    final fab = tester.getRect(find.byType(FloatingActionButton));
    expect(snackBar.overlaps(fab), isFalse, reason: '$snackBar × $fab');
    expect(
      snackBar.bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(NavigationBar)).top),
    );
    expect(find.text('Indústria Alfa Ltda'), findsNothing);

    await tester.tap(find.text('Arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Indústria Alfa Ltda'), findsOneWidget);
  });

  testWidgets('arquivar depois de visitar o Painel não duplica o SnackBar', (
    tester,
  ) async {
    // Ramos visitados continuam montados fora da tela; o SnackBar não pode
    // virar Hero repetido na volta do detalhe.
    final repo = FakeCompanyRepository(now: testNow);
    await repo.seed(alfa);
    await pumpApp(tester, repository: repo);
    await tester.tap(find.text('Ver empresas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Indústria Alfa Ltda'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Arquivar'), 200);
    await tester.tap(find.text('Arquivar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arquivar').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Empresa arquivada'), findsOneWidget);
  });

  testWidgets('Desfazer no SnackBar desarquiva', (tester) async {
    final repo = await pumpDetail(tester);

    await tester.scrollUntilVisible(find.text('Arquivar'), 200);
    await tester.tap(find.text('Arquivar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arquivar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(repo.all.single.isArchived, isFalse);
    expect(find.text('Indústria Alfa Ltda'), findsOneWidget);
  });

  testWidgets('empresa arquivada: faixa e Desarquivar', (tester) async {
    final repo = await pumpDetail(tester, archived: true);

    expect(find.text('CNPJ 11.222.333/0001-81 · Arquivada'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Desarquivar'), 200);
    await tester.tap(find.text('Desarquivar'));
    await tester.pumpAndSettle();

    expect(repo.all.single.isArchived, isFalse);
    expect(find.text('Empresa desarquivada'), findsOneWidget);
    expect(find.text('CNPJ 11.222.333/0001-81'), findsOneWidget);
    expect(find.text('Arquivar'), findsOneWidget);
  });

  testWidgets('id inexistente', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.company('nada'));

    expect(find.text('Empresa não encontrada'), findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma empresa cadastrada'), findsOneWidget);
  });

  testWidgets('só a razão social: módulos e órgãos convidam a editar', (
    tester,
  ) async {
    final repo = FakeCompanyRepository(now: testNow);
    await repo.seed(const CompanyInput(legalName: 'Gama'));
    await pumpApp(
      tester,
      repository: repo,
      initialLocation: AppRoutes.company('c1'),
    );

    expect(find.text('Habilitar módulos'), findsOneWidget);
    expect(find.text('0 de 9 se aplicam'), findsOneWidget);
    expect(find.text('Informar órgãos'), findsOneWidget);
    expect(find.text('Só a razão social foi informada.'), findsOneWidget);
  });

  testWidgets('lápis abre Editar empresa', (tester) async {
    await pumpDetail(tester);

    await tester.tap(find.byTooltip('Editar empresa'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BandTitle, 'Editar empresa'), findsOne);
  });
}

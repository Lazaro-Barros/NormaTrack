import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/presentation/registration_sheet.dart';

import '../../../helpers/finders.dart';

void main() {
  final today = DateTime(2026, 9, 29);

  /// Abre o sheet e devolve uma função que lê o resultado depois de fechar.
  Future<RegistrationSheetResult? Function()> open(
    WidgetTester tester, {
    AuthorityRegistration? current,
  }) async {
    RegistrationSheetResult? result;
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showRegistrationSheet(
                  context,
                  authority: Authority.federalPolice,
                  current: current,
                  today: today,
                );
                closed = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Polícia Federal'), findsOneWidget);
    return () {
      expect(closed, isTrue, reason: 'o sheet deveria ter fechado');
      return result;
    };
  }

  testWidgets('validade vencida aparece como aviso', (tester) async {
    await open(
      tester,
      current: AuthorityRegistration(
        authority: Authority.federalPolice,
        status: RegistrationStatus.registered,
        validUntil: DateTime(2026, 8, 2),
      ),
    );

    expect(find.text('Validade vencida em 02/08/2026'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(fieldText(tester, fieldLabeled('Validade')), '02/08/2026');
  });

  testWidgets('Possui com nº: Aplicar devolve o registro', (tester) async {
    final result = await open(tester);

    expect(fieldLabeled('Nº do registro'), findsNothing);
    await tester.tap(find.text('Possui'));
    await tester.pumpAndSettle();
    await tester.enterText(fieldLabeled('Nº do registro'), 'CRC 2024/0187');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    final registration = result()!.registration!;
    expect(registration.status, RegistrationStatus.registered);
    expect(registration.registrationNumber, 'CRC 2024/0187');
  });

  testWidgets('Precisa obter descarta nº e validade e mantém observação', (
    tester,
  ) async {
    final result = await open(
      tester,
      current: AuthorityRegistration(
        authority: Authority.federalPolice,
        status: RegistrationStatus.registered,
        registrationNumber: 'CRC 2024/0187',
        validUntil: DateTime(2027, 3, 10),
        notes: 'Renovação em andamento',
      ),
    );

    await tester.tap(find.text('Precisa obter'));
    await tester.pumpAndSettle();
    expect(fieldLabeled('Nº do registro'), findsNothing);
    expect(fieldLabeled('Validade'), findsNothing);
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    final registration = result()!.registration!;
    expect(registration.status, RegistrationStatus.required);
    expect(registration.registrationNumber, isNull);
    expect(registration.validUntil, isNull);
    expect(registration.notes, 'Renovação em andamento');
  });

  testWidgets('Não se aplica devolve resultado sem registro', (tester) async {
    final result = await open(
      tester,
      current: const AuthorityRegistration(
        authority: Authority.federalPolice,
        status: RegistrationStatus.required,
      ),
    );

    await tester.tap(find.text('Não se aplica'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    final value = result();
    expect(value, isNotNull);
    expect(value!.registration, isNull);
  });

  testWidgets('Fechar (X) devolve null', (tester) async {
    final result = await open(tester);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(result(), isNull);
  });

  testWidgets('remover validade limpa o campo', (tester) async {
    await open(
      tester,
      current: AuthorityRegistration(
        authority: Authority.federalPolice,
        status: RegistrationStatus.registered,
        validUntil: DateTime(2027, 3, 10),
      ),
    );

    expect(fieldText(tester, fieldLabeled('Validade')), '10/03/2027');
    await tester.tap(find.byTooltip('Remover validade'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, fieldLabeled('Validade')), '');
  });
}

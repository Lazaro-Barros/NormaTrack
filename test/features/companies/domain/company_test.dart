import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';

void main() {
  final created = DateTime.utc(2026, 1, 1);
  final anvisa = AuthorityRegistration(
    authority: Authority.anvisa,
    status: RegistrationStatus.registered,
    registrationNumber: '123',
    validUntil: DateTime(2026, 3, 10),
  );

  Company company({String? tradeName}) => Company(
    id: 'id-1',
    legalName: 'Indústria Alfa Ltda',
    tradeName: tradeName,
    enabledModules: {ModuleType.environmental},
    registrations: {Authority.anvisa: anvisa},
    createdAt: created,
    updatedAt: created,
  );

  test('displayName usa o nome fantasia quando houver', () {
    expect(company().displayName, 'Indústria Alfa Ltda');
    expect(company(tradeName: 'Alfa').displayName, 'Alfa');
  });

  test('hasModule e registrationFor', () {
    final c = company();
    expect(c.hasModule(ModuleType.environmental), isTrue);
    expect(c.hasModule(ModuleType.qualityControl), isFalse);
    expect(c.registrationFor(Authority.anvisa), anvisa);
    expect(c.registrationFor(Authority.ibama), isNull);
  });

  test('coleções não modificáveis', () {
    final c = company();
    expect(
      () => c.enabledModules.add(ModuleType.qualityControl),
      throwsUnsupportedError,
    );
    expect(() => c.registrations.clear(), throwsUnsupportedError);
  });

  group('isExpiredOn', () {
    test('véspera e no dia: válido', () {
      expect(anvisa.isExpiredOn(DateTime(2026, 3, 9)), isFalse);
      expect(anvisa.isExpiredOn(DateTime(2026, 3, 10, 23, 59)), isFalse);
    });
    test('dia seguinte: vencido', () {
      expect(anvisa.isExpiredOn(DateTime(2026, 3, 11)), isTrue);
    });
    test('sem validade: nunca vence', () {
      const r = AuthorityRegistration(
        authority: Authority.ibama,
        status: RegistrationStatus.required,
      );
      expect(r.isExpiredOn(DateTime(2100)), isFalse);
    });
  });

  group('situationOn', () {
    final today = DateTime(2026, 9, 29);
    AuthorityRegistration reg(RegistrationStatus status, [DateTime? until]) =>
        AuthorityRegistration(
          authority: Authority.federalPolice,
          status: status,
          validUntil: until,
        );

    test('precisa obter, mesmo com validade vencida', () {
      expect(
        reg(
          RegistrationStatus.required,
          DateTime(2026, 1, 1),
        ).situationOn(today),
        RegistrationSituation.required,
      );
    });
    test('possui, vencido ontem: expired', () {
      expect(
        reg(
          RegistrationStatus.registered,
          DateTime(2026, 9, 28),
        ).situationOn(today),
        RegistrationSituation.expired,
      );
    });
    test('possui, vence hoje: registered', () {
      expect(
        reg(RegistrationStatus.registered, today).situationOn(today),
        RegistrationSituation.registered,
      );
    });
    test('possui, sem validade: registered', () {
      expect(
        reg(RegistrationStatus.registered).situationOn(today),
        RegistrationSituation.registered,
      );
    });
  });

  test('igualdade por valor', () {
    expect(company(), company());
    expect(company().hashCode, company().hashCode);
    expect(company(), isNot(company(tradeName: 'Alfa')));
    expect(company().toInput(), company().toInput());
    expect(
      const Address(city: 'Fortaleza'),
      isNot(const Address(city: 'Sobral')),
    );
    expect(Address.empty.isEmpty, isTrue);
  });

  test('toInput preserva os dados editáveis', () {
    final input = company(tradeName: 'Alfa').toInput();
    expect(input.legalName, 'Indústria Alfa Ltda');
    expect(input.tradeName, 'Alfa');
    expect(input.enabledModules, {ModuleType.environmental});
    expect(input.registrations, {Authority.anvisa: anvisa});
  });
}

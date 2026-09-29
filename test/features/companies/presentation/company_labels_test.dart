import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/brazilian_state.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_validation.dart';
import 'package:normatrack/features/companies/presentation/company_labels.dart';

void main() {
  final today = DateTime(2026, 9, 29);

  group('registrationDisplay', () {
    AuthorityRegistration reg(RegistrationStatus status, [DateTime? until]) =>
        AuthorityRegistration(
          authority: Authority.semace,
          status: status,
          validUntil: until,
        );

    test('não se aplica', () {
      expect(registrationDisplay(null, today), (
        label: 'Não se aplica',
        tone: null,
      ));
    });
    test('precisa obter', () {
      expect(registrationDisplay(reg(RegistrationStatus.required), today), (
        label: 'Precisa obter',
        tone: StatusTone.dueSoon,
      ));
    });
    test('vencido', () {
      expect(
        registrationDisplay(
          reg(RegistrationStatus.registered, DateTime(2026, 8, 2)),
          today,
        ),
        (label: 'Venceu 02/08/2026', tone: StatusTone.overdue),
      );
    });
    test('possui com validade', () {
      expect(
        registrationDisplay(
          reg(RegistrationStatus.registered, DateTime(2027, 3, 10)),
          today,
        ),
        (label: 'Até 10/03/2027', tone: StatusTone.ok),
      );
    });
    test('possui sem validade', () {
      expect(registrationDisplay(reg(RegistrationStatus.registered), today), (
        label: 'Possui registro',
        tone: StatusTone.ok,
      ));
    });
  });

  test('cityState', () {
    expect(
      cityState(const Address(city: 'Maracanaú', state: BrazilianState.ce)),
      'Maracanaú/CE',
    );
    expect(cityState(const Address(city: 'Maracanaú')), 'Maracanaú');
    expect(cityState(const Address(state: BrazilianState.ce)), 'CE');
    expect(cityState(Address.empty), isNull);
  });

  group('companyFieldMessage', () {
    const cnpjError = CompanyFieldError(
      CompanyField.cnpj,
      CompanyFieldErrorType.invalid,
    );
    const cpfError = CompanyFieldError(
      CompanyField.legalRepCpf,
      CompanyFieldErrorType.invalid,
    );

    test('CNPJ incompleto × inválido', () {
      expect(
        companyFieldMessage(
          cnpjError,
          const CompanyInput(legalName: 'A', cnpj: '1122233300'),
        ),
        'CNPJ incompleto',
      );
      expect(
        companyFieldMessage(
          cnpjError,
          const CompanyInput(legalName: 'A', cnpj: '11222333000182'),
        ),
        'CNPJ inválido',
      );
    });

    test('CPF incompleto × inválido', () {
      expect(
        companyFieldMessage(
          cpfError,
          const CompanyInput(
            legalName: 'A',
            legalRepresentative: LegalRepresentative(cpf: '123'),
          ),
        ),
        'CPF incompleto',
      );
      expect(
        companyFieldMessage(
          cpfError,
          const CompanyInput(
            legalName: 'A',
            legalRepresentative: LegalRepresentative(cpf: '12345678900'),
          ),
        ),
        'CPF inválido',
      );
    });

    test('razão social', () {
      expect(
        companyFieldMessage(
          const CompanyFieldError(
            CompanyField.legalName,
            CompanyFieldErrorType.required,
          ),
          const CompanyInput(legalName: ''),
        ),
        'Informe a razão social',
      );
    });
  });
}

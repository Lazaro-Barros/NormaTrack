import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/company_validation.dart';

void main() {
  List<CompanyFieldError> check(CompanyInput input) =>
      validateCompany(normalizeCompanyInput(input));

  CompanyFieldError invalid(CompanyField f) =>
      CompanyFieldError(f, CompanyFieldErrorType.invalid);

  group('normalização', () {
    test('trim e vazio → null', () {
      final n = normalizeCompanyInput(
        const CompanyInput(
          legalName: '  Alfa  ',
          tradeName: '   ',
          address: Address(street: ' Rua A ', city: ''),
        ),
      );
      expect(n.legalName, 'Alfa');
      expect(n.tradeName, isNull);
      expect(n.address.street, 'Rua A');
      expect(n.address.city, isNull);
    });

    test('remove máscaras e ajusta caixa', () {
      final n = normalizeCompanyInput(
        const CompanyInput(
          legalName: 'Alfa',
          cnpj: '12.abc.345/01de-35',
          stateRegistration: ' isento ',
          phone: '(85) 3222-1234',
          email: ' Contato@Alfa.COM ',
          address: Address(postalCode: '60115-170'),
          legalRepresentative: LegalRepresentative(
            cpf: '123.456.789-09',
            phone: '(85) 99876-5432',
            email: 'Joao@Alfa.com',
          ),
        ),
      );
      expect(n.cnpj, '12ABC34501DE35');
      expect(n.stateRegistration, 'ISENTO');
      expect(n.phone, '8532221234');
      expect(n.email, 'contato@alfa.com');
      expect(n.address.postalCode, '60115170');
      expect(n.legalRepresentative.cpf, '12345678909');
      expect(n.legalRepresentative.phone, '85998765432');
      expect(n.legalRepresentative.email, 'joao@alfa.com');
    });

    test('registro: trim e validade truncada para a data', () {
      final n = normalizeCompanyInput(
        CompanyInput(
          legalName: 'Alfa',
          registrations: {
            Authority.ibama: AuthorityRegistration(
              authority: Authority.ibama,
              status: RegistrationStatus.registered,
              registrationNumber: ' 42 ',
              validUntil: DateTime(2026, 5, 1, 14, 30),
              notes: '  ',
            ),
          },
        ),
      );
      final r = n.registrations[Authority.ibama]!;
      expect(r.registrationNumber, '42');
      expect(r.validUntil, DateTime(2026, 5, 1));
      expect(r.notes, isNull);
    });
  });

  group('validação', () {
    test('só a razão social é válido', () {
      expect(check(const CompanyInput(legalName: 'Alfa')), isEmpty);
    });

    test('razão social obrigatória', () {
      expect(check(const CompanyInput(legalName: '   ')), [
        const CompanyFieldError(
          CompanyField.legalName,
          CompanyFieldErrorType.required,
        ),
      ]);
    });

    test('todos os campos válidos', () {
      expect(
        check(
          const CompanyInput(
            legalName: 'Alfa',
            cnpj: '11.222.333/0001-81',
            phone: '(85) 99876-5432',
            email: 'a@b.co',
            address: Address(postalCode: '60115-170'),
            legalRepresentative: LegalRepresentative(
              cpf: '123.456.789-09',
              phone: '8532221234',
              email: 'rep@alfa.com.br',
            ),
          ),
        ),
        isEmpty,
      );
    });

    test('CNPJ alfanumérico é válido', () {
      expect(
        check(const CompanyInput(legalName: 'A', cnpj: '12.ABC.345/01DE-35')),
        isEmpty,
      );
    });

    test('cada campo inválido gera seu erro', () {
      expect(
        check(
          const CompanyInput(
            legalName: 'Alfa',
            cnpj: '11.222.333/0001-82',
            phone: '853222123',
            email: 'sem-arroba.com',
            address: Address(postalCode: '6011517'),
            legalRepresentative: LegalRepresentative(
              cpf: '111.111.111-11',
              phone: '123',
              email: 'a@b',
            ),
          ),
        ),
        [
          invalid(CompanyField.cnpj),
          invalid(CompanyField.phone),
          invalid(CompanyField.email),
          invalid(CompanyField.postalCode),
          invalid(CompanyField.legalRepCpf),
          invalid(CompanyField.legalRepPhone),
          invalid(CompanyField.legalRepEmail),
        ],
      );
    });

    test('CNPJ só com máscara conta como vazio', () {
      final n = normalizeCompanyInput(
        const CompanyInput(legalName: 'A', cnpj: '../-'),
      );
      expect(n.cnpj, isNull);
    });
  });
}

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/authority.dart';
import '../domain/brazilian_state.dart';
import '../domain/company.dart';
import '../domain/module_type.dart';

// Enums vão para o banco pelo `code`, nunca pelo `name` (D007). Código
// desconhecido vindo do banco lança `ArgumentError`: é corrupção, não entrada
// do usuário.

/// Monta o agregado. `modules` e `authorities` devem conter só linhas vivas.
Company companyFromRows(
  CompanyRow row,
  Iterable<CompanyModuleRow> modules,
  Iterable<CompanyAuthorityRow> authorities,
) {
  final input = companyInputFromRow(row);
  return Company(
    id: row.id,
    legalName: input.legalName,
    tradeName: input.tradeName,
    cnpj: input.cnpj,
    stateRegistration: input.stateRegistration,
    address: input.address,
    phone: input.phone,
    email: input.email,
    legalRepresentative: input.legalRepresentative,
    enabledModules: {
      for (final m in modules)
        if (m.enabled) ModuleType.fromCode(m.moduleType),
    },
    registrations: {
      for (final a in authorities)
        Authority.fromCode(a.authority): registrationFromRow(a),
    },
    archivedAt: row.archivedAt,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

/// Só os dados cadastrais da linha, sem módulos e registros.
CompanyInput companyInputFromRow(CompanyRow row) => CompanyInput(
  legalName: row.legalName,
  tradeName: row.tradeName,
  cnpj: row.cnpj,
  stateRegistration: row.stateRegistration,
  address: Address(
    street: row.addressStreet,
    number: row.addressNumber,
    complement: row.addressComplement,
    district: row.addressDistrict,
    city: row.addressCity,
    state: switch (row.addressState) {
      final code? => BrazilianState.fromCode(code),
      null => null,
    },
    postalCode: row.addressPostalCode,
  ),
  phone: row.phone,
  email: row.email,
  legalRepresentative: LegalRepresentative(
    name: row.legalRepName,
    cpf: row.legalRepCpf,
    phone: row.legalRepPhone,
    email: row.legalRepEmail,
  ),
);

AuthorityRegistration registrationFromRow(CompanyAuthorityRow row) =>
    AuthorityRegistration(
      authority: Authority.fromCode(row.authority),
      status: RegistrationStatus.fromCode(row.status),
      registrationNumber: row.registrationNumber,
      validUntil: row.validUntil,
      notes: row.notes,
    );

/// Colunas de dados cadastrais (sem id, timestamps e arquivamento).
CompaniesCompanion companyDataCompanion(CompanyInput input) {
  final address = input.address;
  final rep = input.legalRepresentative;
  return CompaniesCompanion(
    legalName: Value(input.legalName),
    tradeName: Value(input.tradeName),
    cnpj: Value(input.cnpj),
    stateRegistration: Value(input.stateRegistration),
    addressStreet: Value(address.street),
    addressNumber: Value(address.number),
    addressComplement: Value(address.complement),
    addressDistrict: Value(address.district),
    addressCity: Value(address.city),
    addressState: Value(address.state?.code),
    addressPostalCode: Value(address.postalCode),
    phone: Value(input.phone),
    email: Value(input.email),
    legalRepName: Value(rep.name),
    legalRepCpf: Value(rep.cpf),
    legalRepPhone: Value(rep.phone),
    legalRepEmail: Value(rep.email),
  );
}

/// Colunas de dados do registro (sem id, empresa, órgão e timestamps).
CompanyAuthoritiesCompanion registrationDataCompanion(
  AuthorityRegistration registration,
) => CompanyAuthoritiesCompanion(
  status: Value(registration.status.code),
  registrationNumber: Value(registration.registrationNumber),
  validUntil: Value(registration.validUntil),
  notes: Value(registration.notes),
);

import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';

@TableIndex.sql(
  'CREATE UNIQUE INDEX companies_cnpj_active ON companies (cnpj) '
  'WHERE cnpj IS NOT NULL AND deleted_at IS NULL',
)
class Companies extends Table with EntityColumns {
  TextColumn get legalName => text()();
  TextColumn get tradeName => text().nullable()();
  TextColumn get cnpj => text().nullable()();
  TextColumn get stateRegistration => text().nullable()();
  TextColumn get addressStreet => text().nullable()();
  TextColumn get addressNumber => text().nullable()();
  TextColumn get addressComplement => text().nullable()();
  TextColumn get addressDistrict => text().nullable()();
  TextColumn get addressCity => text().nullable()();

  /// `BrazilianState.code`.
  TextColumn get addressState => text().nullable()();
  TextColumn get addressPostalCode => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get legalRepName => text().nullable()();
  TextColumn get legalRepCpf => text().nullable()();
  TextColumn get legalRepPhone => text().nullable()();
  TextColumn get legalRepEmail => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

class CompanyModules extends Table with EntityColumns {
  TextColumn get companyId => text().references(Companies, #id)();

  /// `ModuleType.code`.
  TextColumn get moduleType => text()();
  BoolColumn get enabled => boolean()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, moduleType},
  ];
}

class CompanyAuthorities extends Table with EntityColumns {
  TextColumn get companyId => text().references(Companies, #id)();

  /// `Authority.code`.
  TextColumn get authority => text()();

  /// `RegistrationStatus.code`.
  TextColumn get status => text()();
  TextColumn get registrationNumber => text().nullable()();
  TextColumn get validUntil =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, authority},
  ];
}

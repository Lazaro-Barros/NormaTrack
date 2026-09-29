import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'authority.dart';
import 'brazilian_state.dart';
import 'module_type.dart';

const _setEquality = SetEquality<ModuleType>();
const _mapEquality = MapEquality<Authority, AuthorityRegistration>();

@immutable
class Address {
  const Address({
    this.street,
    this.number,
    this.complement,
    this.district,
    this.city,
    this.state,
    this.postalCode,
  });

  final String? street;
  final String? number;
  final String? complement;
  final String? district;
  final String? city;
  final BrazilianState? state;

  /// 8 dígitos, sem máscara.
  final String? postalCode;

  static const empty = Address();

  bool get isEmpty => this == empty;

  @override
  bool operator ==(Object other) =>
      other is Address &&
      other.street == street &&
      other.number == number &&
      other.complement == complement &&
      other.district == district &&
      other.city == city &&
      other.state == state &&
      other.postalCode == postalCode;

  @override
  int get hashCode => Object.hash(
    street,
    number,
    complement,
    district,
    city,
    state,
    postalCode,
  );
}

@immutable
class LegalRepresentative {
  const LegalRepresentative({this.name, this.cpf, this.phone, this.email});

  final String? name;

  /// 11 dígitos, sem máscara.
  final String? cpf;

  /// Só dígitos.
  final String? phone;
  final String? email;

  static const empty = LegalRepresentative();

  bool get isEmpty => this == empty;

  @override
  bool operator ==(Object other) =>
      other is LegalRepresentative &&
      other.name == name &&
      other.cpf == cpf &&
      other.phone == phone &&
      other.email == email;

  @override
  int get hashCode => Object.hash(name, cpf, phone, email);
}

/// Dados editáveis da empresa. Usado para criar e para editar.
@immutable
class CompanyInput {
  const CompanyInput({
    required this.legalName,
    this.tradeName,
    this.cnpj,
    this.stateRegistration,
    this.address = Address.empty,
    this.phone,
    this.email,
    this.legalRepresentative = LegalRepresentative.empty,
    // TODO(RF-EMP-02): nenhum módulo habilitado por padrão é suposição (C18).
    this.enabledModules = const {},
    this.registrations = const {},
  });

  final String legalName;
  final String? tradeName;

  /// 14 caracteres, sem máscara, em maiúsculas.
  final String? cnpj;
  final String? stateRegistration;
  final Address address;

  // TODO(RF-EMP-04): um telefone e um e-mail por empresa é suposição (C18).
  final String? phone;
  final String? email;
  final LegalRepresentative legalRepresentative;
  final Set<ModuleType> enabledModules;

  /// Órgão ausente = não se aplica.
  final Map<Authority, AuthorityRegistration> registrations;

  @override
  bool operator ==(Object other) =>
      other is CompanyInput &&
      other.legalName == legalName &&
      other.tradeName == tradeName &&
      other.cnpj == cnpj &&
      other.stateRegistration == stateRegistration &&
      other.address == address &&
      other.phone == phone &&
      other.email == email &&
      other.legalRepresentative == legalRepresentative &&
      _setEquality.equals(other.enabledModules, enabledModules) &&
      _mapEquality.equals(other.registrations, registrations);

  @override
  int get hashCode => Object.hash(
    legalName,
    tradeName,
    cnpj,
    stateRegistration,
    address,
    phone,
    email,
    legalRepresentative,
    _setEquality.hash(enabledModules),
    _mapEquality.hash(registrations),
  );
}

@immutable
class Company {
  Company({
    required this.id,
    required this.legalName,
    this.tradeName,
    this.cnpj,
    this.stateRegistration,
    this.address = Address.empty,
    this.phone,
    this.email,
    this.legalRepresentative = LegalRepresentative.empty,
    Set<ModuleType> enabledModules = const {},
    Map<Authority, AuthorityRegistration> registrations = const {},
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : enabledModules = Set.unmodifiable(enabledModules),
       registrations = Map.unmodifiable(registrations);

  final String id;
  final String legalName;
  final String? tradeName;
  final String? cnpj;
  final String? stateRegistration;
  final Address address;
  final String? phone;
  final String? email;
  final LegalRepresentative legalRepresentative;
  final Set<ModuleType> enabledModules;
  final Map<Authority, AuthorityRegistration> registrations;
  final DateTime? archivedAt;

  /// UTC.
  final DateTime createdAt;

  /// UTC.
  final DateTime updatedAt;

  String get displayName => tradeName ?? legalName;
  bool get isArchived => archivedAt != null;
  bool hasModule(ModuleType module) => enabledModules.contains(module);
  AuthorityRegistration? registrationFor(Authority authority) =>
      registrations[authority];

  /// Para editar: `toInput()` → alterar → `update()`.
  CompanyInput toInput() => CompanyInput(
    legalName: legalName,
    tradeName: tradeName,
    cnpj: cnpj,
    stateRegistration: stateRegistration,
    address: address,
    phone: phone,
    email: email,
    legalRepresentative: legalRepresentative,
    enabledModules: enabledModules,
    registrations: registrations,
  );

  @override
  bool operator ==(Object other) =>
      other is Company &&
      other.id == id &&
      other.archivedAt == archivedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.toInput() == toInput();

  @override
  int get hashCode =>
      Object.hash(id, archivedAt, createdAt, updatedAt, toInput());

  @override
  String toString() => 'Company($id, $legalName)';
}

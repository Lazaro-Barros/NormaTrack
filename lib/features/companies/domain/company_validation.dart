import 'package:meta/meta.dart';

import '../../../core/utils/br_documents.dart';
import 'authority.dart';
import 'company.dart';

enum CompanyField {
  legalName,
  cnpj,
  phone,
  email,
  postalCode,
  legalRepCpf,
  legalRepPhone,
  legalRepEmail,
}

enum CompanyFieldErrorType { required, invalid }

@immutable
class CompanyFieldError {
  const CompanyFieldError(this.field, this.type);

  final CompanyField field;
  final CompanyFieldErrorType type;

  @override
  bool operator ==(Object other) =>
      other is CompanyFieldError && other.field == field && other.type == type;

  @override
  int get hashCode => Object.hash(field, type);

  @override
  String toString() => 'CompanyFieldError(${field.name}, ${type.name})';
}

/// Normaliza o input antes de validar e gravar: `trim`, vazio → `null` e
/// documentos sem máscara.
CompanyInput normalizeCompanyInput(CompanyInput input) {
  final address = input.address;
  final rep = input.legalRepresentative;
  return CompanyInput(
    legalName: input.legalName.trim(),
    tradeName: _text(input.tradeName),
    cnpj: _map(input.cnpj, normalizeCnpj),
    stateRegistration: _text(input.stateRegistration)?.toUpperCase(),
    address: Address(
      street: _text(address.street),
      number: _text(address.number),
      complement: _text(address.complement),
      district: _text(address.district),
      city: _text(address.city),
      state: address.state,
      postalCode: _map(address.postalCode, normalizePostalCode),
    ),
    phone: _map(input.phone, normalizePhone),
    email: _text(input.email)?.toLowerCase(),
    legalRepresentative: LegalRepresentative(
      name: _text(rep.name),
      cpf: _map(rep.cpf, normalizeCpf),
      phone: _map(rep.phone, normalizePhone),
      email: _text(rep.email)?.toLowerCase(),
    ),
    enabledModules: Set.unmodifiable(input.enabledModules),
    registrations: Map.unmodifiable({
      for (final MapEntry(:key, :value) in input.registrations.entries)
        key: AuthorityRegistration(
          authority: value.authority,
          status: value.status,
          registrationNumber: _text(value.registrationNumber),
          validUntil: switch (value.validUntil) {
            final d? => DateTime(d.year, d.month, d.day),
            null => null,
          },
          notes: _text(value.notes),
        ),
    }),
  );
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Valida um input já normalizado. Lista vazia = válido.
List<CompanyFieldError> validateCompany(CompanyInput input) {
  assert(
    input.registrations.entries.every((e) => e.key == e.value.authority),
    'registrations[k].authority deve ser k',
  );
  final rep = input.legalRepresentative;
  return [
    if (input.legalName.isEmpty)
      const CompanyFieldError(
        CompanyField.legalName,
        CompanyFieldErrorType.required,
      ),
    ..._invalidIf(CompanyField.cnpj, input.cnpj, isValidCnpj),
    ..._invalidIf(CompanyField.phone, input.phone, isValidPhone),
    ..._invalidIf(CompanyField.email, input.email, _emailPattern.hasMatch),
    ..._invalidIf(
      CompanyField.postalCode,
      input.address.postalCode,
      isValidPostalCode,
    ),
    ..._invalidIf(CompanyField.legalRepCpf, rep.cpf, isValidCpf),
    ..._invalidIf(CompanyField.legalRepPhone, rep.phone, isValidPhone),
    ..._invalidIf(
      CompanyField.legalRepEmail,
      rep.email,
      _emailPattern.hasMatch,
    ),
  ];
}

Iterable<CompanyFieldError> _invalidIf(
  CompanyField field,
  String? value,
  bool Function(String) isValid,
) => [
  if (value != null && !isValid(value))
    CompanyFieldError(field, CompanyFieldErrorType.invalid),
];

String? _text(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

String? _map(String? value, String Function(String) normalize) {
  final text = _text(value);
  if (text == null) return null;
  final normalized = normalize(text);
  return normalized.isEmpty ? null : normalized;
}

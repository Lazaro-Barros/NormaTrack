import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../domain/authority.dart';
import '../domain/company.dart';
import '../domain/company_validation.dart';
import '../domain/module_type.dart';

extension ModuleTypeUi on ModuleType {
  IconData get icon => switch (this) {
    ModuleType.environmental => Icons.eco_outlined,
    ModuleType.controlledProducts => Icons.shield_outlined,
    ModuleType.qualityControl => Icons.science_outlined,
  };

  String get description => switch (this) {
    ModuleType.environmental => 'Licenças, ruídos, resíduos, ETE/ETA',
    ModuleType.controlledProducts => 'Polícia Federal e Exército',
    ModuleType.qualityControl => 'Produtos, lotes, estoque',
  };
}

/// Rótulo e tom da situação de um registro em órgão, iguais no formulário e
/// no detalhe. `r == null` = não se aplica.
({String label, StatusTone? tone}) registrationDisplay(
  AuthorityRegistration? r,
  DateTime today,
) {
  if (r == null) return (label: 'Não se aplica', tone: null);
  final until = r.validUntil;
  return switch (r.situationOn(today)) {
    RegistrationSituation.required => (
      label: 'Precisa obter',
      tone: StatusTone.dueSoon,
    ),
    RegistrationSituation.expired => (
      label: 'Venceu ${formatDate(until!)}',
      tone: StatusTone.overdue,
    ),
    RegistrationSituation.registered => (
      label: until == null ? 'Possui registro' : 'Até ${formatDate(until)}',
      tone: StatusTone.ok,
    ),
  };
}

/// `Cidade/UF`, só a cidade, só a UF ou `null`.
String? cityState(Address a) {
  final city = a.city;
  final state = a.state?.code;
  if (city != null && state != null) return '$city/$state';
  return city ?? state;
}

/// Mensagem de erro de um campo, a partir do input já normalizado.
String companyFieldMessage(CompanyFieldError e, CompanyInput normalized) =>
    switch (e.field) {
      CompanyField.legalName => 'Informe a razão social',
      CompanyField.cnpj =>
        (normalized.cnpj?.length ?? 0) < 14
            ? 'CNPJ incompleto'
            : 'CNPJ inválido',
      CompanyField.legalRepCpf =>
        (normalized.legalRepresentative.cpf?.length ?? 0) < 11
            ? 'CPF incompleto'
            : 'CPF inválido',
      CompanyField.postalCode => 'CEP incompleto',
      CompanyField.phone || CompanyField.legalRepPhone => 'Telefone incompleto',
      CompanyField.email || CompanyField.legalRepEmail => 'E-mail inválido',
    };

const duplicateCnpjMessage =
    'Já existe uma empresa com este CNPJ (ativa ou arquivada)';

/// Normalização, validação e formatação de documentos brasileiros.
///
/// As funções `is…` e `format…` esperam o valor já normalizado. `format…`
/// devolve a entrada sem alteração quando ela está fora do formato esperado.
library;

final _nonDigits = RegExp(r'\D');
final _cnpjSeparators = RegExp(r'[.\/\-\s]');
final _cnpjPattern = RegExp(r'^[0-9A-Z]{12}[0-9]{2}$');
final _cpfPattern = RegExp(r'^\d{11}$');
final _postalCodePattern = RegExp(r'^\d{8}$');
final _phonePattern = RegExp(r'^\d{10,11}$');

String digitsOnly(String value) => value.replaceAll(_nonDigits, '');

// CNPJ ----------------------------------------------------------------------

/// Remove `.`, `/`, `-` e espaços e passa para maiúsculas.
String normalizeCnpj(String value) =>
    value.replaceAll(_cnpjSeparators, '').toUpperCase();

/// CNPJ numérico ou alfanumérico (IN RFB nº 2.229/2024).
bool isValidCnpj(String cnpj) {
  if (!_cnpjPattern.hasMatch(cnpj)) return false;
  if (_allSame(cnpj)) return false;
  final values = cnpj.codeUnits.map((c) => c - 48).toList();
  final dv1 = _checkDigit(values.sublist(0, 12), const [
    5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, //
  ]);
  final dv2 = _checkDigit(
    [...values.sublist(0, 12), dv1],
    const [
      6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, //
    ],
  );
  return values[12] == dv1 && values[13] == dv2;
}

/// `XX.XXX.XXX/XXXX-XX`.
String formatCnpj(String cnpj) {
  if (!_cnpjPattern.hasMatch(cnpj)) return cnpj;
  return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.'
      '${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
}

// CPF -----------------------------------------------------------------------

String normalizeCpf(String value) => digitsOnly(value);

bool isValidCpf(String cpf) {
  if (!_cpfPattern.hasMatch(cpf)) return false;
  if (_allSame(cpf)) return false;
  final values = cpf.codeUnits.map((c) => c - 48).toList();
  final dv1 = _checkDigit(values.sublist(0, 9), const [
    10, 9, 8, 7, 6, 5, 4, 3, 2, //
  ]);
  final dv2 = _checkDigit(
    [...values.sublist(0, 9), dv1],
    const [
      11, 10, 9, 8, 7, 6, 5, 4, 3, 2, //
    ],
  );
  return values[9] == dv1 && values[10] == dv2;
}

/// `XXX.XXX.XXX-XX`.
String formatCpf(String cpf) {
  if (!_cpfPattern.hasMatch(cpf)) return cpf;
  return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.'
      '${cpf.substring(6, 9)}-${cpf.substring(9)}';
}

// CEP -----------------------------------------------------------------------

String normalizePostalCode(String value) => digitsOnly(value);

bool isValidPostalCode(String postalCode) =>
    _postalCodePattern.hasMatch(postalCode);

/// `XXXXX-XXX`.
String formatPostalCode(String postalCode) {
  if (!isValidPostalCode(postalCode)) return postalCode;
  return '${postalCode.substring(0, 5)}-${postalCode.substring(5)}';
}

// Telefone ------------------------------------------------------------------

String normalizePhone(String value) => digitsOnly(value);

// TODO(RF-EMP-04): telefone com DDD + 8 ou 9 dígitos é suposição (C18).
bool isValidPhone(String phone) => _phonePattern.hasMatch(phone);

/// `(XX) XXXX-XXXX` (10 dígitos) ou `(XX) XXXXX-XXXX` (11).
String formatPhone(String phone) {
  if (!isValidPhone(phone)) return phone;
  final split = phone.length - 4;
  return '(${phone.substring(0, 2)}) ${phone.substring(2, split)}-'
      '${phone.substring(split)}';
}

// ---------------------------------------------------------------------------

bool _allSame(String value) => value.split('').every((c) => c == value[0]);

/// Módulo 11: `0` se o resto for menor que 2, senão `11 − resto`.
int _checkDigit(List<int> values, List<int> weights) {
  var sum = 0;
  for (var i = 0; i < values.length; i++) {
    sum += values[i] * weights[i];
  }
  final r = sum % 11;
  return r < 2 ? 0 : 11 - r;
}

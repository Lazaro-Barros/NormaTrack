import 'package:meta/meta.dart';

/// Órgãos em que a empresa possui ou precisa obter registro (RF-EMP-05).
///
/// Lista fixa (D007). A ordem é a de exibição. `code` é persistido e nunca muda.
enum Authority {
  cityHall('city_hall', 'Prefeitura', 'Prefeitura'),
  agricultureMinistry(
    'agriculture_ministry',
    'Ministério da Agricultura',
    'MAPA',
  ),
  anvisa('anvisa', 'ANVISA', 'ANVISA'),
  semace('semace', 'SEMACE', 'SEMACE'),
  ibama('ibama', 'IBAMA', 'IBAMA'),
  environmentSecretariat(
    'environment_secretariat',
    'Secretaria de Meio Ambiente',
    'Sec. Meio Ambiente',
  ),
  professionalCouncil(
    'professional_council',
    'Conselho de Classe',
    'Conselho de Classe',
  ),
  federalPolice('federal_police', 'Polícia Federal', 'PF'),
  army('army', 'Exército Brasileiro', 'Exército');

  const Authority(this.code, this.label, this.shortLabel);

  final String code;
  final String label;
  final String shortLabel;

  static Authority fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Authority'),
  );
}

enum RegistrationStatus {
  registered('registered', 'Possui registro'),
  required('required', 'Precisa obter');

  const RegistrationStatus(this.code, this.label);

  final String code;
  final String label;

  static RegistrationStatus fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'RegistrationStatus'),
  );
}

/// Situação de um registro numa data. A UI converte para `StatusTone`.
///
/// "Não se aplica" não é situação: é a ausência do registro. Não existe
/// "a vencer" para registro.
// TODO(RF-EMP-05): alerta antes da validade depende de C16.
enum RegistrationSituation { registered, expired, required }

/// Registro da empresa em um órgão. Ausência de registro = "não se aplica".
@immutable
class AuthorityRegistration {
  const AuthorityRegistration({
    required this.authority,
    required this.status,
    this.registrationNumber,
    this.validUntil,
    this.notes,
  });

  final Authority authority;
  final RegistrationStatus status;
  final String? registrationNumber;

  /// Só a data: `DateTime(y, m, d)`, sem hora, local.
  // TODO(RF-EMP-05): a validade deve gerar prazo com alerta? (C16)
  final DateTime? validUntil;

  // TODO(RF-EMP-05): qual conselho/secretaria; um registro por órgão (C17).
  final String? notes;

  /// Vale até o fim do dia `validUntil`, inclusive. Sem validade → false.
  // TODO(RF-EMP-05): validade inclusiva é suposição (C18).
  bool isExpiredOn(DateTime today) {
    final until = validUntil;
    if (until == null) return false;
    final untilDate = DateTime(until.year, until.month, until.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return untilDate.isBefore(todayDate);
  }

  /// `required` se a situação é "precisa obter"; senão `expired` se
  /// [isExpiredOn]; senão `registered`.
  RegistrationSituation situationOn(DateTime today) {
    if (status == RegistrationStatus.required) {
      return RegistrationSituation.required;
    }
    return isExpiredOn(today)
        ? RegistrationSituation.expired
        : RegistrationSituation.registered;
  }

  @override
  bool operator ==(Object other) =>
      other is AuthorityRegistration &&
      other.authority == authority &&
      other.status == status &&
      other.registrationNumber == registrationNumber &&
      other.validUntil == validUntil &&
      other.notes == notes;

  @override
  int get hashCode =>
      Object.hash(authority, status, registrationNumber, validUntil, notes);

  @override
  String toString() =>
      'AuthorityRegistration(${authority.code}, ${status.code}, '
      '$registrationNumber, $validUntil)';
}

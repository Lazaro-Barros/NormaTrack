/// Unidades da federação, em ordem alfabética da sigla. `code` = sigla.
enum BrazilianState {
  ac('AC', 'Acre'),
  al('AL', 'Alagoas'),
  am('AM', 'Amazonas'),
  ap('AP', 'Amapá'),
  ba('BA', 'Bahia'),
  ce('CE', 'Ceará'),
  df('DF', 'Distrito Federal'),
  es('ES', 'Espírito Santo'),
  go('GO', 'Goiás'),
  ma('MA', 'Maranhão'),
  mg('MG', 'Minas Gerais'),
  ms('MS', 'Mato Grosso do Sul'),
  mt('MT', 'Mato Grosso'),
  pa('PA', 'Pará'),
  pb('PB', 'Paraíba'),
  pe('PE', 'Pernambuco'),
  pi('PI', 'Piauí'),
  pr('PR', 'Paraná'),
  rj('RJ', 'Rio de Janeiro'),
  rn('RN', 'Rio Grande do Norte'),
  ro('RO', 'Rondônia'),
  rr('RR', 'Roraima'),
  rs('RS', 'Rio Grande do Sul'),
  sc('SC', 'Santa Catarina'),
  se('SE', 'Sergipe'),
  sp('SP', 'São Paulo'),
  to('TO', 'Tocantins');

  const BrazilianState(this.code, this.label);

  final String code;
  final String label;

  static BrazilianState fromCode(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'BrazilianState'),
  );
}

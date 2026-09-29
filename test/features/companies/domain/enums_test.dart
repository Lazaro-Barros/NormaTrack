import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/features/companies/domain/authority.dart';
import 'package:normatrack/features/companies/domain/brazilian_state.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';

void main() {
  void checkCodes<T extends Enum>(
    List<T> values,
    String Function(T) code,
    T Function(String) fromCode,
  ) {
    for (final v in values) {
      expect(fromCode(code(v)), v);
    }
    expect(values.map(code).toSet(), hasLength(values.length));
    expect(() => fromCode('desconhecido'), throwsArgumentError);
  }

  test('ModuleType', () {
    checkCodes(ModuleType.values, (v) => v.code, ModuleType.fromCode);
    expect(ModuleType.values, hasLength(3));
    expect(ModuleType.controlledProducts.code, 'controlled_products');
  });

  test('Authority', () {
    checkCodes(Authority.values, (v) => v.code, Authority.fromCode);
    expect(Authority.values, hasLength(9));
    expect(Authority.agricultureMinistry.shortLabel, 'MAPA');
  });

  test('RegistrationStatus', () {
    checkCodes(
      RegistrationStatus.values,
      (v) => v.code,
      RegistrationStatus.fromCode,
    );
    expect(RegistrationStatus.required.label, 'Precisa obter');
  });

  test('BrazilianState', () {
    checkCodes(BrazilianState.values, (v) => v.code, BrazilianState.fromCode);
    expect(BrazilianState.values, hasLength(27));
    expect(BrazilianState.fromCode('CE').label, 'Ceará');
    final codes = BrazilianState.values.map((v) => v.code).toList();
    expect(codes, [...codes]..sort());
  });
}

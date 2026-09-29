import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/utils/br_documents.dart';

void main() {
  group('CNPJ', () {
    bool valid(String raw) => isValidCnpj(normalizeCnpj(raw));

    test('numérico válido', () => expect(valid('11.222.333/0001-81'), isTrue));
    test('DV errado', () => expect(valid('11.222.333/0001-82'), isFalse));
    test('alfanumérico válido (exemplo da Receita)', () {
      expect(valid('12.ABC.345/01DE-35'), isTrue);
    });
    test('todos iguais', () => expect(valid('00000000000000'), isFalse));
    test('minúsculas são normalizadas', () {
      expect(normalizeCnpj(' 12.abc.345/01de-35 '), '12ABC34501DE35');
      expect(valid('12.abc.345/01de-35'), isTrue);
    });
    test('tamanho errado', () {
      expect(valid('1122233300018'), isFalse);
      expect(valid('112223330001810'), isFalse);
    });
    test('letra no DV é inválida', () {
      expect(isValidCnpj('12ABC34501DE3A'), isFalse);
    });
    test('formata', () {
      expect(formatCnpj('11222333000181'), '11.222.333/0001-81');
      expect(formatCnpj('12ABC34501DE35'), '12.ABC.345/01DE-35');
      expect(formatCnpj('123'), '123');
    });
  });

  group('CPF', () {
    test('válido', () {
      expect(isValidCpf(normalizeCpf('123.456.789-09')), isTrue);
    });
    test('DV errado', () => expect(isValidCpf('12345678900'), isFalse));
    test('todos iguais', () => expect(isValidCpf('11111111111'), isFalse));
    test('tamanho errado', () => expect(isValidCpf('1234567890'), isFalse));
    test('formata', () {
      expect(formatCpf('12345678909'), '123.456.789-09');
      expect(formatCpf('123'), '123');
    });
  });

  group('CEP', () {
    test('8 dígitos', () {
      expect(isValidPostalCode(normalizePostalCode('60.115-170')), isTrue);
      expect(isValidPostalCode('6011517'), isFalse);
      expect(isValidPostalCode('601151700'), isFalse);
    });
    test('formata', () {
      expect(formatPostalCode('60115170'), '60115-170');
      expect(formatPostalCode('601'), '601');
    });
  });

  group('telefone', () {
    test('10 e 11 dígitos são válidos, 9 não', () {
      expect(isValidPhone(normalizePhone('(85) 3222-1234')), isTrue);
      expect(isValidPhone(normalizePhone('(85) 99876-5432')), isTrue);
      expect(isValidPhone('853222123'), isFalse);
    });
    test('formata', () {
      expect(formatPhone('8532221234'), '(85) 3222-1234');
      expect(formatPhone('85998765432'), '(85) 99876-5432');
      expect(formatPhone('853222123'), '853222123');
    });
  });
}

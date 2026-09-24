import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/core/utils/search_text.dart';

void main() {
  test('remove acentos e passa para minúsculas', () {
    expect(normalizeForSearch('Indústria São João'), 'industria sao joao');
    expect(normalizeForSearch('AÇÚCAR ÊXITO'), 'acucar exito');
  });
}

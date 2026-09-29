import 'package:uuid/uuid.dart';

/// Gera ids de entidades. Injetado para que os testes tenham ids previsíveis.
typedef IdGenerator = String Function();

/// UUID v7: ordenado no tempo, bom para índice e sincronização.
String uuidV7() => const Uuid().v7();

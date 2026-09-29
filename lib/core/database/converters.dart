import 'package:drift/drift.dart';

/// Data sem hora gravada como texto `AAAA-MM-DD`, para não mudar de dia por
/// fuso. Lida de volta como `DateTime(y, m, d)` local.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) {
    final [y, m, d] = fromDb.split('-').map(int.parse).toList();
    return DateTime(y, m, d);
  }

  @override
  String toSql(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

/// Colunas comuns a toda tabela: `id` UUID gerado no app, timestamps e
/// exclusão lógica.
mixin EntityColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

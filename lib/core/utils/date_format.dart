/// `dd/MM/yyyy`. Só a data; a hora é ignorada.
String formatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}

const _months = [
  'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', //
  'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
];

/// Mês abreviado em maiúsculas: `SET`.
String formatMonthAbbr(DateTime d) => _months[d.month - 1];

/// `AAAA-MM-DD` (para rotas e arquivos). Só a data.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Inverso de [isoDate]; `null` se o texto não é uma data válida.
DateTime? parseIsoDate(String text) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final [y, m, d] = [for (var i = 1; i <= 3; i++) int.parse(match[i]!)];
  final date = DateTime(y, m, d);
  return date.year == y && date.month == m && date.day == d ? date : null;
}

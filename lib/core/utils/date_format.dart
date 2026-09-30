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

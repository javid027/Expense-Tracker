import 'package:intl/intl.dart';

DateTime monthStart(DateTime date) => DateTime(date.year, date.month);
DateTime monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0, 23, 59);

bool isInCurrentMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

String shortDate(DateTime date) => DateFormat('d MMM').format(date);
String monthLabel(DateTime date) => DateFormat('MMMM yyyy').format(date);

import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

String formatMoney(num value, {bool compact = false}) {
  if (!compact) return _currency.format(value);
  return NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹')
      .format(value);
}

String formatPercent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

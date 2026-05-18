import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final NumberFormat _currencyCompact =
      NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');

  static String currency(double value) => _currency.format(value);
  static String currencyCompact(double value) => _currencyCompact.format(value);

  static String date(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date.toLocal());
  static String dateTime(DateTime date) =>
      DateFormat('dd MMM, hh:mm a').format(date.toLocal());
  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date.toLocal());

  static String sqlDateTime(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toUtc());
}

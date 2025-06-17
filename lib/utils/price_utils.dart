import 'package:intl/intl.dart';

String formatPrice(double amount) {
  final format = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );
  return format.format(amount);
}
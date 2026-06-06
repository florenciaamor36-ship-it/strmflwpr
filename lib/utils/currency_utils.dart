import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount, {String symbol = 'ARS'}) {
    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '$symbol ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = 'ARS'}) {
    if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: symbol);
  }

  static double parseAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d,\.]'), '');
    final normalized = cleaned.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }
}

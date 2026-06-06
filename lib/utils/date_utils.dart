import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy', 'es');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static bool isExpired(DateTime date) => daysUntil(date) < 0;

  static bool isExpiringSoon(DateTime date, int days) {
    final remaining = daysUntil(date);
    return remaining >= 0 && remaining <= days;
  }

  static String daysRemainingText(DateTime date) {
    final days = daysUntil(date);
    if (days < 0) return 'Vencido hace ${days.abs()} días';
    if (days == 0) return 'Vence hoy';
    if (days == 1) return 'Vence mañana';
    return 'Vence en $days días';
  }

  static DateTime addMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year + (newMonth - 1) ~/ 12;
    newMonth = ((newMonth - 1) % 12) + 1;
    int newDay = date.day;
    final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInNewMonth) newDay = daysInNewMonth;
    return DateTime(newYear, newMonth, newDay);
  }

  static List<DateTime> last6MonthStarts() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = now.month - 5 + i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      return DateTime(year, adjustedMonth, 1);
    });
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}

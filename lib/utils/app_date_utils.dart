import 'package:intl/intl.dart';

/// Local, time-of-day-safe date comparisons so overdue detection doesn't
/// break on time-of-day differences between "now" and stored dates.
class AppDateUtils {
  AppDateUtils._();

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// True if [date] (date-only) is strictly before today (date-only).
  static bool isPastToday(DateTime date) {
    final today = dateOnly(DateTime.now());
    return dateOnly(date).isBefore(today);
  }

  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  static String relativeDueLabel(DateTime dueDate) {
    final today = dateOnly(DateTime.now());
    final due = dateOnly(dueDate);
    final diff = due.difference(today).inDays;
    if (diff < 0) return 'Overdue by ${-diff} day${-diff == 1 ? '' : 's'}';
    if (diff == 0) return 'Due today';
    return 'Due in $diff day${diff == 1 ? '' : 's'}';
  }
}

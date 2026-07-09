import 'package:intl/intl.dart';

class DateFormatUtils {
  DateFormatUtils._();

  static final DateFormat fullDate = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat dayMonth = DateFormat('MMM d');
  static final DateFormat time = DateFormat('h:mm a');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  static final DateFormat dayName = DateFormat('EEEE');
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat apiDate = DateFormat('yyyy-MM-ddTHH:mm:ss');
  static final DateFormat weekDayShort = DateFormat('E');
  static final DateFormat monthDay = DateFormat('MM/dd');

  static String today() => isoDate.format(DateTime.now());

  static String formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortDate.format(dt);
  }

  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    if (diff > -7 && diff < 0) return '${-diff} days ago';
    if (diff > 0 && diff < 7) return 'In $diff days';
    return dayMonth.format(dt);
  }

  static List<DateTime> getCurrentWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return List.generate(7, (i) => now.subtract(Duration(days: weekday - 1 - i)));
  }

  static List<DateTime> getLastDays(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) => now.subtract(Duration(days: i)));
  }

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String durationToString(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes < 60) return '${minutes}m${remainingSeconds > 0 ? ' ${remainingSeconds}s' : ''}';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

import 'package:intl/intl.dart';

class DateFormatter {
  static String shortDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String shortDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static String compactNumber(num value) {
    return NumberFormat.compact().format(value);
  }

  static String percent(double value) {
    return NumberFormat.percentPattern().format(value);
  }
}

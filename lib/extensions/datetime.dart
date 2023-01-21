import 'package:intl/intl.dart';

/// An extension to format datetime values
extension DateTimeExtended on DateTime {
  /// Returns the name of the date.
  String weekdayName() {
    return DateFormat('EEEE').format(this);
  }
}
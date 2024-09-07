import 'package:gpa_galaxy/class/util.dart';

class DateHelper {
  /// List of months in the year, 0 indexed
  static List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  /// Renders a string representing the date in MMMM D, YYYY format
  /// (e.g. "December 25, 2020")
  ///
  /// Parameters:
  ///   - [date]: The DateTime object to format
  ///
  /// Returns:
  ///   - A string representing the date in MMMM D, YYYY format
  static String formatMmmmDYyyy(DateTime date) {
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// Renders a string representing the date in M/D/YYYY format.
  ///
  /// Parameters:
  ///   - [dateTime]: The DateTime object representing the date.
  ///   - [leading]: Flag indicating whether to include leading zero in the month, day, and year.
  ///
  /// Returns:
  ///   - A string representing the date in M/D/YYYY format.
  static String formatMDYyyy(DateTime dateTime, {bool leading = false}) {
    if (leading) {
      var month = Util.addLeadingZero(dateTime.month.toString());
      var day = Util.addLeadingZero(dateTime.day.toString());
      var year = Util.addLeadingZero(dateTime.year.toString(), length: 4);
      return "$month/$day/$year";
    }
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}

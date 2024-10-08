import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';

class Util {
  /// Checks if a given string starts with a vowel.
  ///
  /// Parameters:
  ///   - [str]: The string to be checked.
  ///
  /// Returns:
  ///   - True if the string starts with a vowel, otherwise false.
  static bool startsWithVowel(String str) {
    return str.startsWith(RegExp("[AaEeIiOoUu]"));
  }

  /// Formats a string to look like a title. Capitalize each word, except
  /// for words less than 4 letters.
  ///
  /// Example: "wow the such a cool title" => "Wow the Such a Cool Title"
  ///
  /// Parameters:
  ///   - [str]: The string to format.
  ///
  /// Returns:
  ///   - The formatted string.
  static String formatTitle(String str) {
    var splitStr = str.split(" ");
    for (int i = 0; i < splitStr.length; i++) {
      var word = splitStr[i].toLowerCase().split("");
      if (i == 0 || word.length > 3) {
        word[0] = word[0].toUpperCase();
      }
      splitStr[i] = word.join();
    }
    return splitStr.join(" ");
  }

  /// Gets an action message based on the screen name.
  ///
  /// Parameters:
  ///   - [str]: The screen name.
  ///
  /// Returns:
  ///   - An action message corresponding to the screen name.
  static String getActionFromScreenName(String str) {
    return switch (str) {
      "grades" => "Tap '+' to log a class...",
      "activities" => "Tap '+' to log an activity...",
      _ => "Add $str..."
    };
  }

  /// Gets all classes in a specific semester.
  ///
  /// Parameters:
  ///   - [profile]: The user profile.
  ///   - [grade]: The grade level.
  ///   - [semester]: The semester.
  ///
  /// Returns:
  ///   - A list of classes in the specified semester.
  static List<Class> getClassesInSemester(
    Profile profile,
    Grade grade,
    Semester semester,
  ) {
    List<Class> classes = profile.academics[grade]?[semester] ?? [];
    return classes;
  }

  /// Gets all classes in a specific year.
  ///
  /// Parameters:
  ///   - [profile]: The user profile.
  ///   - [grade]: The grade level.
  ///
  /// Returns:
  ///   - A list of classes in the specified year.
  static List<Class> getClassesInYear(Profile profile, Grade grade) {
    return getClassesInSemester(profile, grade, Semester.s1) +
        getClassesInSemester(profile, grade, Semester.s2);
  }

  /// Gets all classes from the profile.
  ///
  /// Parameters:
  ///   - [profile]: The user profile.
  ///
  /// Returns:
  ///   - A list of all classes present in the profile.
  static List<Class> getAllClasses(Profile profile) {
    return getClassesInYear(profile, Grade.freshman) +
        getClassesInYear(profile, Grade.sophomore) +
        getClassesInYear(profile, Grade.junior) +
        getClassesInYear(profile, Grade.senior);
  }

  /// Renders a string representing the date in M/D format.
  ///
  /// Parameters:
  ///   - [dateTime]: The DateTime object representing the date.
  ///   - [leading]: Flag indicating whether to include leading zero in the month and day.
  ///
  /// Returns:
  ///   - A string representing the date in M/D format.
  static String renderDateMD(DateTime dateTime, {bool leading = false}) {
    if (leading) {
      var month = addLeadingZero(dateTime.month.toString());
      var day = addLeadingZero(dateTime.day.toString());
      return "$month/$day";
    }
    return "${dateTime.month}/${dateTime.day}";
  }

  /// Adds leading zeros in front of the number.
  ///
  /// Parameters:
  ///   - [number]: The number to be padded with leading zeros.
  ///   - [length]: The desired length of the resulting string.
  ///
  /// Returns:
  ///   - The input number padded with leading zeros.
  static addLeadingZero(String number, {int length = 2}) {
    return number.padLeft(length, "0");
  }

  /// Returns a dynamic size based on the width provided. This can be used, for example,
  /// for fonts; they will always take up the same amount of width on all devices.
  ///
  /// Parameters:
  ///  - [size]: the size as it would look on a 300px wide screen
  ///  - [width]: the width to base the font size off of
  ///
  /// returns:
  ///  - a size that scales dynamically to the width provided
  static dynamicUnit(double size, double width) {
    return width / 300 * size;
  }
}

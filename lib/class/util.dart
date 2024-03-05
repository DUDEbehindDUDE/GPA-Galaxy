import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';

class Util {
  static bool startsWithVowel(String str) {
    return str.startsWith(RegExp("[AaEeIiOoUu]"));
  }

  static String getActionFromScreenName(String str) {
    return switch (str) {
      "grades" => "Tap '+' to log a class...",
      "activities" => "Tap '+' to log an activity...",
      _ => "Add $str..."
    };
  }

  static List<Class> getClassesInSemester(
    Profile profile,
    Grade grade,
    Semester semester,
  ) {
    List<Class> classes = profile.academics[grade]?[semester] ?? [];
    return classes;
  }

  static List<Class> getClassesInYear(Profile profile, Grade grade) {
    return getClassesInSemester(profile, grade, Semester.s1) +
        getClassesInSemester(profile, grade, Semester.s2);
  }

  static List<Class> getAllClasses(Profile profile) {
    return getClassesInYear(profile, Grade.freshman) +
        getClassesInYear(profile, Grade.sophomore) +
        getClassesInYear(profile, Grade.junior) +
        getClassesInYear(profile, Grade.senior);
  }

  /// Returns a string of the date, in M/D format (e.g. 1/23)
  /// from the [dateTime] given. If [leadingZero] is true, will be in format
  /// MM/DD (e.g. 01/03)
  static String renderDateMD(DateTime dateTime, {bool leadingZero = false}) {
    if (leadingZero) {
      var month = addLeadingZero(dateTime.month.toString());
      var day = addLeadingZero(dateTime.day.toString());
      return "$month/$day";
    }
    return "${dateTime.month}/${dateTime.day}";
  }

  /// Returns a string of the date, in M/D/YYYY format (e.g. 1/23/2024)
  /// from the [dateTime] given. If [leadingZero] is true, will be in format 
  /// MM/DD/YYYY (e.g. 01/03/2024)
  static String renderDateMDYyyy(DateTime dateTime, {bool leadingZero = false}) {
    if (leadingZero) {
      var month = addLeadingZero(dateTime.month.toString());
      var day = addLeadingZero(dateTime.day.toString());
      var year = addLeadingZero(dateTime.year.toString(), length: 4);
      return "$month/$day/$year";
    }
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }

  /// Adds leading zeros in front of the number (so 1 -> 01) if number is less than length
  static addLeadingZero(String number, {int length = 2}) {
    return number.padLeft(length, "0");
  }
}

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
      "grades" => "Add a class...",
      "activities" => "Add an activity...",
      _ => "Add $str..."
    };
  }

  static Widget getNewItemDialogFromName(String str, dynamic args) {
    return switch (str) {
      // "grades" => ,
      _ => throw ("Item not ")
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

  /// Returns a string of the date, in Month/Day format (e.g. 1/26) 
  /// from the [dateTime] given
  static String renderDateMD(DateTime dateTime) {
    return "${dateTime.month}/${dateTime.day}";
  }
}

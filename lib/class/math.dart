import 'dart:math';

import 'package:gpa_galaxy/generics/type_adapters/class.dart';

class Math {
  /// Rounds a double number to a specified number of decimal places.
  ///
  /// Parameters:
  ///   - [number]: The number to be rounded.
  ///   - [decimalPlaces]: The number of decimal places to round to.
  ///
  /// Returns:
  ///   - The rounded number.
  static double roundToDecimalPlaces(double number, int decimalPlaces) {
    return (number * pow(10, decimalPlaces)).roundToDouble() / pow(10, decimalPlaces); 
  }

  /// Calculates the GPA from a list of classes.
  ///
  /// Parameters:
  ///   - [classes]: The list of classes.
  ///   - [weighted]: Flag indicating whether to calculate weighted GPA (default is true).
  ///
  /// Returns:
  ///   - The calculated GPA.
  static double getGpaFromClasses(List<Class> classes, {weighted = true}) {
    // return 0 if there aren't any classes, otherwise this will return NaN (because we'll be dividing by zero)
    if (classes.isEmpty) return 0;

    double totalGPA = 0;
    // get the gpa per class
    for (var item in classes) {
      // the min is so 100 doesn't count as a 5.0 gpa,
      // the max is so you don't have a negative gpa
      double gpa = max(0, (min(item.grade, 99) / 10).floor() - 5);
      if (weighted) gpa += item.classWeight;
      totalGPA += gpa;
    }

    return totalGPA / classes.length;
  }
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test1/class/database_helper.dart';
import 'package:flutter_test1/class/math.dart';

class Grades extends StatefulWidget {
  const Grades({super.key});

  @override
  createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  Math math = Math();
  DatabaseHelper? gradesDatabaseHelper;

  Future<void> getDatabaseHelper() async {
    var gradesDatabaseHelper = await DatabaseHelper.create("grades");
    setState(() {
      this.gradesDatabaseHelper = gradesDatabaseHelper;
    });
  }

  String gpaText() {
    if (calcGPA() != calcGPA() || calcGPA() == 0) {
      // ^ NaN check
      return "Not enough data to calculate your GPA. Try adding more classes.";
    }
    return '''
Weighted GPA: ${calcGPA()}
Unweighted GPA: ${calcGPA(weighted: false)}
''';
  }

  double calcGPA({bool weighted = true}) {
    if (gradesDatabaseHelper == null) return 0;

    double totalGPA = 0;
    var allDatabaseItems = gradesDatabaseHelper!.getAllItems();
    List<dynamic> allClasses = [];
    for (var databaseItem in allDatabaseItems) {
      // I genuinely don't know why I need this extra for loop
      for (var item in databaseItem) {
        allClasses.add(item);
      }
    }

    for (var item in allClasses) {
      int grade = int.parse(item[1]);
      double weight = item[2] as double;
      if (grade >= 100) grade = 99; // 100 isn't a 5.0 gpa
      double gpa = max(0, (grade / 10).floor() - 5);
      if (weighted) gpa += weight;
      totalGPA += gpa;
    }

    return math.roundToDecimalPlaces(totalGPA / allClasses.length, 4);
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(fontSize: 18);
    getDatabaseHelper();

    if (gradesDatabaseHelper == null) {
      return const Text("");
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GPA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              Text(
                gpaText(),
                style: style,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

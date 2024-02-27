import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/math.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Grades extends StatefulWidget {
  final String profile;

  const Grades({super.key, required this.profile});

  @override
  createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  Math math = Math();
  var profileBox = Hive.box<Profile>("profiles");

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
    double totalGPA = 0;
    Profile profile = profileBox.get(widget.profile)!;

    // Get all the classes out of the database
    List<Class> allClasses = [];
    profile.academics.forEach((key, semesters) {
      semesters.forEach((key, classes) {
        for (var item in classes) {
          allClasses.add(item);
        }
      });
    });

    for (var item in allClasses) {
      // the min is so 100 doesn't count as a 5.0 gpa,
      // the max is so you don't have a negative gpa
      double gpa = max(0, (min(item.grade, 99) / 10).floor() - 5);
      if (weighted) gpa += item.classWeight;
      totalGPA += gpa;
    }

    return math.roundToDecimalPlaces(totalGPA / allClasses.length, 4);
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(fontSize: 18);

    return ValueListenableBuilder<Box>(
      valueListenable: profileBox.listenable(),
      builder: (context, value, child) {
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
                      fontWeight: FontWeight.w600,
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
      },
    );
  }
}

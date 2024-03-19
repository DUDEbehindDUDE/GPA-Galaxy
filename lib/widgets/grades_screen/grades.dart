
import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/math.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Grades extends StatelessWidget {
  final profileBox = Hive.box<Profile>("profiles");
  final String profile;

  Grades({super.key, required this.profile});

  /// Returns a formatted string representing the GPA information.
  ///
  /// If the calculated GPA is 0, it indicates insufficient data, and a corresponding message is returned.
  /// Otherwise, it returns the weighted and unweighted GPA values.
  String _gpaText() {
    if (_getGPA() == 0) {
      return "Not enough data to calculate your GPA. Try adding more classes.";
    }
    return '''
Weighted GPA: ${_getGPA()}
Unweighted GPA: ${_getGPA(weighted: false)}
''';
  }

  /// Calculates and returns the GPA based on the classes in the profile.
  double _getGPA({weighted = true}) {
    // Get all the classes out of the database
    Profile profile = profileBox.get(this.profile)!;
    List<Class> allClasses = Util.getAllClasses(profile);

    // Calculate and round GPA
    return Math.roundToDecimalPlaces(
      Math.getGpaFromClasses(allClasses, weighted: weighted),
      4,
    );
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
                    _gpaText(),
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


import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/math.dart';
import 'package:gpa_galaxy/class/util.dart';
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
    if (getGPA() == 0) {
      return "Not enough data to calculate your GPA. Try adding more classes.";
    }
    return '''
Weighted GPA: ${getGPA()}
Unweighted GPA: ${getGPA(weighted: false)}
''';
  }

  double getGPA({weighted = true}) {
    // Get all the classes out of the database
    Profile profile = profileBox.get(widget.profile)!;
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

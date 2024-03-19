import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/widgets/layout/layout_content_items.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Widget responsible for displaying content based on the selected screen and profile.
class LayoutContent extends StatelessWidget {
  final String screen;
  final String profile;
  final profileBox = Hive.box<Profile>("profiles");

  LayoutContent({super.key, required this.screen, required this.profile});

  /// Retrieves content based on the selected screen and grade.
  List<dynamic> getContent(Grade grade) {
    Profile profile = profileBox.get(this.profile)!;
    List<dynamic> content = [];

    if (screen == "grades") {
      var semesters = profile.academics[grade];
      if (semesters == null) return [];

      semesters.forEach((semester, classes) {
        for (var item in classes) {
          content.add([item.className, item.grade, semester]);
        }
      });

      return content;
    }

    if (screen == "activities") {
      var activities = profile.activities[grade];
      if (activities == null) return [];
      for (var item in activities) {
        content.add([item.name, "${item.weeklyTime} hr/wk"]);
      }
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<Box>(
      valueListenable: profileBox.listenable(),
      builder: (context, box, widget) {
        return Column(
          children: <Widget>[
            LayoutContentItems(
              profile: profile,
              screen: screen,
              grade: Grade.freshman,
              title: "9th Grade",
              content: getContent(Grade.freshman),
            ),
            LayoutContentItems(
              profile: profile,
              screen: screen,
              grade: Grade.sophomore,
              title: "10th Grade",
              content: getContent(Grade.sophomore),
            ),
            LayoutContentItems(
              profile: profile,
              screen: screen,
              grade: Grade.junior,
              title: "11th Grade",
              content: getContent(Grade.junior),
            ),
            LayoutContentItems(
              profile: profile,
              screen: screen,
              grade: Grade.senior,
              title: "12th Grade",
              content: getContent(Grade.senior),
            ),
          ],
        );
      },
    );
  }
}

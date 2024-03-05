import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:gpa_galaxy/widget/activities_screen/add_activity_dialog.dart';
import 'package:gpa_galaxy/widget/grades_screen/add_grade_dialog.dart';

class LayoutContentItems extends StatelessWidget {
  const LayoutContentItems({
    super.key,
    required this.screen,
    required this.title,
    required this.grade,
    required this.profile,
    this.content = const [],
  });

  final String title;
  final Grade grade;
  final String screen;
  final String profile;
  final List<dynamic> content;

  Widget _getDialog() {
    return switch (screen) {
      "grades" => AddGradeDialog(grade: grade, profile: profile),
      "activities" => AddActivityDialog(grade: grade, profile: profile),
      _ => throw ("'$screen' does not have a dialog!"),
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> calculateItems() {
      const TextStyle style = TextStyle(fontSize: 18);
      const TextStyle categoryStyle = TextStyle(color: Colors.grey);

      List<Widget> items = [];
      items.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => _getDialog(),
            ),
            // color: Colors.black,
            icon: const Icon(Icons.add, size: 36),
          ),
        ],
      ));
      if (content.isEmpty) {
        items.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Util.getActionFromScreenName(screen), style: style),
          ],
        ));
        return items;
      }

      // Add S1 heading
      if (screen == "grades") {
        items.add(const Row(
          children: [
            Text(
              "Class · S1",
              style: categoryStyle,
              textAlign: TextAlign.start,
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Text("Grade", style: categoryStyle),
            ),
          ],
        ));
        items.add(const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Divider(height: 8.0),
        ));
      }

      // Add activity heading
      if (screen == "activities") {
        items.add(const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                "Activity name",
                style: categoryStyle,
                textAlign: TextAlign.start,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 14.0),
                child: Text("Hours spent per week", style: categoryStyle),
              ),
            ],
          ),
        ));
        items.add(const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Divider(height: 8.0),
        ));
      }

      // used to track when S2 classes begin in classes item
      var lastSemester = Semester.s1;

      for (List<dynamic> item in content) {
        if (item.isEmpty) continue;
        final String mainText = item[0].toString();
        final String secondaryText =
            (item.length >= 2) ? item[1].toString() : "";

        // Add S2 heading
        if (screen == "grades" && lastSemester == Semester.s1) {
          if (item[2] == Semester.s2) {
            lastSemester = Semester.s2;
            items.add(const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Text(
                    "Class · S2",
                    style: categoryStyle,
                    textAlign: TextAlign.start,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 14.0),
                    child: Text("Grade", style: categoryStyle),
                  ),
                ],
              ),
            ));
            items.add(const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Divider(height: 8.0),
            ));
          }
        }

        items.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                mainText,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 14),
              child: Text(secondaryText, style: style),
            ),
          ],
        ));
      }
      return items;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: calculateItems(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/profile.dart';
import 'package:flutter_test1/widget/activities_screen/add_activity_dialog.dart';
import 'package:flutter_test1/widget/grades_screen/add_grade_dialog.dart';
import 'package:flutter_test1/class/util.dart';

class LayoutContentItems extends StatelessWidget {
  LayoutContentItems({
    super.key,
    required this.screen,
    required this.title,
    required this.grade,
    required this.profile,
    this.content = const [],
  });

  final util = Util();
  final String title;
  final Grade grade;
  final String screen;
  final String profile;
  final List<dynamic> content;

  Widget _getDialog() {
    return switch(screen) {
      "grades" => AddGradeDialog(grade: grade, profile: profile),
      "activities" => AddActivityDialog(grade: grade, profile: profile),
      _ => throw("'$screen' does not have a dialog!"),
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> calculateItems() {
      const TextStyle style = TextStyle(fontSize: 18);

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
              builder: (BuildContext context) =>
                  _getDialog(),
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
            Text(util.getActionFromScreenName(screen), style: style),
          ],
        ));
        return items;
      }

      for (List<dynamic> item in content) {
        if (item.isEmpty) continue;
        final String mainText = item[0].toString();
        final String secondaryText =
            (item.length >= 2) ? item[1].toString() : "";

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
              padding: const EdgeInsets.only(left: 8),
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
        children: calculateItems(),
      ),
    );
  }
}

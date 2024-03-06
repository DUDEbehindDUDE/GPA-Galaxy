import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:gpa_galaxy/widget/activities_screen/add_activity_dialog.dart';
import 'package:gpa_galaxy/widget/grades_screen/add_grade_dialog.dart';

/// Widget responsible for displaying content items based on the selected screen.
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

  /// Returns the dialog widget based on the selected screen.
  Widget _getDialog() {
    return switch (screen) {
      "grades" => AddGradeDialog(grade: grade, profile: profile),
      "activities" => AddActivityDialog(grade: grade, profile: profile),
      _ => throw ("'$screen' does not have a dialog!"),
    };
  }

  /// Get the main heading of the section
  Widget _getMainHeading(BuildContext ctx) {
    return Row(
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
            context: ctx,
            builder: (BuildContext context) => _getDialog(),
          ),
          icon: const Icon(Icons.add, size: 36),
        ),
      ],
    );
  }

  /// Get the heading of the inner content
  List<Widget> _getInnerHeading(String item) {
    const TextStyle categoryStyle = TextStyle(color: Colors.grey);

    // Get heading text
    List<String> text = switch (item) {
      "S1" || "S2" => ["Class · $item", "Grade"],
      "Activity" => ["Activity name", "Hours spent per week"],
      _ => throw ("Item not valid"),
    };

    // Build heading
    return [
      Row(
        children: [
          Text(
            text[0],
            style: categoryStyle,
            textAlign: TextAlign.start,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Text(text[1], style: categoryStyle),
          ),
        ],
      ),
      const Padding(
        padding: EdgeInsets.only(right: 14.0),
        child: Divider(height: 8.0),
      )
    ];
  }

  /// Calculates the list of items to be displayed based on the content and screen.
  List<Widget> _calculateItems(BuildContext ctx) {
    // Styles for text
    const TextStyle hintStyle = TextStyle(
      fontSize: 18,
      fontStyle: FontStyle.italic,
    );

    // Get main heading
    List<Widget> items = [];
    items.add(_getMainHeading(ctx));

    // Display hint if content is empty, and return
    if (content.isEmpty) {
      items.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Util.getActionFromScreenName(screen), style: hintStyle),
        ],
      ));
      return items;
    }

    // Add category headings
    if (screen == "grades") {
      items += _getInnerHeading("S1");
    } else {
      items += _getInnerHeading("Activity");
    }

    // Add content items
    // Used to track when S2 classes begin in classes item
    var lastSemester = Semester.s1;
    for (List<dynamic> item in content) {
      if (item.isEmpty) continue;
      final String mainText = item[0].toString();
      final String secondaryText = (item.length >= 2) ? item[1].toString() : "";

      // Add S2 heading
      if (screen == "grades" && lastSemester == Semester.s1) {
        if (item[2] == Semester.s2) {
          lastSemester = Semester.s2;
          items.add(const Padding(padding: EdgeInsets.only(top: 16.0)));
          items += _getInnerHeading("S2");
        }
      }

      // Add content item
      items.add(_buildItem(mainText, secondaryText));
    }
    return items;
  }

  /// Builds a single content item widget with the provided [mainText] and [secondaryText].
  Widget _buildItem(String mainText, String secondaryText) {
    const TextStyle style = TextStyle(fontSize: 18);
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _calculateItems(context),
      ),
    );
  }
}

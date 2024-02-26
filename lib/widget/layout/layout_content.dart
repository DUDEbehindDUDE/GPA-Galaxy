import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/profile.dart';
import 'package:flutter_test1/widget/layout/layout_content_items.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LayoutContent extends StatefulWidget {

  const LayoutContent({super.key, required this.screen, required this.profile});

  final String screen;
  final String profile;

  @override
  State<LayoutContent> createState() => _LayoutContentState();
}

class _LayoutContentState extends State<LayoutContent> {

  @override
  Widget build(BuildContext context) {
    var profileBox = Hive.box<Profile>("profiles");
    var screen = widget.screen;
    var profileName = widget.profile;

    List<dynamic> getContent(Grade grade) {
      Profile profile = profileBox.get(profileName)!;
      List<dynamic> content = [];

      if (widget.screen == "grades") {
        var semesters = profile.academics[grade];
        if (semesters == null) return [];

        semesters.forEach((key, semester) {
          for (var item in semester) {
            content.add([item.className, item.grade]);
          }
        });

        return content;
      }

      if (widget.screen == "activities") {
        var activities = profile.activities[grade];
        if (activities == null) return [];
        for (var item in activities) {
          content.add([item.name, "${item.weeklyTime} hr/wk"]);
        }
      }

      return content;
    }
    
    return ValueListenableBuilder<Box>(
      valueListenable: profileBox.listenable(),
      builder: (context, box, widget) {
        return Column(
          children: <Widget>[
            LayoutContentItems(
              profile: profileName,
              screen: screen,
              grade: Grade.freshman,
              title: "9th Grade",
              content: getContent(Grade.freshman),
            ),
            LayoutContentItems(
              profile: profileName,
              screen: screen,
              grade: Grade.sophomore,
              title: "10th Grade",
              content: getContent(Grade.sophomore),
            ),
            LayoutContentItems(
              profile: profileName,
              screen: screen,
              grade: Grade.junior,
              title: "11th Grade",
              content: getContent(Grade.junior),
            ),
            LayoutContentItems(
              profile: profileName,
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

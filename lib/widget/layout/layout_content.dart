import 'package:flutter/material.dart';
import 'package:flutter_test1/class/database_helper.dart';
import 'package:flutter_test1/widget/layout/layout_content_items.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LayoutContent extends StatefulWidget {
  const LayoutContent({super.key, required this.screen});

  final String screen;

  @override
  State<LayoutContent> createState() => _LayoutContentState();
}

class _LayoutContentState extends State<LayoutContent> {
  DatabaseHelper? gradeDatabaseHelper;
  
  Future<void> getDatabaseHelper() async {
    var gradeDatabaseHelper = await DatabaseHelper.create(widget.screen);
    setState(() {
      this.gradeDatabaseHelper = gradeDatabaseHelper;
    });
  }

  @override
  Widget build(BuildContext context) {
    getDatabaseHelper();
    var screen = widget.screen;
    var gradeDatabaseHelper = this.gradeDatabaseHelper;

    if (gradeDatabaseHelper == null) {
      // since hive works almost instantly, having a loading screen here
      // would be more annoying than just showing nothing for .1 secs
      return const Text("");
    }
    
    return ValueListenableBuilder<Box>(
      valueListenable: gradeDatabaseHelper.getListener(),
      builder: (context, box, widget) {
        return Column(
          children: <Widget>[
            LayoutContentItems(
              screen: screen,
              title: "9th Grade",
              content: gradeDatabaseHelper.getItems("9th Grade"),
            ),
            LayoutContentItems(
              screen: screen,
              title: "10th Grade",
              content: gradeDatabaseHelper.getItems("10th Grade"),
            ),
            LayoutContentItems(
              screen: screen,
              title: "11th Grade",
              content: gradeDatabaseHelper.getItems("11th Grade"),
            ),
            LayoutContentItems(
              screen: screen,
              title: "12th Grade",
              content: gradeDatabaseHelper.getItems("12th Grade"),
            ),
          ],
        );
      },
    );
  }
}

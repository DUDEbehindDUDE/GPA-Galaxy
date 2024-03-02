import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/achievement_helper.dart';
import 'package:gpa_galaxy/generics/achievements.dart';
import 'package:gpa_galaxy/widget/grades_screen/grades.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'layout_content.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.profile});

  final String profile;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  var profileBox = Hive.box("profiles");
  int _selectedIndex = 0;
  String _title = "Grades";
  late Widget _content;
  late Widget _additionalContent;
  final List<String> _screenNames = [
    "Grades",
    "Activities",
    "Volunteer Hours",
    "Achievements"
  ];
  // Map<String, Achievements> achievements = Achievements(name: "hello", desc: "desc", dependent: "variable", requirements: [1]);
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _title = _screenNames[index];

      _content = switch (index) {
        0 => LayoutContent(screen: "grades", profile: widget.profile),
        1 => LayoutContent(screen: "activities", profile: widget.profile),
        2 => const Text(""), // empty element
        3 => const Text(""), // empty element
        _ => throw ("$index not in range"),
      };

      _additionalContent = switch (index) {
        0 => Grades(profile: widget.profile),
        1 || 2 || 3 => const Text(""), // empty element
        _ => throw ("$index not in range"),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    _onDestinationSelected(_selectedIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
        iconTheme: const IconThemeData(size: 28, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _content,
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              _additionalContent,
              // extra padding on the bottom so edit button isn't gonna block anything
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),

              // Check for new achievements when the box changes
              ValueListenableBuilder(
                valueListenable: profileBox.listenable(),
                builder: (context, box, widget) {
                  AchievementHelper.getNewAchievements(context);

                  // we don't need to return anything, so we will just have an empty text widget
                  return const Text("");
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Hive.box(_screenNames[_selectedIndex].toLowerCase()).clear();
        },
        child: const Icon(Icons.edit_outlined),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: "Grades",
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_basketball_outlined),
            selectedIcon: Icon(Icons.sports_basketball),
            label: "Activities",
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: "Volunteering",
          ),
          NavigationDestination(
            // I don't know why the trophy icon isn't in here, but this
            // one is literally the exact same so 🤷
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: "Achievements",
          ),
        ],
      ),
    );
  }
}

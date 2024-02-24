import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/achievements.dart';
import 'package:flutter_test1/widget/grades_screen/grades.dart';
import 'package:hive/hive.dart';

import 'layout_content.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.selected});

  final String selected;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;
  String _title = "Grades";
  Widget _content = const LayoutContent(screen: "grades");
  Widget _additionalContent = const Grades();
  final List<String> _screenNames = [
    "Grades",
    "Activities",
    "Volunteer Hours",
    "Achievements"
  ];
  var achievement = Achievements(name: "hello", desc: "desc", dependent: "variable", requirements: [1]);
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _title = _screenNames[index];

      _content = switch (index) {
        0 => const LayoutContent(screen: "grades"),
        1 => const LayoutContent(screen: "activities"),
        _ => const Text(""), // empty element
      };

      _additionalContent = switch (index) {
        0 => const Grades(),
        _ => const Text(""), // empty element
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
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
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium),
            label: "Achievements",
          ),
        ],
      ),
    );
  }
}

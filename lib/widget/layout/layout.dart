import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/achievement_helper.dart';
import 'package:gpa_galaxy/generics/achievements.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/widget/grades_screen/edit_dialog.dart'
    as grade_edit_dialog;
import 'package:gpa_galaxy/widget/activities_screen/edit_dialog.dart'
    as activity_edit_dialog;
import 'package:gpa_galaxy/widget/grades_screen/grades.dart';
import 'package:gpa_galaxy/widget/volunteer_screen/add_volunteer_dialog.dart';
import 'package:gpa_galaxy/widget/volunteer_screen/volunteer_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'layout_content.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.profile});

  final String profile;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  var profileBox = Hive.box<Profile>("profiles");
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
        2 => VolunteerScreen(profile: widget.profile),
        3 => const SizedBox(), // empty element
        _ => throw ("$index not in range"),
      };

      _additionalContent = switch (index) {
        0 => Grades(profile: widget.profile),
        1 || 2 || 3 => const SizedBox(), // empty element
        _ => throw ("$index not in range"),
      };
    });
  }

  void _updateAchievements(BuildContext context) async {
    // Get profile object
    Profile profile = profileBox.get(widget.profile)!;

    // get all the earned achievements
    var newAchievements = await AchievementHelper.updateEarnedAchievements(
      profile,
      context,
      _onDestinationSelected,
    );

    // if it was invalid we don't want to update anything
    if (newAchievements == null) return;

    // update box
    Profile newProfile = profile;
    newProfile.unlockedAchievements = newAchievements;
    profileBox.put(widget.profile, newProfile);
  }

  /// Returns the proper floatingActionButton based on the screen
  FloatingActionButton? _getFloatingActionButton() {
    // floating action button isn't necessary on achievements screen
    if (_selectedIndex == 3) return null;

    // floating action button logs an item on volunteer screen 
    if (_selectedIndex == 2) {
      return FloatingActionButton(
        onPressed: () => _showFloatingActionDialog(),
        child: const Icon(Icons.add),
      );
    }

    // on other screens it edits items
    return FloatingActionButton(
      onPressed: () => _showFloatingActionDialog(),
      child: const Icon(Icons.edit_outlined),
    );
  }

  /// Displays the proper dialog from the action button based on the current screen
  void _showFloatingActionDialog() {
    var dialog = switch (_selectedIndex) {
      0 => grade_edit_dialog.EditDialog(profile: widget.profile),
      1 => activity_edit_dialog.EditDialog(profile: widget.profile),
      2 => AddVolunteerDialog(profile: widget.profile),
      _ => null,
    };
    if (dialog == null) return;

    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get selected index (_content might not be initialized if we don't)
    _onDestinationSelected(_selectedIndex);
    Color bgColor = const Color.fromARGB(180, 16, 0, 22);
    Color accentColor = const Color.fromARGB(180, 66, 33, 78);
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    // main profile scaffold
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
        iconTheme: const IconThemeData(size: 28, color: Colors.white),
        backgroundColor: bgColor,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/galaxy2.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, top: topPadding, right: 2),
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
                      _updateAchievements(context);

                      // we don't need to return anything, but we can't return null, so here is an empty widget
                      return const SizedBox();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: bgColor,
        elevation: 0,
        indicatorColor: accentColor,
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

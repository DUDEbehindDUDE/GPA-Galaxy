import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/widget/info/info_index.dart';
import 'package:gpa_galaxy/widget/profile/create_profile_dialog.dart';
import 'package:gpa_galaxy/widget/layout/layout.dart';
import 'package:gpa_galaxy/widget/profile/delete_profile_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  String? selected;
  var profileBox = Hive.box<Profile>("profiles");

  List<Widget> _getProfileSelections() {
    List<Widget> profiles = [];
    for (String profileName in profileBox.keys) {
      profiles.add(Card(
        child: ListTile(
          selected: _isSelected(profileName),
          onTap: () {
            _setSelected(null);
            _goToProfile(context, profileName);
          },
          onLongPress: () => _setSelected(profileName),
          title: Text(profileName),
          trailing: _isSelected(profileName) ? const Icon(Icons.check) : null,
        ),
      ));
    }

    // If the user hasn't created a profile, tell them how to create one
    // otherwise, add a hint below that you can long press for more context actions
    if (profiles.isEmpty) {
      profiles.add(const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 32.0),
          child: Card.outlined(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            color: Color.fromARGB(209, 26, 14, 31),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "It looks like you haven't made a profile yet. Tap 'New' below to create one.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    } else {
      profiles.add(Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: (profileBox.keys.isNotEmpty)
            ? Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(50, 0, 0, 0),
                  borderRadius:
                      BorderRadius.circular(6.0), // Set desired radius
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.only(left: 4, right: 4, top: 1, bottom: 1),
                  child: Text(
                    "Long press on an item for more actions",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : null,
      ));
    }

    return profiles;
  }

  // Navigates to the profile when you tap it
  void _goToProfile(context, profileName) async {
    await Hive.openBox(profileName);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Layout(profile: profileName)),
    );
  }

  // This function toggles the selection of a profile
  void _setSelected(name) {
    setState(() {
      if (_isSelected(name)) {
        selected = null;
        return;
      }
      selected = name;
    });
  }

  bool _isSelected(name) {
    return (name == selected);
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    Color bgColor = const Color.fromARGB(180, 16, 0, 22);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          "Select a Profile",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
        iconTheme: const IconThemeData(size: 28, color: Colors.white),
      ),
      persistentFooterButtons: [
        // This is wrapped in a row to make it so that the info icon can float left, and everything else can float right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => InfoIndex()),
              ),
              icon: const Icon(Icons.info_outlined),
            ),
            const Spacer(),

            // Edit Button
            TextButton(
              // set this to null if nothing is selected, which disables button
              onPressed: selected == null ? null : () {},
              child: const Text("Edit"),
            ),

            // Delete Profile Button
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                // set this to null if nothing is selected, which disables button
                onPressed: selected == null
                    ? null
                    : () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              DeleteProfileDialog(profile: selected!),
                        );
                        _setSelected(null);
                      },
                child: const Text("Delete"),
              ),
            ),

            // New profile button
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilledButton(
                child: const Text("New"),
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const CreateProfileDialog()),
              ),
            )
          ],
        )
      ],
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/galaxy1.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          ValueListenableBuilder<Box>(
            valueListenable: profileBox.listenable(),
            builder: (content, box, widget) {
              return SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 8.0, right: 8.0, top: topPadding),
                  child: Column(
                    children: _getProfileSelections(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

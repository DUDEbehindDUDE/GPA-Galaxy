import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/type_adapters/profile.dart';
import 'package:flutter_test1/widget/create_profile_dialog.dart';
import 'package:flutter_test1/widget/layout/layout.dart';
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
    List<Widget> profiles = [
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
        child: (profileBox.keys.isNotEmpty)
            ? const Text("Long press on an item for more actions")
            : null,
      ),
    ];
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

    profiles.add(Center(
      child: TextButton(
        child: const Text("Delete all profiles (debug)"),
        onPressed: () => profileBox.clear(),
      ),
    ));
    profiles.add(Center(
      child: TextButton(
        child: const Text("New profile..."),
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => const CreateProfileDialog(),
        ),
      ),
    ));

    return profiles;
  }

  void _goToProfile(context, profileName) async {
    await Hive.openBox(profileName);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Layout(profile: profileName)),
    );
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select a Profile",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
        iconTheme: const IconThemeData(size: 28, color: Colors.white),
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: selected == null ? null : () {},
          child: const Text("Edit"),
        ),
        TextButton(
          onPressed: selected == null
              ? null
              : () {
                  profileBox.delete(selected);
                  _setSelected(null);
                },
          child: const Text("Delete"),
        ),
      ],
      body: ValueListenableBuilder<Box>(
        valueListenable: profileBox.listenable(),
        builder: (content, box, widget) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _getProfileSelections(),
              ),
            ),
          );
        },
      ),
    );
  }
}

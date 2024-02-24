import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/profile.dart';
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
    List<Widget> profiles = [];
    for (String profileName in profileBox.keys) {
      profiles.add(Card(
        child: ListTile(
          selected: _isSelected(profileName),
          onTap: () => _setSelected(profileName),
          title: Text(profileName),
          trailing: _isSelected(profileName) ? const Icon(Icons.check) : null,
        ),
      ));
    }
    profiles.add(Center(
      child: TextButton(
        child: const Text("Delete all profiles (debug)"),
        onPressed: () {
          profileBox.clear();
          _setSelected(null);                    
        },
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

  void _goToProfile(context) async {
    var selected = this.selected;
    if (selected == null) return;

    await Hive.openBox(selected);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Layout(selected: selected)),
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
        title: const Text("Select a Profile"),
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: selected == null ? null : () => _goToProfile(context),
          child: const Text("Done"),
        )
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

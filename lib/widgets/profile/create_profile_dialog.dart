import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:gpa_galaxy/generics/type_adapters/activity.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreateProfileDialog extends StatefulWidget {
  const CreateProfileDialog({Key? key}) : super(key: key);

  @override
  createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<CreateProfileDialog> {
  var profileBox = Hive.box<Profile>("profiles");
  String? profileNameErrorText;
  String? profileName;

  void _checkIfNameTaken(name) {
    if (profileBox.keys.contains(name)) {
      profileNameErrorText = "Profile name is already taken";
      profileName = null;
    }
  }

  void _addProfileToBox() {
    var profileName = this.profileName;
    if (profileName == null) return; // shouldn't happen but just in case
    if (profileBox.get(profileName) != null) return;

    var newProfile = Profile(
      academics: <Grade, Map<Semester, List<Class>>> {},
      activities: <Grade, List<Activity>> {},
      volunteering: <Volunteer> [],
      unlockedAchievements: <String, List<EarnedAchievement>> {},
    );

    profileBox.put(profileName, newProfile);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create a profile"),
      content: SizedBox(
        width: 300,
        height: 100,
        child: Column(
          children: [
            TextField(
              onChanged: (value) => {
                setState(() {
                  profileName = ValidationHelper.validateItem(text: value);
                  profileNameErrorText =
                      ValidationHelper.validateItemErrorText(text: value);
                  _checkIfNameTaken(value);
                })
              },
              decoration: InputDecoration(
                labelText: "Profile Name",
                filled: true,
                hintText: "My Amazing Profile",
                errorText: profileNameErrorText,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "Discard"),
          child: const Text("Discard"),
        ),
        FilledButton(
          onPressed: (profileName == null) ? null : () {
            _addProfileToBox();
            Navigator.pop(context, "Create");
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}

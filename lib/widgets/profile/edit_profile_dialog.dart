import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditProfileDialog extends StatefulWidget {
  final String profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  var profileBox = Hive.box<Profile>("profiles");
  String? newProfileName;
  String? newProfileNameErrorText;

  void _checkIfNameTaken(name) {
    if (name == widget.profile) {
      newProfileNameErrorText =
          "Must be different than current name";
      newProfileName = null;
      return;
    }

    if (profileBox.keys.contains(name)) {
      newProfileNameErrorText = "Profile name is already taken";
      newProfileName = null;
    }
  }

  void _renameProfile() {
    var newProfileName = this.newProfileName;
    if (newProfileName == null) return; // shouldn't happen but just in case
    if (profileBox.get(newProfileName) != null) return;

    // Transfer profile data from one box to another and delete the old one
    Profile profile = profileBox.get(widget.profile)!;
    profileBox.put(newProfileName, profile);
    profileBox.delete(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    var profileName = widget.profile;

    return AlertDialog(
      title: Text("Edit \"$profileName\""),
      content: SizedBox(
        child: TextField(
          decoration: InputDecoration(
            labelText: "New Profile Name",
            filled: true,
            hintText: "My More Amazing Profile",
            errorText: newProfileNameErrorText,
          ),
          onChanged: (value) => {
            setState(() {
              newProfileName = ValidationHelper.validateItem(text: value);
              newProfileNameErrorText =
                  ValidationHelper.validateItemErrorText(text: value);
              _checkIfNameTaken(value);
            })
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "Discard"),
          child: const Text("Discard"),
        ),
        FilledButton(
          onPressed: (newProfileName == null)
              ? null
              : () {
                  _renameProfile();
                  Navigator.pop(context, "Save");
                },
          child: const Text("Save"),
        )
      ],
    );
  }
}

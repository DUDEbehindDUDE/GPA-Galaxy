import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/activity.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditDialog extends StatefulWidget {
  final String profile;
  const EditDialog({super.key, required this.profile});

  @override
  createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  var profileBox = Hive.box<Profile>("profiles");
  TextEditingController activityNameController =
      TextEditingController(text: null);
  TextEditingController activityHrWkController =
      TextEditingController(text: null);
  TextEditingController activityWkYrController =
      TextEditingController(text: null);
  Grade grade = Grade.freshman;
  Activity? selectedActivity;
  String? newActivityName;
  String? newActivityNameErrorText;
  double? newActivityHrWk;
  String? newActivityHrWkErrorText;
  int? newActivityWkYr;
  String? newActivityWkYrErrorText;

  /// Saves all the edits that you've changed, and closes the dialog
  void _saveEdits({delete = false}) {
    var box = Hive.box<Profile>("profiles");
    var profile = box.get(widget.profile)!;
    var selectedActivity = this.selectedActivity!;

    if (delete) {
      profile.activities[grade]!.remove(selectedActivity);
      box.put(widget.profile, profile);
      Navigator.pop(context, "delete");
      return;
    }

    for (var i = 0; i < profile.activities[grade]!.length; i++) {
      if (profile.activities[grade]![i] == selectedActivity) {
        profile.activities[grade]![i].name = newActivityName!;
        profile.activities[grade]![i].weeklyTime = newActivityHrWk!;
        profile.activities[grade]![i].totalWeeks = newActivityWkYr!;
        break;
      }
    }
    box.put(widget.profile, profile);
    Navigator.pop(context, "save");
  }

  /// Checks if the activity name is already in use, and if it is, invalidate item
  void _checkActivityNameTaken() {
    if (newActivityName == selectedActivity?.name) return;

    var profile = Hive.box<Profile>("profiles").get(widget.profile)!;
    for (var item in profile.activities[grade]!) {
      if (item.name == newActivityName) {
        setState(() {
          newActivityName = null;
          newActivityNameErrorText = "Activity name is already taken";
        });
      }
    }
  }

  /// Returns a list of dropdown entries of all the activities in the grade
  List<DropdownMenuEntry<Activity>> _getActivityDropdownEntries(
    Grade grade,
  ) {
    var activities = profileBox.get(widget.profile)!.activities[grade];
    activities ??= [];

    List<DropdownMenuEntry<Activity>> entries = [];
    for (var activity in activities) {
      entries.add(
          DropdownMenuEntry<Activity>(value: activity, label: activity.name));
    }

    return entries;
  }

  /// Returns a dropdown menu of all the activities in the selected grade
  DropdownMenu _getActivityDropdownMenu() {
    var entries = _getActivityDropdownEntries(grade);
    String? errorText;

    if (entries.isEmpty) {
      errorText = "No activities found";
    }

    return DropdownMenu<Activity>(
      // The key invalidates this widget regenerate when you select something else,
      // which prevents an activity from another grade from appearing selected
      key: Key("$grade"),
      enableFilter: true,
      enabled: errorText == null,
      requestFocusOnTap: true,
      leadingIcon: const Icon(Icons.search),
      // make the text red if it is error
      textStyle:
          errorText == null ? null : TextStyle(color: Colors.red.shade200),
      width: 265,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      dropdownMenuEntries: entries,
      errorText: errorText,
      helperText: "Activity",
      onSelected: (value) => setState(() {
        selectedActivity = value;
        if (value != null) {
          activityNameController.text = value.name;
          activityHrWkController.text = value.weeklyTime.toString();
          activityWkYrController.text = value.totalWeeks.toString();
          newActivityName = value.name;
          newActivityHrWk = value.weeklyTime;
          newActivityWkYr = value.totalWeeks;
        }
      }),
    );
  }

  /// Returns the fields to change activity stuff, but only if
  /// the user has selected a valid activity
  Widget? _getAdditionalItems() {
    var selectedActivity = this.selectedActivity;
    if (selectedActivity == null) return null;

    return Column(
      children: [
        TextField(
          controller: activityNameController,
          decoration: InputDecoration(
            errorText: newActivityNameErrorText,
            filled: true,
            labelText: "Rename activity",
          ),
          onChanged: (value) {
            setState(() {
              newActivityName = ValidationHelper.validateItem(text: value);
              newActivityNameErrorText =
                  ValidationHelper.validateItemErrorText(text: value);
              _checkActivityNameTaken();
            });
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 128,
              child: TextField(
                controller: activityHrWkController,
                decoration: InputDecoration(
                  errorText: newActivityHrWkErrorText,
                  filled: true,
                  labelText: "Hrs/wk",
                ),
                onChanged: (value) {
                  setState(() {
                    newActivityHrWk = ValidationHelper.validateItem(
                      text: value,
                      type: double,
                      min: 0,
                      max: 40,
                    );
                    newActivityHrWkErrorText = ValidationHelper.validateItemErrorText(
                      text: value,
                      type: double,
                      min: 0,
                      max: 40,
                      short: true,
                    );
                  });
                },
              ),
            ),
            SizedBox(
              width: 128,
              child: TextField(
                controller: activityWkYrController,
                decoration: InputDecoration(
                  errorText: newActivityWkYrErrorText,
                  filled: true,
                  labelText: "Total Wks",
                ),
                onChanged: (value) {
                  setState(() {
                    newActivityWkYr = ValidationHelper.validateItem(
                      text: value,
                      type: int,
                      min: 1,
                      max: 52,
                    );
                    newActivityWkYrErrorText = ValidationHelper.validateItemErrorText(
                      text: value,
                      type: int,
                      min: 1,
                      max: 52,
                      short: true,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit an activity"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 265,
          child: Column(
            children: [
              DropdownMenu(
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      grade = value;
                    });
                  }
                },
                width: 265,
                initialSelection: Grade.freshman,
                helperText: "Grade",
                hintText: "Select",
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: Grade.freshman,
                    label: "9th Grade",
                  ),
                  DropdownMenuEntry(
                    value: Grade.sophomore,
                    label: "10th Grade",
                  ),
                  DropdownMenuEntry(
                    value: Grade.junior,
                    label: "11th Grade",
                  ),
                  DropdownMenuEntry(
                    value: Grade.senior,
                    label: "12th Grade",
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _getActivityDropdownMenu(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _getAdditionalItems(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, "cancel"),
            child: const Text("Cancel")),
        TextButton(
            onPressed:
                selectedActivity != null ? () => _saveEdits(delete: true) : null,
            child: const Text("Delete")),
        FilledButton(
            onPressed: selectedActivity != null &&
                    newActivityName != null &&
                    newActivityHrWk != null &&
                    newActivityWkYr != null
                ? () => _saveEdits()
                : null,
            child: const Text("Save")),
      ],
    );
  }
}

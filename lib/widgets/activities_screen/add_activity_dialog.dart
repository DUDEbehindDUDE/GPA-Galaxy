import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/activity.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddActivityDialog extends StatefulWidget {
  final Grade grade;
  final String profile;

  const AddActivityDialog({
    super.key,
    required this.grade,
    required this.profile,
  });

  @override
  State<AddActivityDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddActivityDialog> {
  TextEditingController hrsPerWkController = TextEditingController(text: "");

  double? hrsPerWk;
  int? totalWeeks;
  String? activityName;
  String? dateStarted = "";

  String? hrsPerWkErrorText;
  String? totalWeeksErrorText;
  String? activityNameErrorText;
  String? dateStartedErrorText;

  var profileBox = Hive.box<Profile>("profiles");

  /// Checks if all the inputs are valid. If they are returns true; otherwise, returns false.
  bool _checkIfNull() {
    if (hrsPerWk == null) return true;
    if (totalWeeks == null) return true;
    if (activityName == null) return true;
    if (dateStarted == null) return true;
    return false;
  }

  /// Generates a random activity name, without any bias whatsoever.
  String _randomActivityName() {
    var activities = [
      "Volleyball",
      "Football",
      "Soccer",
      "Track",
      "Marching Band",
      "Battle of the Books",
      "Student Government",
      "FBLA", // this one is cool so we should make it come up more often
      "FBLA",
      "FBLA",
      "FBLA",
    ];

    return "e.g. ${activities[Random().nextInt(activities.length - 1)]}";
  }

  /// Logs the activity to the profile
  void _addItemToBox() {
    Profile newProfile = profileBox.get(widget.profile)!;

    if (newProfile.activities[widget.grade] == null) {
      newProfile.activities[widget.grade] = [];
    }

    newProfile.activities[widget.grade]!.add(Activity(
      name: activityName!,
      date: dateStarted!,
      weeklyTime: (hrsPerWk! * 10).roundToDouble() / 10,
      totalWeeks: totalWeeks!,
    ));

    profileBox.put(widget.profile, newProfile);
  }

  /// Checks to see of the activity name is already taken. If it is,
  /// invalidate field and set error text.
  void _checkIfNameTaken(name) {
    var activities = profileBox.get(widget.profile)!.activities[widget.grade];
    if (activities == null) return;
    for (var activity in activities) {
      if (activity.name == name) {
        activityName = null;
        activityNameErrorText = "Activity name already taken";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add an activity"),
      content: SizedBox(
        width: 300,
        height: 187,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  activityName = ValidationHelper.validateItem(text: value);
                  activityNameErrorText =
                      ValidationHelper.validateItemErrorText(text: value);
                  _checkIfNameTaken(value);
                });
              },
              decoration: InputDecoration(
                labelText: "Activity Name",
                errorText: activityNameErrorText,
                filled: true,
                hintText: _randomActivityName(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 3) {
                          value = value.substring(0, 3);
                          hrsPerWkController.text = value;
                        }
                        hrsPerWk = ValidationHelper.validateItem(
                          text: value,
                          type: double,
                          min: 0,
                          max: 40,
                        );
                        hrsPerWkErrorText =
                            ValidationHelper.validateItemErrorText(
                          text: value,
                          type: double,
                          min: 0,
                          max: 40,
                          short: true,
                        );
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Hrs/wk",
                      errorText: hrsPerWkErrorText,
                      filled: true,
                      hintText: "e.g. '4.5'",
                    ),
                    controller: hrsPerWkController,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 8.0)),
                Flexible(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        totalWeeks = ValidationHelper.validateItem(
                            text: value, type: int, min: 1, max: 52);
                        totalWeeksErrorText =
                            ValidationHelper.validateItemErrorText(
                          text: value,
                          type: int,
                          min: 1,
                          max: 52,
                          short: true,
                        );
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Total Wks",
                      errorText: totalWeeksErrorText,
                      filled: true,
                      hintText: "e.g. '12'",
                    ),
                  ),
                ),
              ],
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
          // Grey out this option if anything is invalid as per material 3 guidelines
          onPressed: _checkIfNull()
              ? null
              : () {
                  _addItemToBox();
                  Navigator.pop(context, "Create");
                },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test1/class/validation_helper.dart';
import 'package:flutter_test1/generics/type_adapters/activity.dart';
import 'package:flutter_test1/generics/type_adapters/grade.dart';
import 'package:flutter_test1/generics/type_adapters/profile.dart';
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
  double? hrsPerWk;
  int? totalWeeks;
  String? activityName;
  String? dateStarted = "";

  String? hrsPerWkErrorText;
  String? totalWeeksErrorText;
  String? activityNameErrorText;
  String? dateStartedErrorText;

  var profileBox = Hive.box<Profile>("profiles");

  void _validateInput() {
    setState(() {
      hrsPerWkErrorText ??=
          ValidationHelper.validateItemErrorText(text: hrsPerWk.toString(), type: double, min: 0, max: 40);
      totalWeeksErrorText ??=
          ValidationHelper.validateItemErrorText(text: totalWeeks.toString(), type: int, min: 1, max: 52);
      activityNameErrorText ??=
          ValidationHelper.validateItemErrorText(text: activityName);
      dateStartedErrorText ??=
          ValidationHelper.validateItemErrorText(text: dateStarted);
    });
  }

  bool _checkIfNull() {
    if (hrsPerWk == null) return true;
    if (totalWeeks == null) return true;
    if (activityName == null) return true;
    if (dateStarted == null) return true;
    return false;
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add an Activity"),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  activityName = ValidationHelper.validateItem(text: value);
                  activityNameErrorText =
                      ValidationHelper.validateItemErrorText(text: value);
                });
              },
              decoration: InputDecoration(
                labelText: "Activity Name",
                errorText: activityNameErrorText,
                filled: true,
                hintText: _randomActivityName(),
              ),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        hrsPerWk = ValidationHelper.validateItem(
                            text: value, type: double, min: 0, max: 40);
                        hrsPerWkErrorText =
                            ValidationHelper.validateItemErrorText(
                                text: value, type: double, min: 0, max: 40);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Hrs/wk",
                      errorText: hrsPerWkErrorText,
                      filled: true,
                      hintText: "e.g. '4'",
                    ),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        totalWeeks = ValidationHelper.validateItem(
                            text: value, type: int, min: 1, max: 52);
                        totalWeeksErrorText =
                            ValidationHelper.validateItemErrorText(
                                text: value, type: int, min: 1, max: 52);
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
        TextButton(
          onPressed: () {
            if (_checkIfNull()) {
              _validateInput();
              return;
            }
            _addItemToBox();
            Navigator.pop(context, "Create");
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

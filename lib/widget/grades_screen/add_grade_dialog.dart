import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddGradeDialog extends StatefulWidget {
  final Grade grade;
  final String profile;

  const AddGradeDialog({
    super.key,
    required this.grade,
    required this.profile,
  });

  @override
  State<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {
  int? grade;
  String? className;
  double classWeight = 0.0;
  Semester semester = Semester.s1;

  String? classNameErrorText;
  String? gradeErrorText;

  var profileBox = Hive.box<Profile>("profiles");

  String _randomClassName() {
    const classes = [
      "Biology",
      "Physics",
      "Chemistry",
      "Civics",
      "World History",
      "Calculus",
    ];

    return "e.g. ${classes[Random().nextInt(classes.length - 1)]}";
  }

  /// Checks if there is already a class with the same name present in the semester
  void _checkIfNameTaken() {
    var name = className;
    if (name == null) return;

    var classesInSemester = Util.getClassesInSemester(profileBox.get(widget.profile)!, widget.grade, semester);
    for (var item in classesInSemester) {
      if (item.className == name) {
        classNameErrorText = "Class name is already taken in semester";
        return;
      }
    }
    if (classNameErrorText == "Class name is already taken in semester") {
      classNameErrorText = null;
    }
  }

  /// If we can infer from [text] that it's an AP or Honors class, this sets the weight to be that
  void _autofillClassWeight(String? text) {
    if (text == null) return;
    text = text.toLowerCase();

    if (text.contains("ap") || text.contains("ib")) {
      classWeight = 1.0;
      return;
    }

    if (text.contains("honors")) {
      classWeight = 0.5;
      return;
    }
  }

  void _addItem() {
    Profile newProfile = profileBox.get(widget.profile)!;
    Class item =
        Class(className: className!, classWeight: classWeight, grade: grade!);

    if (newProfile.academics[widget.grade] == null) {
      newProfile.academics[widget.grade] = {}; // Initialize empty map
    }
    if (newProfile.academics[widget.grade]?[semester] == null) {
      newProfile.academics[widget.grade]
          ?[semester] = []; // Initialize empty list
    }

    newProfile.academics[widget.grade]?[semester]?.add(item);
    profileBox.put(widget.profile, newProfile);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add a class"),
      content: SizedBox(
        width: 300,
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                onChanged: (value) => setState(() {
                  className = ValidationHelper.validateItem(text: value);
                  classNameErrorText =
                      ValidationHelper.validateItemErrorText(text: value);
                  _checkIfNameTaken();
                  _autofillClassWeight(value);
                }),
                decoration: InputDecoration(
                  labelText: "Class Name",
                  errorText: classNameErrorText,
                  filled: true,
                  hintText: _randomClassName(),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4)),
              Center(
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: 0.0,
                      label: Text("Regular"),
                    ),
                    ButtonSegment(
                      value: 0.5,
                      label: Text("Honors"),
                    ),
                    ButtonSegment(
                      value: 1.0,
                      label: Text("AP/IB"),
                    ),
                  ],
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: MaterialStatePropertyAll(
                      TextStyle(fontSize: 12),
                    ),
                  ),
                  selected: <double>{classWeight},
                  onSelectionChanged: (selection) => setState(() {
                    classWeight = selection.first;
                  }),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4)),
              Center(
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: Semester.s1,
                      label: Text("Semester 1"),
                    ),
                    ButtonSegment(
                      value: Semester.s2,
                      label: Text("Semester 2"),
                    ),
                  ],
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: MaterialStatePropertyAll(
                      TextStyle(fontSize: 12),
                    ),
                  ),
                  selected: <Semester>{semester},
                  onSelectionChanged: (selection) => setState(() {
                    semester = selection.first;
                    _checkIfNameTaken();
                  }),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              TextField(
                onChanged: (value) => {
                  setState(() {
                    grade = ValidationHelper.validateItem(text: value, min: 0, max: 100, type: int);
                    gradeErrorText = ValidationHelper.validateItemErrorText(text: value, min: 0, max: 100, type: int);
                  })
                },
                decoration: InputDecoration(
                  labelText: "Grade",
                  filled: true,
                  errorText: gradeErrorText,
                  hintText: "e.g. '91'",
                ),
              ),
              // extra padding on the bottom so it doesn't look as weird to scroll
              const Padding(padding: EdgeInsets.all(20)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "Discard"),
          child: const Text("Discard"),
        ),
        FilledButton(
          // grey out this option if things are invalid as per material 3 guidelines
          onPressed: (className == null || grade == null || classNameErrorText != null)
              ? null
              : () {
                  _addItem();
                  Navigator.pop(context, "Create");
                },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

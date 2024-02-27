import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test1/generics/type_adapters/semester.dart';
import 'package:flutter_test1/generics/type_adapters/class.dart';
import 'package:flutter_test1/generics/type_adapters/grade.dart';
import 'package:flutter_test1/generics/type_adapters/profile.dart';
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

  void _validateInput(String? value, String field) {
    if (value == null || value.toString().isEmpty) {
      _setInput("Field cannot be empty", "${field}ErrorText");
      _setInput(null, field);
      return;
    }
    if (value.length > 50) {
      _setInput("Field exceeds character limit (${value.length}/50)",
          "${field}ErrorText");
      _setInput(null, field);
      return;
    }
    if (field == "grade") {
      int? number = int.tryParse(value);
      if (number == null) {
        _setInput(
            "Field must be a number between 0 and 100", "${field}ErrorText");
        _setInput(null, field);
        return;
      }

      if (number > 100 || number < 0) {
        _setInput(
            "Field must be a number between 0 and 100", "${field}ErrorText");
        _setInput(null, field);
        return;
      }

      _setInput(null, "${field}ErrorText");
      _setInput(number, field);
      return;
    }
    if (field == "className") {
      var lowerValue = value.toLowerCase();
      if (lowerValue.contains("honors")) {
        classWeight = 0.5;
      }
      if (lowerValue.contains("ap") || lowerValue.contains("ib")) {
        classWeight = 1.0;
      }
    }
    _setInput(null, "${field}ErrorText");
    _setInput(value, field);
  }

  void _setInput(input, field) {
    setState(() {
      switch (field) {
        case "grade":
          grade = input;
          break;
        case "gradeErrorText":
          gradeErrorText = input;
          break;
        case "className":
          className = input;
          break;
        case "classNameErrorText":
          classNameErrorText = input;
          break;
      }
    });
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
                onChanged: (value) => _validateInput(value, "className"),
                decoration: InputDecoration(
                  labelText: "Class Name",
                  errorText: classNameErrorText,
                  filled: true,
                  hintText: _randomClassName(),
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
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
                  }),
                ),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              TextField(
                onChanged: (value) => _validateInput(value, "grade"),
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
          onPressed: (className == null || grade == null)
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

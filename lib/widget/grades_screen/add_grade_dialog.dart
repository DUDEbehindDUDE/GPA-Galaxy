import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test1/class/database_helper.dart';

class AddGradeDialog extends StatefulWidget {
  final String screen;
  final String grade;

  const AddGradeDialog({super.key, required this.grade, required this.screen});

  @override
  State<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {

  int? grade;
  String? className;
  double classWeight = 0.0;

  String? classNameErrorText;
  String? gradeErrorText;

  late DatabaseHelper gradeDatabaseHelper;
  Future<void> getDatabaseHelper() async {
    gradeDatabaseHelper = await DatabaseHelper.create(widget.screen);
  }

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

  void _validateInput(String? value, String field) {
    if (value == null || value.toString().isEmpty) {
      _setInput("Field cannot be empty", "${field}ErrorText");
      _setInput(null, field);
      return;
    }
    if (value.length > 50) {
      _setInput("Field exceeds character limit (${value.length}/50)", "${field}ErrorText");
      _setInput(null, field);
      return;
    }
    if (field == "grade") {
      int number;
      try {
        number = int.parse(value);
      } catch (e) {
        _setInput("Field must be a number between 0 and 100", "${field}ErrorText");
        _setInput(null, field);
        return;
      }
      
      if (number > 100 || number < 0) {
        _setInput("Field must be a number between 0 and 100", "${field}ErrorText");
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
    getDatabaseHelper();
    
    return AlertDialog(
      title: const Text("Add a class"),
      content: SizedBox(
        width: 300,
        height: 300,
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
            if (className == null || grade == null) {
              _validateInput(className, "className");
              _validateInput(grade.toString(), "grade");
              return;
            }
            gradeDatabaseHelper.addItem(widget.grade, [className, grade.toString(), classWeight]);
            Navigator.pop(context, "Create");
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
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
  TextEditingController classNameController = TextEditingController(text: null);
  TextEditingController classGradeController =
      TextEditingController(text: null);
  Grade grade = Grade.freshman;
  Semester semester = Semester.s1;
  Class? classItem;
  String? newClassName;
  String? newClassNameErrorText;
  int? newClassGrade;
  String? newClassGradeErrorText;
  double newClassWeight = 0.0;

  /// Saves all the edits that you've changed, and closes the dialog
  void _saveEdits({delete = false}) {
    var box = Hive.box<Profile>("profiles");
    var profile = box.get(widget.profile)!;
    var classItem = this.classItem!;

    if (delete) {
      profile.academics[grade]![semester]!.remove(classItem);
      box.put(widget.profile, profile);
      Navigator.pop(context, "delete");
      return;
    }

    for (var i = 0; i < profile.academics[grade]![semester]!.length; i++) {
      if (profile.academics[grade]![semester]![i] == classItem) {
        profile.academics[grade]![semester]![i].className = newClassName!;
        profile.academics[grade]![semester]![i].grade = newClassGrade!;
        profile.academics[grade]![semester]![i].classWeight = newClassWeight;
        break;
      }
    }
    box.put(widget.profile, profile);
    Navigator.pop(context, "save");
  }

  /// Checks if the class name is already in use, and if it is, invalidate item
  void _checkClassNameTaken() {
    if (newClassName == classItem?.className) return;

    var profile = Hive.box<Profile>("profiles").get(widget.profile)!;
    for (var item in profile.academics[grade]![semester]!) {
      if (item.className == newClassName) {
        setState(() {
          newClassName = null;
          newClassNameErrorText = "Class name is already taken";
        });
      }
    }
  }

  /// Returns a list of dropdown entries of all the classes in the grade and semester
  List<DropdownMenuEntry<Class>> _getClassDropdownEntries(
    Grade grade,
    Semester semester,
  ) {
    var classes = Util.getClassesInSemester(
      profileBox.get(widget.profile)!,
      grade,
      semester,
    );

    List<DropdownMenuEntry<Class>> entries = [];
    for (var item in classes) {
      entries.add(DropdownMenuEntry<Class>(value: item, label: item.className));
    }

    return entries;
  }

  /// Returns a dropdown menu of all the classes in the selected grade and semester
  DropdownMenu _getClassDropdownMenu(double availableWidth) {
    var entries = _getClassDropdownEntries(grade, semester);
    String? errorText;

    if (entries.isEmpty) {
      errorText = "No classes found";
    }

    return DropdownMenu<Class>(
      // The key invalidates this widget regenerate when you select something else,
      // which prevents a class from another grade/semester from appearing selected
      key: Key("$grade$semester"),
      enableFilter: true,
      enabled: errorText == null,
      requestFocusOnTap: true,
      leadingIcon: const Icon(Icons.search),
      // make the text red if it is error
      textStyle:
          errorText == null ? null : TextStyle(color: Colors.red.shade200),
      width: availableWidth,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      dropdownMenuEntries: entries,
      errorText: errorText,
      helperText: "Class",
      onSelected: (value) => setState(() {
        classItem = value;
        if (value != null) {
          classNameController.text = value.className;
          classGradeController.text = value.grade.toString();
          newClassGrade = value.grade;
          newClassName = value.className;
          newClassWeight = value.classWeight;
        }
      }),
    );
  }

  /// If we can infer from [text] that it's an AP or Honors class, this sets the weight to be that
  void _autofillClassWeight(String? text) {
    if (text == null) return;
    text = text.toLowerCase();

    if (text.contains("ap") || text.contains("ib")) {
      newClassWeight = 1.0;
      return;
    }

    if (text.contains("honors")) {
      newClassWeight = 0.5;
      return;
    }
  }

  /// Returns the fields to change your class name and grade, but only if
  /// the user has selected a valid class
  Widget? _getAdditionalItems() {
    var classItem = this.classItem;
    if (classItem == null) return null;

    return Column(
      children: [
        TextField(
          controller: classNameController,
          decoration: InputDecoration(
            errorText: newClassNameErrorText,
            filled: true,
            labelText: "Rename Class",
          ),
          onChanged: (value) {
            setState(() {
              newClassName = ValidationHelper.validateItem(text: value);
              newClassNameErrorText =
                  ValidationHelper.validateItemErrorText(text: value);
              _checkClassNameTaken();
              _autofillClassWeight(value);
            });
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            showSelectedIcon: false,
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
            selected: <double>{newClassWeight},
            onSelectionChanged: (selection) => setState(() {
              newClassWeight = selection.first;
            }),
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 16)),
        TextField(
          controller: classGradeController,
          decoration: InputDecoration(
            errorText: newClassGradeErrorText,
            filled: true,
            labelText: "Grade",
          ),
          onChanged: (value) {
            setState(() {
              newClassGrade = ValidationHelper.validateItem(
                text: value,
                type: int,
                min: 0,
                max: 100,
              );
              newClassGradeErrorText = ValidationHelper.validateItemErrorText(
                text: value,
                type: int,
                min: 0,
                max: 100,
              );
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double availableWidth =
        min(MediaQuery.of(context).size.width - 128, 300);
    return AlertDialog(
      title: const Text("Edit a class"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: availableWidth,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu(
                    width: availableWidth * 0.6,
                    onSelected: (value) {
                      if (value != grade) {
                        setState(() {
                          classItem = null;
                        });
                      }
                      if (value != null) {
                        setState(() {
                          grade = value;
                        });
                      }
                    },
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
                  DropdownMenu(
                    width: availableWidth * 0.4 - 8,
                    onSelected: (value) {
                      if (value != semester) {
                        setState(() {
                          classItem = null;
                        });
                      }
                      if (value != null) {
                        setState(() {
                          semester = value;
                        });
                      }
                    },
                    initialSelection: Semester.s1,
                    helperText: "Semester",
                    hintText: "Select",
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: Semester.s1,
                        label: "S1",
                      ),
                      DropdownMenuEntry(
                        value: Semester.s2,
                        label: "S2",
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _getClassDropdownMenu(availableWidth),
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
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, "cancel"),
              child: const Text("Cancel"),
            ),
            const Spacer(),
            TextButton(
              onPressed:
                  classItem != null ? () => _saveEdits(delete: true) : null,
              child: const Text("Delete"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilledButton(
                onPressed: classItem != null &&
                        newClassName != null &&
                        newClassGrade != null
                    ? () => _saveEdits()
                    : null,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

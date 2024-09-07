import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/date_helper.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditDialog extends StatefulWidget {
  final String profile;
  final int year;
  final List<Volunteer> items;
  const EditDialog(
      {super.key,
      required this.profile,
      required this.year,
      required this.items});

  @override
  createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  var profileBox = Hive.box<Profile>("profiles");
  FocusNode dateFocusNode = FocusNode();
  TextEditingController volunteerNameController =
      TextEditingController(text: null);
  TextEditingController dateController = TextEditingController(text: null);
  bool dateFieldEditing = false;

  int? selectedIndex;
  String? newVolunteerName;
  String? newVolunteerNameErrorText;
  double? newHoursLogged;
  String? newHoursLoggedErrorText;
  DateTime? newDate;
  String? newDateErrorText;

  /// Saves all the edits that you've changed, and closes the dialog
  void _saveEdits({delete = false}) {
    String navAction = "delete";
    var box = Hive.box<Profile>("profiles");
    var profile = box.get(widget.profile)!;
    var selected = selectedIndex;
    var name = newVolunteerName;
    var date = newDate;
    var hours = newHoursLogged;

    if (selected == null || name == null || date == null || hours == null) {
      return;
    }

    for (int i = 0; i < profile.volunteering.length; i++) {
      if (profile.volunteering[i] == widget.items[selected]) {
        profile.volunteering.removeAt(i);
        break;
      }
    }

    if (!delete) {
      profile.volunteering.add(Volunteer(name: name, date: date, hours: hours));
      navAction = "save";
    }

    box.put(widget.profile, profile);
    Navigator.pop(context, navAction);
  }

  /// Returns a list of dropdown entries of all the items logged in the year
  List<DropdownMenuEntry<int>> _getVolunteerDropdownEntries() {
    List<DropdownMenuEntry<int>> entries = [];
    for (int i = 0; i < widget.items.length; i++) {
      var item = widget.items[i];
      entries.add(DropdownMenuEntry<int>(
          value: i, label: "${item.date.month}/${item.date.day} ${item.name}"));
    }

    return entries;
  }

  /// Returns a dropdown menu of all the classes in the selected grade and semester
  DropdownMenu _getVolunteerDropdownMenu(double availableWidth) {
    var entries = _getVolunteerDropdownEntries();
    String? errorText;

    return DropdownMenu<int>(
      // The key invalidates this widget regenerate when you select something else,
      // in case the option is added later to be able to change years
      key: Key("${widget.year}"),
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
      helperText: "Volunteer Item",
      onSelected: (index) => setState(() {
        selectedIndex = index;
        if (index != null) {
          var volunteer = widget.items[index];
          volunteerNameController.text = volunteer.name;
          dateController.text = DateHelper.formatMmmmDYyyy(volunteer.date);
          newVolunteerName = volunteer.name;
          newDate = volunteer.date;
          newHoursLogged = volunteer.hours;
        }
      }),
    );
  }

  /// Returns the editable fields but only if a valid item is selected
  Widget? _getAdditionalItems() {
    var selectedIndex = this.selectedIndex;
    if (selectedIndex == null) return null;

    return Column(
      children: [
        TextField(
          controller: volunteerNameController,
          decoration: InputDecoration(
            errorText: newVolunteerNameErrorText,
            filled: true,
            labelText: "Rename Volunteer Activity",
          ),
          onChanged: (value) {
            setState(() {
              newVolunteerName = ValidationHelper.validateItem(text: value);
              newVolunteerNameErrorText =
                  ValidationHelper.validateItemErrorText(text: value);
            });
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 16)),
        TextField(
          controller: dateController,
          decoration: InputDecoration(
            errorText: newDateErrorText,
            filled: true,
            labelText: "Date",
            hintText: "MM-DD-YYYY",
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _pickDate,
              color: Colors.grey.shade300,
            ),
          ),
          onTap: _onDateFieldTap,
          focusNode: dateFocusNode,
        ),
      ],
    );
  }

  /// Converts the text to the user-editable version
  /// e.g. "December 25, 2020" -> "12-25-2020"
  void _onDateFieldTap() {
    // Break if user is currently editing this field
    if (newDateErrorText != null) return;
    if (dateFieldEditing) return;

    setState(() {
      dateFieldEditing = true;
      dateController.text = DateHelper.formatMDYyyy(newDate!, leading: true);
    });
  }

  /// Checks if the input date is valid, and if it is sets new date to it
  void _checkDateValid(String str) {
    if (str.isEmpty) {
      setState(() {
        newDateErrorText = "Date cannot be left empty";
      });
      return;
    }
    str = str.replaceAll("/", "-");
    var splitStr = str.split("-");
    if (splitStr.length != 3) {
      _invalidateDate();
      return;
    }

    var dateSplitStr = [splitStr[2], splitStr[0], splitStr[1]];
    var date = DateTime.tryParse(dateSplitStr.join("-"));
    if (date == null) {
      _invalidateDate();
      return;
    }
    if (date.isBefore(
      // the +1 here is because for some reason date picker thinks +1 is within range
      DateTime.now().subtract(const Duration(days: 365 * 10 + 1)),
    )) {
      setState(() {
        newDateErrorText = "Date can't be more than 10 years ago";
      });
      return;
    }
    if (date.isAfter(DateTime.now())) {
      setState(() {
        newDateErrorText = "Date can't be in the future";
      });
      return;
    }

    setState(() {
      newDate = date;
      newDateErrorText = null;
    });
  }

  /// Adds error text to date picker
  void _invalidateDate() {
    setState(() {
      newDateErrorText = "Date must be in MM-DD-YYYY format";
    });
  }

  /// Opens the DatePicker, and when the user selects a date, updates date
  void _pickDate() async {
    var newDate = await showDatePicker(
      context: context,
      // Keep the user from being able to input a date earlier than 10 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      // User does not have a time machine
      lastDate: DateTime.now(),
      initialDate: this.newDate,
    );
    if (newDate == null) return;

    setState(() {
      this.newDate = newDate;
      newDateErrorText = null;
      if (dateFieldEditing) {
        dateController.text = DateHelper.formatMDYyyy(newDate, leading: true)
            .replaceAll("/", "-");
      } else {
        dateController.text = DateHelper.formatMmmmDYyyy(newDate);
      }
    });
  }

  /// Triggers when user deselects the date text field
  _dateFocusListener() {
    if (dateFocusNode.hasFocus) return;
    _checkDateValid(dateController.text);
    var newDate = this.newDate;

    if (newDateErrorText == null && newDate != null) {
      setState(() {
        dateFieldEditing = false;
        dateController.text = DateHelper.formatMmmmDYyyy(newDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dateFocusNode.addListener(_dateFocusListener);
  }

  @override
  void dispose() {
    dateFocusNode.removeListener(_dateFocusListener);
    dateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double availableWidth =
        min(MediaQuery.of(context).size.width - 128, 300);
    return AlertDialog(
      title: const Text("Edit a Volunteer Activity"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: availableWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _getVolunteerDropdownMenu(availableWidth),
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
                  selectedIndex != null ? () => _saveEdits(delete: true) : null,
              child: const Text("Delete"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilledButton(
                onPressed: selectedIndex != null &&
                        newVolunteerName != null &&
                        newHoursLogged != null &&
                        newDate != null
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

import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/class/validation_helper.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddVolunteerDialog extends StatefulWidget {
  final String profile;

  const AddVolunteerDialog({super.key, required this.profile});

  @override
  createState() => _AddVolunteerDialogState();
}

class _AddVolunteerDialogState extends State<AddVolunteerDialog> {
  FocusNode dateFocusNode = FocusNode();
  TextEditingController hoursController = TextEditingController(text: "");
  late TextEditingController dateController;
  DateTime date = DateTime.now();
  bool dateFieldEditing = false;
  String? dateErrorText;
  String? activityName;
  String? activityNameErrorText;
  double? hours;
  String? hoursErrorText;

  _AddVolunteerDialogState() {
    dateController = TextEditingController(text: _formatDateText());
  }

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  /// Adds the item to the database
  void _addToDatabase() {
    var profileBox = Hive.box<Profile>("profiles");
    var profile = profileBox.get(widget.profile)!;
    profile.volunteering
        .add(Volunteer(name: activityName!, date: date, hours: hours!));
    profileBox.put(widget.profile, profile);
    Navigator.pop(context, "log");
  }

  /// Converts the text to the user-editable version
  /// e.g. "December 25, 2020" -> "12-25-2020"
  void _onDateFieldTap() {
    // Break if user is currently editing this field
    if (dateErrorText != null) return;
    if (dateFieldEditing) return;

    setState(() {
      dateFieldEditing = true;
      dateController.text =
          Util.renderDateMDYyyy(date, leadingZero: true).replaceAll("/", "-");
    });
  }

  /// Converts the text into a more "formal" format. Basically, I mean it turns
  /// "12-25-2020" -> "December 25, 2020". This gives the user feedback that the
  /// date they input was indeed valid. (returns the formatted text)
  String _formatDateText() {
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// Checks if the input date is valid, and if it is sets new date to it
  void _checkDateValid(String str) {
    if (str.isEmpty) {
      setState(() {
        dateErrorText = "Date cannot be left empty";
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
        dateErrorText = "Date can't be more than 10 years ago";
      });
      return;
    }
    if (date.isAfter(DateTime.now())) {
      setState(() {
        dateErrorText = "Date can't be in the future";
      });
      return;
    }

    setState(() {
      this.date = date;
      dateErrorText = null;
    });
  }

  /// Adds error text to date picker
  void _invalidateDate() {
    setState(() {
      dateErrorText = "Date must be in MM-DD-YYYY format";
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
      initialDate: date,
    );
    if (newDate == null) return;

    setState(() {
      date = newDate;
      dateErrorText = null;
      if (dateFieldEditing) {
        dateController.text = Util.renderDateMDYyyy(newDate, leadingZero: true)
            .replaceAll("/", "-");
      } else {
        dateController.text = _formatDateText();
      }
    });
  }

  /// Triggers when user deselects the date text field
  _dateFocusListener() {
    if (dateFocusNode.hasFocus) return;
    _checkDateValid(dateController.text);

    if (dateErrorText == null) {
      setState(() {
        dateFieldEditing = false;
        dateController.text = _formatDateText();
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
    return AlertDialog(
      title: const Text("Log new volunteer activity"),
      content: SizedBox(
        width: 300,
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Volunteer Activity Name",
                  errorText: activityNameErrorText,
                  filled: true,
                  hintText: "Cool volunteer activity",
                ),
                onChanged: (value) {
                  setState(() {
                    activityName = ValidationHelper.validateItem(text: value);
                    activityNameErrorText =
                        ValidationHelper.validateItemErrorText(text: value);
                  });
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 16.0)),
              TextField(
                controller: hoursController,
                decoration: InputDecoration(
                    labelText: "Hours Spent",
                    errorText: hoursErrorText,
                    filled: true,
                    hintText: "e.g. '1.5'"),
                onChanged: (value) {
                  setState(() {
                    if (value.length > 3) {
                      value = value.substring(0,3);
                      hoursController.text = value;
                    }
                    hours = ValidationHelper.validateItem(
                      text: value,
                      type: double,
                      min: 0,
                      max: 24,
                    );
                    hoursErrorText = ValidationHelper.validateItemErrorText(
                      text: value,
                      type: double,
                      min: 0,
                      max: 24,
                    );
                  });
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 16.0)),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                    labelText: "Date",
                    errorText: dateErrorText,
                    filled: true,
                    hintText: "MM-DD-YYYY",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickDate,
                      color: Colors.grey.shade300,
                    )),
                onTap: () => _onDateFieldTap(),
                focusNode: dateFocusNode,
              ),
              const Padding(padding: EdgeInsets.only(top: 16.0)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "discard"),
          child: const Text("Discard"),
        ),
        FilledButton(
          onPressed:
              activityName == null || hours == null || dateErrorText != null
                  ? null
                  : () => _addToDatabase(),
          child: const Text("Log"),
        ),
      ],
    );
  }
}

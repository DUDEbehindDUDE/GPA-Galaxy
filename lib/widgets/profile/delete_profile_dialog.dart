import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeleteProfileDialog extends StatelessWidget {
  final String profile;

  const DeleteProfileDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Profile"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          style: ButtonStyle(
            backgroundColor:
                WidgetStateColor.resolveWith((states) => Colors.red.shade300),
            foregroundColor: WidgetStateColor.resolveWith(
                (states) => const Color.fromARGB(255, 73, 20, 20)),
          ),
          onPressed: () {
            Hive.box<Profile>("profiles").delete(profile);
            Navigator.pop(context);
          },
          child: const Text("Delete"),
        ),
      ],
      content: const Text(
          "This action is irreversible. Are you sure you want to do this?"),
    );
  }
}

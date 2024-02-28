import 'package:flutter/material.dart';
import 'package:gpa_galaxy/widget/info/info_index.dart';
import 'package:gpa_galaxy/widget/profile/profile_select_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => InfoIndex()),
          ),
          icon: const Icon(Icons.info_outlined),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 120),
              child: Text(
                "Welcome to GPA Galaxy!",
                style: TextStyle(fontSize: 48),
                textAlign: TextAlign.center,
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const ProfileSelectScreen(),
                  ),
                );
              },
              child: const Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}

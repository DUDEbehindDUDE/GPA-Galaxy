import 'package:flutter/material.dart';
import 'package:gpa_galaxy/widgets/info/info_screen.dart';
import 'package:gpa_galaxy/widgets/profile/profile_select_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/galaxy2.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => InfoScreen()),
              ),
              icon: const Icon(Icons.info_outlined),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to",
                        style: TextStyle(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "GPA Galaxy!",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
        ],
      ),
    );
  }
}

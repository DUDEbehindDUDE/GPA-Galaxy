import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/activity.dart';
import 'package:gpa_galaxy/generics/type_adapters/class.dart';
import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:gpa_galaxy/widget/welcome_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // register hive stuff
  await Hive.initFlutter();
  Hive.registerAdapter(ClassAdapter());
  Hive.registerAdapter(ActivityAdapter());
  Hive.registerAdapter(VolunteerAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(SemesterAdapter());
  Hive.registerAdapter(GradeAdapter());
  Hive.registerAdapter(EarnedAchievementAdapter());
  // open boxes
  await Hive.openBox("appConfig");
  await Hive.openBox<Profile>("profiles");

  runApp(const GPAGalaxy());
}

class GPAGalaxy extends StatefulWidget {
  const GPAGalaxy({super.key});

  @override
  State<GPAGalaxy> createState() => _GPAGalaxyState();
}

class _GPAGalaxyState extends State<GPAGalaxy> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPA Galaxy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 16, 0, 22),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

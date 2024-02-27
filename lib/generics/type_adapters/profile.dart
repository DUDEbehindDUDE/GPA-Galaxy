import 'package:hive_flutter/hive_flutter.dart';

import 'activity.dart';
import 'class.dart';
import 'grade.dart';
import 'semester.dart';
import 'volunteer.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  Map<Grade, Map<Semester, List<Class>>> academics;
  
  @HiveField(1)
  Map<Grade, List<Activity>> activities;
  
  @HiveField(2)
  Map<Grade, List<Volunteer>> volunteering;
  
  @HiveField(3)
  List<String> unlockedAchievements;

  Profile({
    required this.academics,
    required this.activities,
    required this.volunteering,
    required this.unlockedAchievements,
  });
}

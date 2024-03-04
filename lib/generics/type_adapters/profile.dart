import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
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
  List<Volunteer> volunteering;
  
  @HiveField(3)
  Map<String, List<EarnedAchievement>> unlockedAchievements;

  Profile({
    required this.academics,
    required this.activities,
    required this.volunteering,
    required this.unlockedAchievements,
  });
}

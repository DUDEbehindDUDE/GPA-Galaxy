import 'package:flutter_test1/class/database_helper.dart';
import 'package:flutter_test1/generics/achievements.dart';

class AchievementHelper {
  Future<AchievementHelper> create() async {
    achievementDatabaseHelper = await DatabaseHelper.create("achievements");
    var component = AchievementHelper._create();
    return component;
  }

  AchievementHelper._create();

  late final DatabaseHelper achievementDatabaseHelper;


  void getNewAchievements() {
    Achievements(name: "hello", desc: "desc", dependent: "variable", requirements: []);
  }

  
}
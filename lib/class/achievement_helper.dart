import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/achievements.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';

class AchievementHelper {
  static Future<Map<String, List<Achievements>>> loadJson() async {
    var data = await rootBundle.loadString(
      'assets/data/achievements.json',
      cache: true,
    );
    var jsonMap = await jsonDecode(data);

    // parse json object and convert it to what we want
    Map<String, List<Achievements>> achievementMap = {};
    jsonMap.forEach((category, achievementsJson) {
      List<Achievements> achievementsList = [];
      achievementsJson.forEach((achievementJson) {
        // Convert the achievement JSON object into an Achievements object
        Achievements achievement = Achievements(
          name: achievementJson['name'],
          desc: achievementJson['description'],
          upgradable: achievementJson['upgradable'],
          additionalDesc: achievementJson['additionalDescriptions'] != null
              ? List<String>.from(achievementJson['additionalDescriptions'])
              : null,
          dependent: achievementJson['dependent'],
          levelCap: achievementJson['levelCap'],
          levelStart: achievementJson['levelStart'],
          requirements: List<int>.from(achievementJson['levelRequirements']),
        );

        // Add the achievement to the list for the current category
        achievementsList.add(achievement);
      });

      // Add the list of achievements to the map, keyed by category
      achievementMap[category] = achievementsList;
    });

    return achievementMap;
  }

  // how many classes are >= the grade in the profile
  static int howManyAboveGrade(int grade, Profile profile) {
    var classes = Util.getAllClasses(profile);
    int amount = 0;

    // love how you can't name a variable class :P
    for (var item in classes) {
      if (item.grade >= grade) amount++;
    }

    return amount;
  }

  static int howManySemestersLogged(Profile profile) {
    var classes = Util.getAllClasses(profile);
    // return -1 if you wouldn't have the achievement, 0 if you would get level 0
    if (classes.isEmpty) return -1;
    if (classes.length == 1) return 0;

    // count how many semesters have been fully logged
    int amount = 0;
    for (var grade in Grade.values) {
      for (var semester in Semester.values) {
        if (Util.getClassesInSemester(profile, grade, semester).length < 4) {
          return amount;
        }
        amount++;
      }
    }
    return amount;
  }

  static num getAchievementVariable(String name, Profile profile) {
    // gets the variable associated with the dependent in the json
    return switch (name) {
      "aAmount" => howManyAboveGrade(90, profile),
      "bAmount" => howManyAboveGrade(80, profile),
      "semesterHasFourClasses" => howManySemestersLogged(profile),
      _ => throw ("Variable $name not valid!")
    };
  }

  static void getNewAchievements(
    Profile profile,
    BuildContext ctx,
    Function(int) goToScreen,
  ) async {
    // get the list of all achievements
    Map<String, List<Achievements>> allAchievements = await loadJson();

    // check if BuildContext is still valid since there is an async above
    if (!ctx.mounted) {
      return;
    }

    // Calculate all the achievements
    Map<String, Map<String, int>> newAchievements = {};
    allAchievements.forEach((category, achievements) {
      for (var achievement in achievements) {
        num dependentValue =
            getAchievementVariable(achievement.dependent, profile);

        int level = 0;
        for (int item in achievement.requirements) {
          if (item > dependentValue) break;
          level++;
        }
        // if level is less than 1, the achievement hasn't been earned
        if (level == 0) continue;

        // add level start
        level += achievement.levelStart - 1;

        // add achievement to map
        newAchievements[category] ??= {}; // initialize if null
        newAchievements[category]![achievement.name] = level;

        // display snackbar for new achievements
        int? snackbarLevel = achievement.upgradable ? level : null;
        showSnackbar(ctx, achievement.name, snackbarLevel,
            achievement.levelStart, goToScreen);
      }
    });
  }

  static void showSnackbar(
    BuildContext ctx,
    String achievement,
    int? level,
    int? startingLevel,
    Function(int) goToScreen,
  ) {
    // get achievement text
    String achievementMainText;
    String achievementSecondaryText;
    if (level != null && startingLevel != null) {
      achievementMainText = level == startingLevel
          ? "You earned a new achievement!"
          : "You leveled up an achievement!";
      achievementSecondaryText = level == startingLevel
          ? achievement
          : "$achievement is now level $level";
    } else {
      achievementMainText = "You earned a new achievement!";
      achievementSecondaryText = achievement;
    }

    // prevents error from snackbar being rendered on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // create snackbar from BuildContext
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.emoji_events, color: Colors.black),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievementMainText, textAlign: TextAlign.left),
                        Text(
                          achievementSecondaryText,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          action: SnackBarAction(
            label: "View",
            // go to achievements screen when you click the action
            onPressed: () => goToScreen(3),
          ),
        ),
      );
    });
  }
}

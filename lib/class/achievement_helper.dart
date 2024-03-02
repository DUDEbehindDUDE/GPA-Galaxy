import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/achievements.dart';
import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
import 'package:gpa_galaxy/generics/type_adapters/grade.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/semester.dart';

class AchievementHelper {
  /// Loads the json from assets/data/achievements.json, and parses it into a
  /// [Map<String, List<Achievements>>] object, where the key is the category.
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

  /// Returns how many classes are >= grade in profile. Example: profile contains classes
  /// with grades 89, 90, 92, 80, 79. [howManyAboveGrade(90, profile)] returns 2;
  /// [howManyAboveGrade(80, profile)] returns 4.
  static int howManyAboveGrade(int grade, Profile profile) {
    var classes = Util.getAllClasses(profile);
    int amount = 0;

    // love how you can't name a variable class :P
    for (var item in classes) {
      if (item.grade >= grade) amount++;
    }

    return amount;
  }

  /// Returns how many semesters the user has fully logged. Returns 0 if they have logged
  /// at least one class; otherwise, if the user has logged no classes, returns -1.
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

  /// This returns the variable associated with the dependent based on the profile.
  static num getAchievementVariable(String dependent, Profile profile) {
    return switch (dependent) {
      "aAmount" => howManyAboveGrade(90, profile),
      "bAmount" => howManyAboveGrade(80, profile),
      "semesterHasFourClasses" => howManySemestersLogged(profile),
      _ => throw ("Variable $dependent not valid!")
    };
  }

  /// Returns all the achievements that are earned, and if any are any new achievements
  /// or achievements that have leveled up, it will display a snackbar saying that they have
  /// been earned. Returns null if BuildContext is invalid, or if nothing has changed.
  static Future<Map<String, List<EarnedAchievement>>?> updateEarnedAchievements(
    Profile profile,
    BuildContext ctx,
    Function(int) goToScreen,
  ) async {
    // get the list of all achievements
    Map<String, List<Achievements>> allAchievements = await loadJson();

    // check if BuildContext is still valid since there is an async above
    if (!ctx.mounted) {
      return null;
    }

    // Calculate all the achievements
    Map<String, List<EarnedAchievement>> allEarnedAchievements = {};
    allAchievements.forEach((category, achievements) {
      for (var achievement in achievements) {
        num dependentValue =
            getAchievementVariable(achievement.dependent, profile);

        int level = -1;
        for (int item in achievement.requirements) {
          if (item > dependentValue) break;
          level++;
        }
        // if level is still -1, the achievement hasn't been earned
        if (level == -1) continue;

        // get description
        String desc = getDesc(achievement, level);

        // add level start
        level += achievement.levelStart;

        // add achievement to map
        allEarnedAchievements[category] ??= []; // initialize if null
        allEarnedAchievements[category]!.add(EarnedAchievement(
          name: achievement.name,
          desc: desc,
          upgradable: achievement.upgradable,
          level: level,
          startingLevel: achievement.levelStart,
          levelCap: achievement.levelCap,
        ));
      }
    });

    // check and display new achievements
    var newAchievements = getNewAchievementList(allEarnedAchievements, profile);
    // this return keeps everything from constantly rerendering
    if (newAchievements.isEmpty) return null;
    renderAchievementSnackbars(ctx, newAchievements, goToScreen);

    return allEarnedAchievements;
  }

  /// Checks if each achievement in allEarnedAchievements is present in profile. If it isn't,
  /// it is added to the returned [List<EarnedAchievement>].
  static List<EarnedAchievement> getNewAchievementList(
    Map<String, List<EarnedAchievement>> allEarnedAchievements,
    Profile profile,
  ) {
    var profileAchievements = profile.unlockedAchievements;

    // initialize empty array
    List<EarnedAchievement> newAchievements = [];

    // check if the achievement has been earned already, and if not, add it to newAchievements
    allEarnedAchievements.forEach((category, achievements) {
      for (var achievement in achievements) {
        if (!(profileAchievements[category] ?? []).contains(achievement)) {
          newAchievements.add(achievement);
        }
      }
    });

    return newAchievements;
  }

  /// Gets the description of an achievement based on the current level
  static String getDesc(Achievements achievement, int level) {
    if (level == 0 || achievement.additionalDesc == null) {
      return achievement.desc;
    }

    var descriptions = achievement.additionalDesc!;
    if (descriptions.isEmpty) return achievement.desc;

    // if you have level 1, description would be additionalDesc[0], etc
    return descriptions[min(level, descriptions.length) - 1];
  }

  /// Calls [displayAchievementSnackbar()] for each achievement given. Used to
  /// show snackbars for all new achievements.
  static void renderAchievementSnackbars(
    BuildContext ctx,
    List<EarnedAchievement> achievements,
    Function(int) goToScreen,
  ) {
    // get achievement text
    for (var achievement in achievements) {
      String achievementMainText;
      String achievementSecondaryText;

      // get flavor text
      if (!achievement.upgradable ||
          achievement.startingLevel == achievement.level) {
        achievementMainText = "You earned a new achievement!";
        achievementSecondaryText = "${achievement.name}: ${achievement.desc}";
      } else {
        achievementMainText = "You leveled up an achievement!";
        achievementSecondaryText =
            "${achievement.name} is now level ${achievement.level}";
      }
      // display snackbar
      displayAchievementSnackbar(
        achievementMainText,
        achievementSecondaryText,
        ctx,
        goToScreen,
      );
    }
  }

  /// Displays a snackbar with primary and secondary text, and with an action that, when
  /// clicked, goes to the achievement screen (runs goToScreen(3))
  static void displayAchievementSnackbar(
    String mainText,
    String secondaryText,
    BuildContext ctx,
    Function(int) goToScreen,
  ) {
    // prevents error from snackbar being rendered on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // create snackbar from BuildContext
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          dismissDirection: DismissDirection.horizontal,
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
                        Text(mainText, textAlign: TextAlign.left),
                        Text(
                          secondaryText,
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
            onPressed: () {
              // we have to check if the context is still mounted, because if it's not the user
              // has gone to a different screen and this will cause an exception
              if (ctx.mounted) {
                goToScreen(3);
              }
            },
          ),
        ),
      );
    });
  }
}

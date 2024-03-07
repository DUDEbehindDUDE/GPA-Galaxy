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
  /// Loads the JSON data from assets/data/achievements.json and parses it into a
  /// Map<String, List<Achievements>> object, where the key is the category.
  ///
  /// Returns:
  ///   - A Future containing the parsed achievement map.
  static Future<Map<String, List<Achievements>>> loadJson() async {
    var data = await rootBundle.loadString(
      'assets/data/achievements.json',
      cache: true,
    );
    var jsonMap = await jsonDecode(data);

    // Parse json object and convert it to what we want
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

  /// Returns the number of classes with grades greater than or equal to the specified grade in the profile.
  /// 
  /// Example: profile contains classes with grades 89, 90, 92, 80, 79. `howManyAboveGrade(90, profile)` 
  /// would return 2. `howManyAboveGrade(80, profile)` would return 4.
  ///
  /// Parameters:
  ///   - [grade]: The grade to compare against.
  ///   - [profile]: The user profile.
  ///
  /// Returns:
  ///   - The number of classes with grades greater than or equal to the specified grade.
  static int howManyAboveGrade(int grade, Profile profile) {
    var classes = Util.getAllClasses(profile);
    int amount = 0;

    // love how you can't name a variable class :P
    for (var item in classes) {
      if (item.grade >= grade) amount++;
    }

    return amount;
  }

  /// Returns the number of fully logged semesters in the user's profile. If the user has logged
  /// at least one class (but not a full semester's worth), returns zero. If the user hasn't logged
  /// any classes, returns -1.
  ///
  /// Parameters:
  ///   - [profile]: The user profile.
  ///
  /// Returns:
  ///   - The number of fully logged semesters.
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

  /// Returns the variable associated with the dependent based on the profile.
  ///
  /// Parameters:
  ///   - [dependent]: The dependent variable name.
  ///   - [profile]: The user profile.
  ///
  /// Returns:
  ///   - The value of the dependent variable.
  static num getAchievementVariable(String dependent, Profile profile) {
    return switch (dependent) {
      "aAmount" => howManyAboveGrade(90, profile),
      "bAmount" => howManyAboveGrade(80, profile),
      "semesterHasFourClasses" => howManySemestersLogged(profile),
      _ => throw ("Variable $dependent not valid!")
    };
  }

  /// Updates the earned achievements based on the user's profile and displays any new achievements.
  /// Returns all the achievements that are earned, and if any are any new achievements or achievements
  /// that have leveled up, it will display a snackbar saying that they have been earned. Returns null
  /// if BuildContext is invalid, or if nothing has changed.
  ///
  /// Parameters:
  ///   - [profile]: The user profile.
  ///   - [ctx]: The BuildContext.
  ///   - [goToScreen]: A function to navigate to a specific screen.
  ///
  /// Returns:
  ///   - A Future containing the updated earned achievements.
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

        int level = 0;
        for (int item in achievement.requirements) {
          if (item > dependentValue) break;
          level++;
        }
        // if level is still 0, the achievement hasn't been earned
        if (level == 0) continue;

        // get description
        String desc = getDesc(achievement, level);

        // add achievement to map
        allEarnedAchievements[category] ??= []; // initialize if null
        allEarnedAchievements[category]!.add(EarnedAchievement(
          name: achievement.name,
          desc: desc,
          upgradable: achievement.upgradable,
          level: level,
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
  ///
  /// Parameters:
  ///   - [allEarnedAchievements]: A map containing all earned achievements.
  ///   - [profile]: The user profile.
  ///
  /// Returns:
  ///   - A list of new earned achievements.
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
        if (profileAchievements[category] == null) {
          newAchievements.add(achievement);
          continue;
        }

        // check if achievement has leveled up
        bool found = false;
        for (var item in profileAchievements[category]!) {
          // if names don't match
          if (item.name != achievement.name) continue;

          // if achievement exists, but hasn't leveled up
          if (item.level >= achievement.level) {
            found = true;
          }
          break;
        }

        if (!found) newAchievements.add(achievement);
      }
    });

    return newAchievements;
  }

  /// Gets the description of an achievement based on the current level.
  ///
  /// Parameters:
  ///   - [achievement]: The achievement object.
  ///   - [level]: The achievement level.
  ///
  /// Returns:
  ///   - The achievement description.
  static String getDesc(Achievements achievement, int level) {
    if (level == 1 || achievement.additionalDesc == null) {
      return achievement.desc;
    }

    var descriptions = achievement.additionalDesc!;
    if (descriptions.isEmpty) return achievement.desc;

    // if you have level 1, description would be additionalDesc[0], etc
    return descriptions[min(level - 1, descriptions.length) - 1];
  }

  /// Renders snackbars for all new achievements.
  ///
  /// Parameters:
  ///   - [ctx]: The BuildContext.
  ///   - [achievements]: A list of earned achievements.
  ///   - [goToScreen]: A function to navigate to a specific screen.
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
      if (!achievement.upgradable || achievement.level == 1) {
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

  /// Displays a snackbar for a specific achievement.
  ///
  /// Parameters:
  ///   - [mainText]: The main text of the snackbar.
  ///   - [secondaryText]: The secondary text of the snackbar.
  ///   - [ctx]: The BuildContext.
  ///   - [goToScreen]: A function to navigate to a specific screen.
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

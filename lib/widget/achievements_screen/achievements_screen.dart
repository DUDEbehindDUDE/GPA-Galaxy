import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/achievement_helper.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/widget/achievements_screen/achievement_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AchievementsScreen extends StatefulWidget {
  final String profile;

  const AchievementsScreen({super.key, required this.profile});

  @override
  createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  var profileBox = Hive.box<Profile>("profiles");

  Future<List<Widget>> _allAchievements() async {
    var profile = profileBox.get(widget.profile)!;
    var earnedAchievements = profile.unlockedAchievements;
    var allAchievements = await AchievementHelper.loadAchievementsFromJson();

    List<Widget> column = [];

    allAchievements.forEach((category, achievements) {
      column.add(Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0, left: 3.0),
        child: Text(
          Util.formatTitle(category),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ));
      for (var achievement in achievements) {
        EarnedAchievement? item;
        for (var earnedAchievement in earnedAchievements[category] ?? []) {
          // if names don't match
          if (earnedAchievement.name != achievement.name) continue;

          item = earnedAchievement;
          break;
        }

        if (item == null) {
          column.add(AchievementCard(
            name: achievement.name,
            desc: "???",
            upgradable: achievement.upgradable,
            levelCap: achievement.levelCap,
          ));
          continue;
        }

        column.add(AchievementCard(
          name: item.name,
          desc: item.desc,
          upgradable: item.upgradable,
          level: item.level,
          levelCap: item.levelCap,
          dateEarned: item.dateEarned,
        ));
      }
    });

    return column;
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: _allAchievements(),
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data ?? [const RefreshProgressIndicator()],
            );
          },
        ),
      ),
    );
  }
}

import 'package:hive/hive.dart';

part 'earned_achievement.g.dart';

@HiveType(typeId: 6)
class EarnedAchievement {
  /// Name of the earned achievement
  @HiveField(0)
  String name;

  /// Description of the earned achievement
  @HiveField(1)
  String desc;

  /// Whether the earned achievement can be upgraded or not
  @HiveField(2)
  bool upgradable;

  /// Level of the earned achievement
  @HiveField(3)
  int level;

  /// Starting level of the earned achievement (1 if not supplied)
  @HiveField(4)
  int startingLevel;

  /// Level cap of the earned achievement (ignored if not upgradable)
  @HiveField(5)
  int? levelCap;

  EarnedAchievement({
    required this.name,
    required this.desc,
    required this.upgradable,
    required this.level,
    this.startingLevel = 1,
    this.levelCap,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EarnedAchievement &&
        other.name == name &&
        other.desc == desc &&
        other.upgradable == upgradable &&
        other.level == level &&
        other.startingLevel == startingLevel &&
        other.levelCap == levelCap;
  }

  @override
  int get hashCode {
    // generate hashCode based on relevant properties
    return Object.hash(name, desc, upgradable, level, startingLevel, levelCap);
  }
}

class Achievements {
  /// Name of achievement
  String name;

  /// Description of achievement
  String desc;

  /// If the achievement is upgradable or not (defaults to false)
  /// If it is upgradable, that means you can level up the achievement
  bool upgradable;

  /// If the achievement is upgradable, these will display with each level
  List<String>? additionalDesc;

  /// The variable the achievement is dependent upon
  String dependent;

  /// The maximum level of the achievement (if not supplied/null, there is no level cap)
  /// Doesn't apply if the achievement isn't upgradable.
  int? levelCap;

  /// The level of the first achievement (defaults to 1)
  /// Doesn't apply if the achievement isn't upgradable.
  int levelStart;

  /// What amount of the dependent is needed to unlock the achievement. This is
  /// a list, so that you can specify the amount for different levels.
  /// E.g. if this is [1, 4, 7], to unlock the first level, it needs to be >=1,
  /// for level 2, >=4, for level 3, >=7. If this is shorter than the level cap
  /// (or level cap is infinite), the interval of the last gap is used to calculate
  /// additional levels (so in the example, the next ones would be 10, 13, 16... etc)
  /// If the achievement isn't upgradable, only the first index is considered.
  List<int> requirements;

  Achievements({
    required this.name,
    required this.desc,
    this.upgradable = false,
    this.additionalDesc,
    required this.dependent,
    this.levelCap,
    this.levelStart = 1,
    required this.requirements
  }) {
    if (requirements.isEmpty) {
      throw("Requirements cannot be empty");
    }
  }
}

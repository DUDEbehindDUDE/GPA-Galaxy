import 'package:flutter/material.dart';
import 'package:gpa_galaxy/widgets/achievements_screen/achievement_dialog.dart';

class AchievementCard extends StatelessWidget {
  final String name;
  final String desc;
  final bool upgradable;
  final int? levelCap;
  final int level;
  final DateTime? dateEarned;

  final TextStyle titleCardStyle = const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );
  final TextStyle descCardStyle = const TextStyle(
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  const AchievementCard({
    super.key,
    required this.name,
    required this.desc,
    required this.upgradable,
    this.levelCap,
    this.level = 0, 
    this.dateEarned,
  });

  Widget _levelText() {
    if (!upgradable || level == 0) {
      return const SizedBox(); // Empty widget
    }
    String levelText = level == levelCap ? "Max level!" : "Level $level";
    return Text(
      levelText,
      style: const TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: level == 0
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) => AchievementDialog(
                  name: name,
                  desc: desc,
                  upgradable: upgradable,
                  level: level,
                  levelCap: levelCap,
                  dateEarned: dateEarned,
                ),
              );
            },
      child: Card.outlined(
        shape: Border.all(
            width: 3,
            color: level == 0 ? Colors.grey.shade800 : Colors.grey.shade400),
        child: Stack(children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/achievement_tile_bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _levelText(),
                        Text(
                          name,
                          style: titleCardStyle,
                        ),
                        Text(
                          desc,
                          style: descCardStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (level == 0)
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(150, 42, 42, 42),
              ),
            ),
        ]),
      ),
    );
  }
}

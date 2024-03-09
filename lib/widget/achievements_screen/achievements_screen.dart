import 'package:flutter/material.dart';
import 'package:gpa_galaxy/widget/achievements_screen/achievement_card.dart';

class AchievementsScreen extends StatefulWidget {
  final String profile;

  const AchievementsScreen({super.key, required this.profile});

  @override
  createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  TextStyle titleCardStyle = const TextStyle();
  TextStyle descCardStyle = const TextStyle(fontStyle: FontStyle.italic);

  // WIP, this isn't going to stay like this very long
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Academics",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          AchievementCard(titleCardStyle: titleCardStyle, descCardStyle: descCardStyle)
        ],
      ),
    );
  }
}

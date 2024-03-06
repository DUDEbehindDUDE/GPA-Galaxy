import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  final String profile;

  const AchievementsScreen({super.key, required this.profile});

  @override
  createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  TextStyle titleCardStyle = const TextStyle();
  TextStyle descCardStyle = const TextStyle(fontStyle: FontStyle.italic);

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
          Card.outlined(
            shape: Border.all(width: 2, color: Colors.white),
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
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text("Building up the Galaxy", style: titleCardStyle),
                        Text("Log your first grade", style: descCardStyle),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}

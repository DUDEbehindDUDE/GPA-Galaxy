import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpa_galaxy/generics/achievements.dart';

class AchievementHelper {
  
  static Future<Map<String, Achievements>> loadJson() async {
    var data = await rootBundle.loadString('assets/data/achievements.json', cache: true);
    return jsonDecode(data);
  }

  static void getNewAchievements(BuildContext ctx) async {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text("Snackbar!!!!"),
      ),
    );
  }

  
}
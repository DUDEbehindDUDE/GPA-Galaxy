import 'package:hive_flutter/hive_flutter.dart';

part 'activity.g.dart';

@HiveType(typeId: 2)
class Activity {
  @HiveField(0)
  String name;

  @HiveField(1)
  String date;

  @HiveField(2)
  double weeklyTime;
  
  @HiveField(3)
  int totalWeeks;

  Activity({
    required this.name,
    required this.date,
    required this.weeklyTime,
    required this.totalWeeks,
  });
}

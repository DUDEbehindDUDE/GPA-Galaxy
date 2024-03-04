import 'package:hive_flutter/hive_flutter.dart';

part 'volunteer.g.dart';

@HiveType(typeId: 3)
class Volunteer {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double hours;

  Volunteer({required this.name, required this.date, required this.hours});
}

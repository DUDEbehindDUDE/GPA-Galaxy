import 'package:hive_flutter/hive_flutter.dart';

part 'semester.g.dart';

@HiveType(typeId: 5)
enum Semester {
  @HiveField(0)
  s1,
  @HiveField(1)
  s2,
}
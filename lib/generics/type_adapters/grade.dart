
import 'package:hive_flutter/hive_flutter.dart';

part 'grade.g.dart';

@HiveType(typeId: 4)
enum Grade {
  @HiveField(0)
  freshman,

  @HiveField(1)
  sophomore,

  @HiveField(2)
  junior,

  @HiveField(3)
  senior,
}
import 'package:hive_flutter/hive_flutter.dart';

part 'class.g.dart';

@HiveType(typeId: 1)
class Class {
  @HiveField(0)
  String className;

  @HiveField(1)
  double classWeight;
  
  @HiveField(2)
  int grade;

  Class({
    required this.className,
    required this.classWeight,
    required this.grade,
  });
}

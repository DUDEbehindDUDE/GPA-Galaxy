class Profile {
  // string grade, list of classes
  Map<Grade, Map<Semester, List<Class>>> academics;
  Map<Grade, List<Activity>> activities;
  Map<Grade, List<Volunteer>> volunteering;
  List<String> unlockedAchievements;

  Profile({
    required this.academics,
    required this.activities,
    required this.volunteering,
    required this.unlockedAchievements,
  });
}

class Class {
  String className;
  double classWeight;
  int grade;

  Class({
    required this.className,
    required this.classWeight,
    required this.grade,
  });
}

class Activity {
  String name;
  String date;
  double weeklyTime;
  int totalWeeks;

  Activity({
    required this.name,
    required this.date,
    required this.weeklyTime,
    required this.totalWeeks,
  });
}

class Volunteer {
  String name;
  String date;
  String hours;

  Volunteer({required this.name, required this.date, required this.hours});
}

enum Grade { freshman, sophomore, junior, senior }

enum Semester { s1, s2 }

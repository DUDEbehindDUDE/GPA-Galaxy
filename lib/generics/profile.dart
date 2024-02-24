class Profile {
  // string grade, list of classes
  Map<Year, Map<Semester, List<Class>>> academics;
  Map<Year, Map<String, Activity>> activities;
  Map<Year, Map<String, Volunteer>> volunteering;
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
  int classWeight;
  int grade;

  Class({
    required this.className,
    required this.classWeight,
    required this.grade,
  });
}

class Activity {
  String date;
  double weeklyTime;
  int totalWeeks;

  Activity({
    required this.date,
    required this.weeklyTime,
    required this.totalWeeks,
  });
}

class Volunteer {
  String date;
  String hours;

  Volunteer({required this.date, required this.hours});
}

enum Year { freshman, sophomore, junior, senior }

enum Semester { s1, s2 }

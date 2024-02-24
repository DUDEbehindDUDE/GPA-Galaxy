import 'package:flutter_test1/generics/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

// I don't know how this part of hive works, this is 
// what ChatGPT generated for me LOL (it works though!)

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 3; // Unique identifier for Profile

  @override
  Profile read(BinaryReader reader) {
    return Profile(
      academics: reader.read(),
      activities: reader.read(),
      volunteering: reader.read(),
      unlockedAchievements: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer.write(obj.academics);
    writer.write(obj.activities);
    writer.write(obj.volunteering);
    writer.write(obj.unlockedAchievements);
  }
}

class ClassAdapter extends TypeAdapter<Class> {
  @override
  final int typeId = 0; // Unique identifier for Class

  @override
  Class read(BinaryReader reader) {
    return Class(
      className: reader.read(),
      classWeight: reader.read(),
      grade: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Class obj) {
    writer.write(obj.className);
    writer.write(obj.classWeight);
    writer.write(obj.grade);
  }
}

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 1; // Unique identifier for Activity

  @override
  Activity read(BinaryReader reader) {
    return Activity(
      date: reader.read(),
      weeklyTime: reader.read(),
      totalWeeks: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer.write(obj.date);
    writer.write(obj.weeklyTime);
    writer.write(obj.totalWeeks);
  }
}

class VolunteerAdapter extends TypeAdapter<Volunteer> {
  @override
  final int typeId = 2; // Unique identifier for Volunteer

  @override
  Volunteer read(BinaryReader reader) {
    return Volunteer(
      date: reader.read(),
      hours: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Volunteer obj) {
    writer.write(obj.date);
    writer.write(obj.hours);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      academics: (fields[0] as Map).map((dynamic k, dynamic v) => MapEntry(
          k as Grade,
          (v as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as Semester, (v as List).cast<Class>())))),
      activities: (fields[1] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as Grade, (v as List).cast<Activity>())),
      volunteering: (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as Grade, (v as List).cast<Volunteer>())),
      unlockedAchievements: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.academics)
      ..writeByte(1)
      ..write(obj.activities)
      ..writeByte(2)
      ..write(obj.volunteering)
      ..writeByte(3)
      ..write(obj.unlockedAchievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

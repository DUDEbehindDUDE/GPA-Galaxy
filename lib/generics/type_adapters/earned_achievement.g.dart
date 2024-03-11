// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earned_achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EarnedAchievementAdapter extends TypeAdapter<EarnedAchievement> {
  @override
  final int typeId = 6;

  @override
  EarnedAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EarnedAchievement(
      name: fields[0] as String,
      desc: fields[1] as String,
      upgradable: fields[2] as bool,
      immutable: fields[4] as bool,
      level: fields[3] as int,
      levelCap: fields[5] as int?,
      dateEarned: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EarnedAchievement obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.desc)
      ..writeByte(2)
      ..write(obj.upgradable)
      ..writeByte(4)
      ..write(obj.immutable)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.levelCap)
      ..writeByte(6)
      ..write(obj.dateEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarnedAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volunteer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VolunteerAdapter extends TypeAdapter<Volunteer> {
  @override
  final int typeId = 3;

  @override
  Volunteer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Volunteer(
      name: fields[0] as String,
      date: fields[1] as DateTime,
      hours: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Volunteer obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.hours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolunteerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

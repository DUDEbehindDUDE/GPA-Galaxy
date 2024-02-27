// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassAdapter extends TypeAdapter<Class> {
  @override
  final int typeId = 1;

  @override
  Class read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class(
      className: fields[0] as String,
      classWeight: fields[1] as double,
      grade: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Class obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.className)
      ..writeByte(1)
      ..write(obj.classWeight)
      ..writeByte(2)
      ..write(obj.grade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

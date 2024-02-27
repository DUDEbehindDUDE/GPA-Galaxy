// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterAdapter extends TypeAdapter<Semester> {
  @override
  final int typeId = 5;

  @override
  Semester read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Semester.s1;
      case 1:
        return Semester.s2;
      default:
        return Semester.s1;
    }
  }

  @override
  void write(BinaryWriter writer, Semester obj) {
    switch (obj) {
      case Semester.s1:
        writer.writeByte(0);
        break;
      case Semester.s2:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

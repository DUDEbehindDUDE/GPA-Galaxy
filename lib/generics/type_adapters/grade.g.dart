// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 4;

  @override
  Grade read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Grade.freshman;
      case 1:
        return Grade.sophomore;
      case 2:
        return Grade.junior;
      case 3:
        return Grade.senior;
      default:
        return Grade.freshman;
    }
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    switch (obj) {
      case Grade.freshman:
        writer.writeByte(0);
        break;
      case Grade.sophomore:
        writer.writeByte(1);
        break;
      case Grade.junior:
        writer.writeByte(2);
        break;
      case Grade.senior:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

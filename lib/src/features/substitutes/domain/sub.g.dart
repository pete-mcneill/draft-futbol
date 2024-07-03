// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubAdapter extends TypeAdapter<Sub> {
  @override
  final int typeId = 2;

  @override
  Sub read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sub(
      fields[0] as int,
      fields[1] as int,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Sub obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.gameweek)
      ..writeByte(1)
      ..write(obj.subOutId)
      ..writeByte(2)
      ..write(obj.subInId)
      ..writeByte(3)
      ..write(obj.subOutPosition)
      ..writeByte(4)
      ..write(obj.subInPosition)
      ..writeByte(5)
      ..write(obj.teamId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

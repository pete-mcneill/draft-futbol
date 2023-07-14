// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_subs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftSubAdapter extends TypeAdapter<DraftSub> {
  @override
  final int typeId = 1;

  @override
  DraftSub read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftSub(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DraftSub obj) {
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
      other is DraftSubAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

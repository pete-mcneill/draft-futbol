// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CupAdapter extends TypeAdapter<Cup> {
  @override
  final int typeId = 3;

  @override
  Cup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cup(
      fields[0] as String,
      (fields[1] as List).cast<dynamic>(),
      (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<dynamic>())),
      (fields[3] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Cup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rounds)
      ..writeByte(2)
      ..write(obj.fixtures)
      ..writeByte(3)
      ..write(obj.teamIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

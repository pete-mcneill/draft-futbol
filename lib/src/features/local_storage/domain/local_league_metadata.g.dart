// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_league_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalLeagueMetadataAdapter extends TypeAdapter<LocalLeagueMetadata> {
  @override
  final int typeId = 0;

  @override
  LocalLeagueMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalLeagueMetadata(
      id: fields[0] as int,
      name: fields[1] as String,
      scoring: fields[2] as String,
      adminId: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalLeagueMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.scoring)
      ..writeByte(3)
      ..write(obj.adminId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalLeagueMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

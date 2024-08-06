// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cup_fixture.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CupFixtureAdapter extends TypeAdapter<CupFixture> {
  @override
  final int typeId = 4;

  @override
  CupFixture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CupFixture(
      homeTeamId: fields[0] as int,
      awayTeamId: fields[1] as int,
      firstLegHomeScore: fields[2] as int?,
      firstLegAwayScore: fields[3] as int?,
      homeScore: fields[4] as int?,
      homeBonusScore: fields[5] as int?,
      awayScore: fields[6] as int?,
      awayBonusScore: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CupFixture obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.homeTeamId)
      ..writeByte(1)
      ..write(obj.awayTeamId)
      ..writeByte(2)
      ..write(obj.firstLegHomeScore)
      ..writeByte(3)
      ..write(obj.firstLegAwayScore)
      ..writeByte(4)
      ..write(obj.homeScore)
      ..writeByte(5)
      ..write(obj.homeBonusScore)
      ..writeByte(6)
      ..write(obj.awayScore)
      ..writeByte(7)
      ..write(obj.awayBonusScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CupFixtureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

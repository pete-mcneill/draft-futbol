import 'package:hive/hive.dart';

part 'sub.g.dart';

@HiveType(typeId: 2)
class Sub {
  @HiveField(0)
  int gameweek;

  @HiveField(1)
  int subOutId;

  @HiveField(2)
  int subInId;

  @HiveField(3)
  int subOutPosition;

  @HiveField(4)
  int subInPosition;

  @HiveField(5)
  int teamId;

  Sub(this.gameweek, this.subOutId, this.subInId, this.subOutPosition,
      this.subInPosition, this.teamId);
}

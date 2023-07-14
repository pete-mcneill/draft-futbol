
import 'package:hive/hive.dart';

part 'draft_subs.g.dart';

@HiveType(typeId: 1)
class DraftSub {
  @HiveField(0)
  String gameweek;
  
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


  DraftSub(this.gameweek, this.subOutId, this.subInId, this.subOutPosition, this.subInPosition, this.teamId);
}

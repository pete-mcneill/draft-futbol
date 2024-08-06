import 'package:hive/hive.dart';

part 'cup_fixture.g.dart';

@HiveType(typeId: 4)
class CupFixture {
  @HiveField(0)
  int homeTeamId;
  @HiveField(1)
  int awayTeamId;
  @HiveField(2)
  int? firstLegHomeScore;
  @HiveField(3)
  int? firstLegAwayScore;
  @HiveField(4)
  int? homeScore;
  @HiveField(5)
  int? homeBonusScore;
  @HiveField(6)
  int? awayScore;
  @HiveField(7)
  int? awayBonusScore;

  CupFixture(
      {required this.homeTeamId,
      required this.awayTeamId,
      this.firstLegHomeScore = 0,
      this.firstLegAwayScore = 0,
      this.homeScore,
      this.homeBonusScore,
      this.awayScore,
      this.awayBonusScore});

  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeamId,
      'awayTeam': awayTeamId,
    };
  }
}

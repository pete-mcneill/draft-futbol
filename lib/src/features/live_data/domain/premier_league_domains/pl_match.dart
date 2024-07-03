import 'package:draft_futbol/src/features/premier_league_matches/domain/bps.dart';

class PlMatch {
  int? matchId;
  String? homeTeam;
  int? homeTeamId;
  String? awayTeam;
  int? awayTeamId;
  String? homeCode;
  String? awayCode;
  bool? started;
  bool? finished;
  bool? finishedProvisional;
  Map<int, List<Bps>> bpsPlayers;
  String? homeShortName;
  String? awayShortName;
  int? homeScore;
  int? awayScore;
  List<dynamic>? stats;
  String? kickOffTime;

  PlMatch(
      {this.matchId,
      this.homeTeam,
      this.awayTeam,
      this.homeTeamId,
      this.awayTeamId,
      this.homeCode,
      this.awayCode,
      this.started,
      this.finished,
      this.finishedProvisional,
      required this.bpsPlayers,
      this.homeShortName,
      this.awayShortName,
      this.homeScore,
      this.awayScore,
      this.stats,
      this.kickOffTime});

  factory PlMatch.fromJson(
      int matchId,
      String homeTeam,
      String awayTeam,
      int homeId,
      int awayId,
      String homeCode,
      String awayCode,
      bool started,
      bool finished,
      bool finishedProvisional,
      Map<int, List<Bps>> bpsPlayers,
      String homeShortName,
      String awayShortName,
      int homeScore,
      int awayScore,
      List<dynamic> stats,
      String kickOffTime) {
    return PlMatch(
        matchId: matchId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeTeamId: homeId,
        awayTeamId: awayId,
        homeCode: homeCode,
        awayCode: awayCode,
        started: started,
        finished: finished,
        finishedProvisional: finishedProvisional,
        bpsPlayers: bpsPlayers,
        homeShortName: homeShortName,
        awayShortName: awayShortName,
        homeScore: homeScore,
        awayScore: awayScore,
        stats: stats,
        kickOffTime: kickOffTime);
  }
}

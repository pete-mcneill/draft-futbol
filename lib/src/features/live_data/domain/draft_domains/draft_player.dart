import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';

class DraftPlayers {
  Map<int, DraftPlayer> players = {};

  DraftPlayers() : super();
}

class DraftPlayer {
  int? playerId;
  String? playerName;
  String? position;
  int? teamId;
  int? playerCode;
  Map<int, String>? playerStatus;
  Map<int, int>? draftTeamId;
  List<PlMatchStats>? matches;
  List<String>? gameweekFixtures;

  DraftPlayer(
      {this.playerId,
      this.playerName,
      this.position,
      this.teamId,
      this.playerCode,
      this.playerStatus,
      this.draftTeamId,
      this.gameweekFixtures});

  void updateMatches(List<PlMatchStats> _matches) {
    matches = _matches;
  }

  factory DraftPlayer.fromJson(Map<String, dynamic> json) {
    String? position;
    switch (json['element_type']) {
      case 1:
        position = "GK";
        break;
      case 2:
        position = "DEF";
        break;
      case 3:
        position = "MID";
        break;
      case 4:
        position = "FWD";
    }
    return DraftPlayer(
        playerId: json['id'],
        playerName: json['web_name'],
        position: position,
        playerCode: json["code"],
        teamId: json['team'],
        draftTeamId: {},
        playerStatus: {},
        gameweekFixtures: []);
  }
}

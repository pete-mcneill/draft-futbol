import 'package:draft_futbol/models/players/match.dart';

class BaguleyDraftPlayer {
  String? playerId;
  String? playerName;
  int? positionId;
  String? position;
  String? teamId;
  String? playerCode;
  Map<String, String>? playerStatus;
  Map<String, String>? draftTeamId;
  List<PlMatchStats>? matches;

  BaguleyDraftPlayer(
      {this.playerId,
      this.playerName,
      this.positionId,
      this.position,
      this.teamId,
      this.playerCode,
      this.playerStatus,
      this.draftTeamId});

  void updateMatches(List<PlMatchStats> _matches) {
    matches = _matches;
  }

  factory BaguleyDraftPlayer.fromJson(Map<String, dynamic> json) {
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
    return BaguleyDraftPlayer(
        playerId: json['id'].toString(),
        playerName: json['web_name'],
        positionId: json['positionId'],
        position: position,
        playerCode: json["code"].toString(),
        teamId: json['team'].toString(),
        draftTeamId: {},
        playerStatus: {});
  }
}

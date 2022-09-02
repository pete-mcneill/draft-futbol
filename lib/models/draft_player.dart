import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/players/bps.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftPlayersNotifier extends StateNotifier<DraftPlayers> {
  DraftPlayersNotifier() : super(DraftPlayers());

  void createAllDraftPlayers(var staticPlayers) {
    for (var player in staticPlayers) {
      DraftPlayer _player = DraftPlayer.fromJson(player);
      try {
        state.players[player['id']] = _player;
      } catch (e) {
        print(e);
      }
    }
  }

  void getLivePlayerData(var liveData) async {
    try {
      liveData['elements'].forEach((k, v) {
        List<Match> _matches = [];
        for (var liveMatch in v['explain']) {
          Match _match = Match.fromJson(liveMatch);
          _matches.add(_match);
        }
        state.players[int.parse(k)]!.updateMatches(_matches);
      });
    } catch (e) {
      print(e);
    }
  }

  void updateLiveBonusPoints(Map<String, PlMatch> plMatches) {
    try {
      state.players.forEach((id, DraftPlayer player) {
        if (player.matches != null) {
          for (Match match in player.matches!) {
            PlMatch plMatch = plMatches[match.matchId.toString()]!;
            if (plMatch.started! && !plMatch.finished!) {
              Map<int, List<Bps>> bps = plMatch.bpsPlayers;
              Iterable threeBps = bps[3]!
                  .where((Bps i) => i.element.toString() == player.playerId);
              if (threeBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 3, value: 3);
                match.stats!.add(_stat);
              }
              Iterable twoBps = bps[2]!
                  .where((Bps i) => i.element.toString() == player.playerId);
              if (twoBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 2, value: 2);
                match.stats!.add(_stat);
              }
              Iterable oneBps = bps[1]!
                  .where((Bps i) => i.element.toString() == player.playerId);
              if (oneBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 1, value: 1);
                match.stats!.add(_stat);
              }
            }
          }
        }
      });
    } catch (error) {
      print(error);
      return;
    }
  }
}

class DraftPlayers {
  Map<int, DraftPlayer> players = {};

  DraftPlayers() : super();
}

class DraftPlayer {
  String? playerId;
  String? playerName;
  String? position;
  String? teamId;
  String? playerCode;
  List<Match>? matches;

  DraftPlayer(
      {this.playerId,
      this.playerName,
      this.position,
      this.teamId,
      this.playerCode});

  void updateMatches(List<Match> _matches) {
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
        playerId: json['id'].toString(),
        playerName: json['web_name'],
        position: position,
        playerCode: json["code"].toString(),
        teamId: json['team'].toString());
  }
}

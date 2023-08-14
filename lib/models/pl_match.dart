import 'package:draft_futbol/models/players/bps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlMatchesNotifier extends StateNotifier<PlMatches> {
  PlMatchesNotifier() : super(PlMatches());

  void addPlayer(PlMatch match) {
    state = state..plMatches!.addAll({match.matchId!: match});
  }

  Future<void> getPlFixtures(dynamic staticData, int gameweek) async {
    Map<String, PlMatch> _matches = {};
    try {
      for (var _match in staticData['fixtures'][gameweek]) {
        String homeTeamName = "";
        String awayTeamName = "";
        String homeCode = "";
        String awayCode = "";
        int homeId = 0;
        int awayId = 0;
        String homeShortName = "";
        String awayShortName = "";
        Map<int, List<Bps>> bpsPlayers = {};

        for (var _team in staticData["teams"]) {
          if (_team["id"] == _match['team_h']) {
            homeTeamName = _team['name'];
            homeCode = _team['code'].toString();
            homeId = _team['id'];
            homeShortName = _team['short_name'];
          }
          if (_team["id"] == _match['team_a']) {
            awayTeamName = _team['name'];
            awayCode = _team['code'].toString();
            awayId = _team['id'];
            awayShortName = _team['short_name'];
          }
        }
        PlMatch match = PlMatch.fromJson(
            _match['id'].toString(),
            homeTeamName,
            awayTeamName,
            homeId.toString(),
            awayId.toString(),
            homeCode,
            awayCode,
            _match['started'],
            _match['finished'],
            _match['finished_provisional'],
            bpsPlayers,
            homeShortName,
            awayShortName,
            _match['team_h_score'] ?? 0,
            _match['team_a_score'] ?? 0, []);
        _matches[_match['id'].toString()] = match;
      }
    } on Exception catch (e) {
      print(e);
    }
    state = state.copyWith(plMatches: _matches);
  }

  Future<void> getLivePlFixtures(dynamic staticData, dynamic liveData) async {
    try {
      Map<String, PlMatch> _matches = {};
      for (var _match in liveData['fixtures']) {
        int homeTeam = 0;
        int awayTeam = 0;
        String homeTeamName = "";
        String awayTeamName = "";
        String homeCode = "";
        String awayCode = "";
        String homeShortName = "";
        String awayShortName = "";
        Map<int, List<Bps>> bpsPlayers = {};
        homeTeam = _match['team_h'];
        awayTeam = _match['team_a'];

        for (var _team in staticData["teams"]) {
          if (_team["id"] == homeTeam) {
            homeTeamName = _team['name'];
            homeCode = _team['code'].toString();
            homeShortName = _team['short_name'];
          }
          if (_team["id"] == awayTeam) {
            awayTeamName = _team['name'];
            awayCode = _team['code'].toString();
            awayShortName = _team['short_name'];
          }
        }
        for (var stat in _match['stats']) {
          for (var statType in staticData['element_stats']) {
            if (statType['name'] == stat['s']) {
              stat['name'] = statType['label'];
            }
          }
          if (stat['s'] == 'bps') {
            bpsPlayers = calculateBPSPlayers(stat);
          }
        }
        PlMatch match = PlMatch.fromJson(
            _match['id'].toString(),
            homeTeamName,
            awayTeamName,
            homeTeam.toString(),
            awayTeam.toString(),
            homeCode,
            awayCode,
            _match['started'],
            _match['finished'],
            _match['finished_provisional'],
            bpsPlayers,
            homeShortName,
            awayShortName,
            _match['team_h_score'] ?? 0,
            _match['team_a_score'] ?? 0,
            _match['stats']);
        _matches[_match['id'].toString()] = match;
      }
      state = state.copyWith(plMatches: _matches);
    } on Exception {
      return;
    }
  }

  Map<int, List<Bps>> calculateBPSPlayers(var stats) {
    try {
      List combinedBPS;
      List<Bps> bpsPlayers = [];
      List<Bps> threeBP;
      List<Bps> twoBP;
      List<Bps> oneBP;
      combinedBPS = List.from(stats['h'])..addAll(stats['a']);
      combinedBPS.sort((a, b) => b['value']!.compareTo(a['value']!));
      for (var player in combinedBPS) {
        Bps _bps = Bps.fromJson(player);
        bpsPlayers.add(_bps);
      }
      threeBP = get3BPSPlayers(bpsPlayers);
      twoBP = get2BPSPlayers(bpsPlayers, threeBP);
      oneBP = get1BPSPlayers(bpsPlayers, threeBP, twoBP);
      var players = {3: threeBP, 2: twoBP, 1: oneBP};
      return players;
    } catch (e) {
      return {3: [], 2: [], 1: []};
    }
  }

  List<Bps> get3BPSPlayers(List<Bps> players) {
    Bps topPlayer = players[0];

    List<Bps> sameBpsPlayers =
        players.where((element) => element.value == topPlayer.value).toList();

    return sameBpsPlayers;
  }

  List<Bps> get2BPSPlayers(List<Bps> players, List<Bps> threeBPS) {
    List<Bps> twoBP = [];
    if (threeBPS.length > 1) {
      return twoBP;
    } else {
      Bps twoBpPLayer = players[1];
      List<Bps> twoBP = players
          .where((element) => element.value == twoBpPLayer.value)
          .toList();
      return twoBP;
    }
  }

  List<Bps> get1BPSPlayers(
      List<Bps> players, List<Bps> threeBPS, List<Bps> twoBPS) {
    List<Bps> oneBP = [];
    if (threeBPS.length > 2) {
      return oneBP;
    }
    if (threeBPS.length == 2) {
      Bps firstOneBP = players[2];
      oneBP = players
          .where((element) => element.value == firstOneBP.value)
          .toList();
      return oneBP;
    } else if (twoBPS.length < 2) {
      Bps firstOneBP = players[2];
      oneBP = players
          .where((element) => element.value == firstOneBP.value)
          .toList();
      return oneBP;
    }
    return oneBP;
  }
}

class PlMatches {
  Map<String, PlMatch>? plMatches = {};

  PlMatches({this.plMatches});

  PlMatches copyWith({Map<String, PlMatch>? plMatches}) {
    return PlMatches(plMatches: plMatches ?? this.plMatches);
  }
}

class PlMatch {
  String? matchId;
  String? homeTeam;
  String? homeTeamId;
  String? awayTeam;
  String? awayTeamId;
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
      this.stats});

  factory PlMatch.fromJson(
      String matchId,
      String homeTeam,
      String awayTeam,
      String homeId,
      String awayId,
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
      List<dynamic> stats) {
    print("FROM JSON");
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
        stats: stats);
  }
}

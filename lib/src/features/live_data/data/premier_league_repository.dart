import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/bps.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premier_league_repository.g.dart';

/// API for reading, watching and writing local cart data (guest user)
class PremierLeagueRepository {
  PremierLeagueRepository();

  /// Preload with the default list of products when the app starts
  // Map<int, DraftPlayer> players = {};
  // Map<int, PlTeam> teams = {};
  // Map<int, PlMatch> matches = {};

  final _api = Api();

  Map<int, DraftPlayer> getAllPremierLeaguePlayers(var playersData) {
    try {
      Map<int, DraftPlayer> players = {};
      for (var player in playersData) {
        DraftPlayer _player = DraftPlayer.fromJson(player);
        players[_player.playerId!] = _player;
      }
      return players;
    } catch (e) {
      throw e;
    }
  }

  Map<int, DraftPlayer> setPlayerOwnershipState(
      var elementStatus, int leagueId, Map<int, DraftPlayer> players) {
    try {
      for (var _player in elementStatus) {
        try {
          players[_player["element"]]!.playerStatus![leagueId] =
              _player["status"];
          if (_player["owner"] != null) {
            players[_player["element"]]!.draftTeamId![leagueId] =
                _player["owner"];
          }
        } catch (e) {
          print(e);
        }
      }
      return players;
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  Future<Map<int, PlTeam>> createPremierLeagueTeams(var teamsData) async {
    Map<int, PlTeam> teams = {};
    for (var team in teamsData) {
      PlTeam _team = PlTeam.fromJson(team);
      teams[_team.id!] = _team;
    }
    return teams;
  }

  Future<void> getCurrentGameweek() async {
    try {
      var _gameweek = await _api.getCurrentGameweek();
      Gameweek gameweek = Gameweek.fromJson(_gameweek);
      gameweek = gameweek;
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  Future<Map<int, DraftPlayer>> getLivePlayerData(
      var liveData, Map<int, DraftPlayer> players, int gameweek) async {
    try {
      liveData['elements'].forEach((k, v) {
        List<PlMatchStats> _matches = [];
        for (var liveMatch in v['explain']) {
          PlMatchStats _match = PlMatchStats.fromJson(liveMatch);
          _matches.add(_match);
        }
        players[int.parse(k)]!.updateMatches(_matches, gameweek);
      });
      return players;
    } catch (e) {
      print("Error getting live player data");
      print(e);
      throw e;
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

  Future<Map<int, PlMatch>> getLivePlFixtures(
      dynamic staticData, dynamic liveData) async {
    try {
      Map<int, PlMatch> matches = {};
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
            _match['id'],
            homeTeamName,
            awayTeamName,
            homeTeam,
            awayTeam,
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
            _match['stats'],
            _match['kickoff_time']);
        matches[_match['id']] = match;
      }
      return matches;
    } on Exception {
      throw Error();
    }
  }

  Map<int, PlMatch> updateLiveBonusPoints(Map<int, PlMatch> plMatches,
      Map<int, DraftPlayer> players, int gameweek) {
    try {
      players.forEach((id, DraftPlayer player) {
        if (player.matches != null) {
          for (PlMatchStats match in player.matches![gameweek]!) {
            PlMatch plMatch = plMatches[match.matchId]!;
            var finalBonus =
                match.stats?.where((_match) => _match.statName == "Bonus");
            if (plMatch.started! && !plMatch.finished! && finalBonus!.isEmpty) {
              Map<int, List<Bps>> bps = plMatch.bpsPlayers;
              Iterable threeBps =
                  bps[3]!.where((Bps i) => i.element == player.playerId);
              if (threeBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 3, value: 3);
                match.stats!.add(_stat);
              }
              Iterable twoBps =
                  bps[2]!.where((Bps i) => i.element == player.playerId);
              if (twoBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 2, value: 2);
                match.stats!.add(_stat);
              }
              Iterable oneBps =
                  bps[1]!.where((Bps i) => i.element == player.playerId);
              if (oneBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 1, value: 1);
                match.stats!.add(_stat);
              }
            }
          }
        }
      });
      return plMatches;
    } catch (error) {
      print(error);
      throw Error();
    }
  }

  // Future<void> getLiveData(var staticData) async {
  //   // Null Means Season has not started
  //   // Therefore no live Data yet
  //   if (gameweek!.currentGameweek != 0) {
  //     var liveData = await _api.getLiveData(gameweek!.currentGameweek);
  //     getLivePlayerData(liveData);

  //     state.plMatches = await PremierLeagueMatchService()
  //         .getLivePlFixtures(staticData, liveData);

  //     state.players = DraftMatchService()
  //         .updateLiveBonusPoints(state.plMatches!, state.players!);
  //   }
  // }

  // void getLivePlayerData(var liveData) async {
  //   try {
  //     liveData['elements'].forEach((k, v) {
  //       List<PlMatchStats> _matches = [];
  //       for (var liveMatch in v['explain']) {
  //         PlMatchStats _match = PlMatchStats.fromJson(liveMatch);
  //         _matches.add(_match);
  //       }
  //       state.players![int.parse(k)]!.updateMatches(_matches);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<DraftLeague> createDraftLeague(int leagueId) async {
  //   var leagueDetails = await _api.getLeagueDetails(leagueId);
  //   DraftLeague _league = DraftLeague.fromJson(leagueDetails);
  //   state.addLeague(_league);
  //   return _league;
  // }

  // // Future<void> refreshData(WidgetRef ref) async {
  // //   Map<int, dynamic> leagueIds =
  // //       ref.read(utilsProvider.select((value) => value.leagueIds!));
  // //   await getFplGameweekData(leagueIds.keys.toList());
  // // }

  // void subScorePreview(Map<int, int>? squad, int leagueId, int teamId) {
  //   Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
  //   Map<int, DraftTeam> _leagueTeams = allTeams[leagueId]!;
  //   DraftTeam team = _leagueTeams[teamId]!;

  //   team = DraftTeamService().getTeamScore(team, state.players!);
  //   allTeams[leagueId]![teamId] = team;

  //   state = state.copyWith(teams: allTeams);
  //   print("Updated State");
  // }

  // void resetSelectedSubs(Map<int, Sub> resetSubs, DraftTeam team) {
  //   for (Sub sub in resetSubs.values) {
  //     int subInPoition = team.squad![sub.subInId]!;
  //     int subOutPosition = team.squad![sub.subOutId]!;
  //     team.squad![sub.subInId] = subOutPosition;
  //     team.squad![sub.subOutId] = subInPoition;
  //   }
  //   team = DraftTeamService().getTeamScore(team, state.players!);
  //   Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
  //   allTeams[team.leagueId]![team.id!] = team;
  //   state = state.copyWith(teams: allTeams);
  // }
}

@Riverpod(keepAlive: true)
PremierLeagueRepository premierLeagueDataRepository(
    PremierLeagueDataRepositoryRef ref) {
  // * Override this in the main method
  return PremierLeagueRepository();
}

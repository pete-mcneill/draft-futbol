import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:draft_futbol/models/app_state.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/draft_league_service.dart';
import 'package:draft_futbol/services/draft_match_service.dart';
import 'package:draft_futbol/services/draft_team_service.dart';
import 'package:draft_futbol/services/premier_league_match_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/draft_leagues.dart';
import '../models/draft_player.dart';
import '../models/draft_team.dart';
import '../models/gameweek.dart';
import '../models/players/match.dart';
import '../models/sub.dart';
import '../services/api_service.dart';
// import '../models/gameweek.dart';

class FplDataNotifier extends StateNotifier<FplData> {
  final _api = Api();
  FplDataNotifier()
      : super(FplData(
          leagues: {},
          players: {},
          teams: {},
          h2hFixtures: {},
          plTeams: {},
          plMatches: {},
          staticStandings: {},
          liveStandings: {},
          bonusStanding: {},
        ));

  FutureOr<FplData> getFplGameweekData(List<int> leagueIds) async {
    print("Calling FPL Data");
    // Returns the Current GW From FPL
    await getCurrentGameweek();
    var staticData = await _api.getStaticData();
    // Creates all DraftPlayer Models from FPL Data
    createAllPlayers(staticData['elements']);
    // Creates all Premier Team models
    createPremierLeagueTeams(staticData['teams']);

    await getLiveData(staticData);

    Map<dynamic, dynamic> subs = {};
    try {
      // await Hive.box('subs').clear();
      // _gameweek!.currentGameweek = "38";
      // Get Subs fom local storage and remove if not for the current GW
      subs = Hive.box('gwSubs').toMap();
      subs.removeWhere(
          (key, value) => value.gameweek != state.gameweek!.currentGameweek);
      // _gameweek!.currentGameweek = "34";
    } catch (error) {
      print(error);
    }

    for (int leagueId in leagueIds) {
      DraftLeague league = await createDraftLeague(leagueId);
      var playerStatus = await _api.getPlayerStatus(leagueId);
      state.players = DraftTeamService().setPlayerStatus(
          playerStatus!['element_status'], leagueId, state.players!);
      if (league.draftStatus != "pre" && state.gameweek!.currentGameweek != 0) {
        // Common League fetches
        //  Get all Squads
        Map<int, DraftTeam> _teams = await DraftTeamService().getLeagueSquads(
            league, state.gameweek!.currentGameweek, leagueId, subs);

        // Calculate Remaining players
        if (league.scoring == "h") {
          // Get League Fixtures
          state.h2hFixtures![leagueId] =
              DraftleagueService().getAllH2HFixtures(league);
          // Get Static League Standings
          state.staticStandings![leagueId] = DraftleagueService()
              .getStaticStandings(league.rawStandings, _teams);
          if (state.gameweek!.gameweekFinished) {
            _teams = DraftTeamService().updateFinishedTeamScores(
                state.h2hFixtures![leagueId]![state.gameweek!.currentGameweek]!,
                _teams);
          } else {
            try {
              _teams = DraftTeamService()
                  .updateLiveTeamScores(state.players!, _teams);
              _teams = DraftTeamService().calculateRemainingPlayers(
                  state.players!, state.plMatches!, _teams);
              List liveStandings =
                  json.decode(json.encode(league.rawStandings));
              List bonusStandings =
                  json.decode(json.encode(league.rawStandings));
              state.liveStandings![leagueId] = DraftleagueService()
                  .getH2hLiveStandings(
                      liveStandings,
                      league.leagueId,
                      state.h2hFixtures![leagueId]!,
                      _teams,
                      state.gameweek!.currentGameweek,
                      false);
              state.bonusStanding![leagueId] = DraftleagueService()
                  .getH2hLiveStandings(
                      bonusStandings,
                      league.leagueId,
                      state.h2hFixtures![leagueId]!,
                      _teams,
                      state.gameweek!.currentGameweek,
                      true);
            } catch (e) {
              print(e);
            }
          }
        } else if (league.scoring == 'c') {
          state.staticStandings![leagueId] = DraftleagueService()
              .getStaticStandings(league.rawStandings, _teams);
          if (state.gameweek!.gameweekFinished) {
            _teams = DraftTeamService().updateClasicTeamScores(
                state.staticStandings![leagueId]!, _teams);
          } else {
            try {
              _teams = DraftTeamService()
                  .updateLiveTeamScores(state.players!, _teams);
              _teams = DraftTeamService().calculateRemainingPlayers(
                  state.players!, state.plMatches!, _teams);
              List liveStandings =
                  json.decode(json.encode(league.rawStandings));
              List bonusStandings =
                  json.decode(json.encode(league.rawStandings));
              state.liveStandings![leagueId] = DraftleagueService()
                  .getClassicLiveStandings(liveStandings, _teams, false,
                      state.players!, state.plMatches!);
              state.bonusStanding![leagueId] = DraftleagueService()
                  .getClassicLiveStandings(bonusStandings, _teams, true,
                      state.players!, state.plMatches!);
            } catch (e) {
              print(e);
            }
          }
        }
        state.teams![leagueId] = _teams;
        // Update Team Scores
      }
    }
    return state;
  }

  Future<void> getCurrentGameweek() async {
    try {
      var _gameweek = await _api.getCurrentGameweek();
      Gameweek gameweek = Gameweek.fromJson(_gameweek);
      state.gameweek = gameweek;
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  void createAllPlayers(var players) {
    try {
      for (var player in players) {
        DraftPlayer _player = DraftPlayer.fromJson(player);
        state.players![_player.playerId!] = _player;
      }
    } catch (e) {
      throw e;
    }
  }

  void createPremierLeagueTeams(var teams) {
    for (var team in teams) {
      PlTeam _team = PlTeam.fromJson(team);
      state.plTeams![_team.id!] = _team;
    }
  }

  Future<void> getLiveData(var staticData) async {
    // Null Means Season has not started
    // Therefore no live Data yet
    if (state.gameweek!.currentGameweek != 0) {
      var liveData = await _api.getLiveData(state.gameweek!.currentGameweek);
      getLivePlayerData(liveData);

      state.plMatches = await PremierLeagueMatchService()
          .getLivePlFixtures(staticData, liveData);

      state.players = DraftMatchService()
          .updateLiveBonusPoints(state.plMatches!, state.players!);
    }
  }

  void getLivePlayerData(var liveData) async {
    try {
      liveData['elements'].forEach((k, v) {
        List<PlMatchStats> _matches = [];
        for (var liveMatch in v['explain']) {
          PlMatchStats _match = PlMatchStats.fromJson(liveMatch);
          _matches.add(_match);
        }
        state.players![int.parse(k)]!.updateMatches(_matches);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<DraftLeague> createDraftLeague(int leagueId) async {
    var leagueDetails = await _api.getLeagueDetails(leagueId);
    DraftLeague _league = DraftLeague.fromJson(leagueDetails);
    state.addLeague(_league);
    return _league;
  }

  Future<void> refreshData(WidgetRef ref) async {
    Map<int, dynamic> leagueIds =
        ref.read(utilsProvider.select((value) => value.leagueIds!));
    await getFplGameweekData(leagueIds.keys.toList());
  }

  void subScorePreview(Map<int, int>? squad, int leagueId, int teamId) {
    Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
    Map<int, DraftTeam> _leagueTeams = allTeams[leagueId]!;
    DraftTeam team = _leagueTeams[teamId]!;

    team = DraftTeamService().getTeamScore(team, state.players!);
    allTeams[leagueId]![teamId] = team;

    state = state.copyWith(teams: allTeams);
    print("Updated State");
  }

  void resetSelectedSubs(Map<int, Sub> resetSubs, DraftTeam team) {
    for (Sub sub in resetSubs.values) {
      int subInPoition = team.squad![sub.subInId]!;
      int subOutPosition = team.squad![sub.subOutId]!;
      team.squad![sub.subInId] = subOutPosition;
      team.squad![sub.subOutId] = subInPoition;
    }
    team = DraftTeamService().getTeamScore(team, state.players!);
    Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
    allTeams[team.leagueId]![team.id!] = team;
    state = state.copyWith(teams: allTeams);
  }
}

import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/utils/commons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class DraftTeamsNotifier extends StateNotifier<DraftTeams> {
  DraftTeamsNotifier() : super(DraftTeams(teams: {}));

  Future<void> getLeagueSquads(dynamic leagueData, String gameweek,
      String leagueId, Map<dynamic, dynamic> subs) async {
    try {
      state.teams![leagueId] = {};
      for (var team in leagueData['league_entries']) {
        DraftTeam _team = DraftTeam.fromJson(team, int.parse(leagueId));
        final teamDetailsResponse = await http.get((Uri.parse(Commons.baseUrl +
            "/api/entry/" +
            _team.entryId!.toString() +
            "/event/" +
            gameweek)));
        if (teamDetailsResponse.statusCode == 200) {
          var response = Commons.returnResponse(teamDetailsResponse);
          for (var player in response['picks']) {
            _team.squad![player['element']] = player['position'];
          }
          if (subs.isNotEmpty) {
            subs.forEach((key, value) {
              if (value.teamId == _team.id) {
                _team.squad![value.subInId] = value.subOutPosition;
                _team.squad![value.subOutId] = value.subInPosition;
                _team.userSubsActive = true;
              }
            });
          }
        }

        state.teams![leagueId]![_team.id!] = _team;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> refreshSquadAfterSubs(
      int teamId, String gameweek, Map<dynamic, dynamic> subs) async {
    DraftTeams teamsCopy = state.copyWith(teams: state.teams);
    for (var league in teamsCopy.teams!.entries) {
      for (var entry in league.value.entries) {
        DraftTeam team = entry.value;
        if (team.id == teamId) {
          final teamDetailsResponse = await http.get((Uri.parse(
              Commons.baseUrl +
                  "/api/entry/" +
                  team.entryId!.toString() +
                  "/event/" +
                  gameweek)));
          if (teamDetailsResponse.statusCode == 200) {
            var response = Commons.returnResponse(teamDetailsResponse);
            for (var player in response['picks']) {
              team.squad![player['element']] = player['position'];
            }
            if (subs.isNotEmpty) {
              subs.forEach((key, value) {
                if (value.teamId == team.id) {
                  team.squad![value.subInId] = value.subOutPosition;
                  team.squad![value.subOutId] = value.subInPosition;
                  team.userSubsActive = true;
                }
              });
            }
            state.teams![league.key]![team.id!] = team;
          }
        }
      }
    }
  }

  void updateFinishedTeamScores(List<Fixture> fixtures, String leagueId) {
    for (Fixture fixture in fixtures) {
      state.teams![leagueId]![fixture.homeTeamId]!.points =
          fixture.homeStaticPoints;
      state.teams![leagueId]![fixture.homeTeamId]!.bonusPoints =
          fixture.homeStaticPoints;
      state.teams![leagueId]![fixture.awayTeamId]!.points =
          fixture.awayStaticPoints;
      state.teams![leagueId]![fixture.awayTeamId]!.bonusPoints =
          fixture.awayStaticPoints;
    }
  }

  void updateLiveTeamScores(Map<int, DraftPlayer> players) {
    int leagueScore = 0;
    int leagueBonusScore = 0;
    int teams = 0;
    int averageId = 0;
    int averageScore = 0;
    int averageBonusScore = 0;
    DraftTeams teamsCopy = state.copyWith(teams: state.teams);
    // Map<String, Map<int, DraftTeam>> _updatedTeams = state.teams!@
    teamsCopy.teams!.forEach((
      leagueId,
      Map<int, DraftTeam> _teams,
    ) {
      _teams.forEach((teamId, DraftTeam team) {
        if (team.teamName != "Average") {
          teams += 1;
          int score = 0;
          int liveBonusScore = 0;
          team.squad!.forEach((int playerId, int position) {
            DraftPlayer _player = players[playerId]!;
            for (Match match in _player.matches!) {
              if (position < 12) {
                for (Stat stat in match.stats!) {
                  if (stat.statName != "Live Bonus Points") {
                    score += stat.fantasyPoints!;
                    liveBonusScore += stat.fantasyPoints!;
                    leagueScore += stat.fantasyPoints!;
                    leagueBonusScore += stat.fantasyPoints!;
                  } else {
                    liveBonusScore += stat.fantasyPoints!;
                    leagueBonusScore += stat.fantasyPoints!;
                  }
                }
              }
            }
          });
          // state.teams[leagueId]![team.id]!.points = score;
          // state.teams[leagueId]![team.id]!.bonusPoints = liveBonusScore;
          team.points = score;
          team.bonusPoints = liveBonusScore;
        } else {
          averageId = teamId;
        }
      });
      averageScore = leagueScore ~/ (_teams.length - 1).round();
      averageBonusScore = leagueBonusScore ~/ (_teams.length - 1).round();
      if (averageId != 0) {
        _teams[averageId]!.points = averageScore;
        _teams[averageId]!.bonusPoints = averageBonusScore;
      }
    });
    state = teamsCopy;
  }

  // void resetSubs( Map<dynamic,dynamic> subs){
  //   subs.forEach((key, value) {
  //     if(value.teamId == _team.id){
  //       _team.squad![value.subInId] = value.subOutPosition;
  //       _team.squad![value.subOutId] = value.subInPosition;
  //       _team.userSubsActive = true;
  //     }
  //   });
  // }

  void updateTeamSquad(Map<int, int>? updatedSquad, int id) {
    state.teams!.forEach((
      leagueId,
      Map<int, DraftTeam> _teams,
    ) {
      _teams.forEach((teamId, DraftTeam _team) {
        if (teamId == id) {
          _team.squad = updatedSquad;
        }
      });
    });
  }

  void calculateRemainingPlayers(
      Map<int, DraftPlayer> players, Map<String, PlMatch> plMatches) {
    state.teams!.forEach((
      leagueId,
      Map<int, DraftTeam> _teams,
    ) {
      _teams.forEach((teamId, DraftTeam team) {
        if (team.teamName != "Average") {
          team.completedPlayersMatches = 0;
          team.remainingPlayersMatches = 0;
          team.completedSubsMatches = 0;
          team.remainingSubsMatches = 0;
          team.livePlayers = 0;
          team.squad!.forEach((int playerId, int position) {
            DraftPlayer _player = players[playerId]!;
            for (Match match in _player.matches!) {
              PlMatch plMatch = plMatches[match.matchId.toString()]!;
              if (position < 12) {
                if (plMatch.started! && !plMatch.finishedProvisional!) {
                  team.livePlayers += 1;
                } else if (plMatch.started!) {
                  team.completedPlayersMatches += 1;
                } else {
                  team.remainingPlayersMatches += 1;
                }
              } else {
                if (plMatch.started!) {
                  team.completedSubsMatches += 1;
                } else {
                  team.remainingSubsMatches += 1;
                }
              }
            }
          });
        }
      });
    });
  }
}

class DraftTeams {
  DraftTeams({this.teams});
  int refreshIncrement = 0;
  Map<String, Map<int, DraftTeam>>? teams = {};
  DraftTeams copyWith({Map<String, Map<int, DraftTeam>>? teams}) {
    return DraftTeams(
      teams: teams ?? this.teams,
    );
  }
}

class DraftTeam {
  final int leagueId;
  final int? entryId;
  final int? id;
  final String? teamName;
  final String? managerName;
  int? points;
  int? bonusPoints;
  Map<int, int>? squad = {};
  int remainingPlayersMatches;
  int completedPlayersMatches;
  int remainingSubsMatches;
  int completedSubsMatches;
  int livePlayers;
  bool? userSubsActive;

  DraftTeam(
      {required this.leagueId,
      this.entryId,
      this.id,
      this.teamName,
      this.managerName,
      this.points,
      this.bonusPoints,
      required this.remainingPlayersMatches,
      required this.completedPlayersMatches,
      required this.remainingSubsMatches,
      required this.completedSubsMatches,
      required this.livePlayers,
      this.userSubsActive = false});

  factory DraftTeam.fromJson(Map<String, dynamic> json, int leagueId) {
    String firstName = json['player_first_name'] ?? "";
    String secondName = json['player_last_name'] ?? "";
    return DraftTeam(
        leagueId: leagueId,
        entryId: json['entry_id'] ?? 0,
        id: json['id'],
        teamName: json['entry_name'] ?? "Average",
        managerName: firstName + " " + secondName,
        points: 0,
        bonusPoints: 0,
        remainingPlayersMatches: 0,
        completedPlayersMatches: 0,
        remainingSubsMatches: 0,
        completedSubsMatches: 0,
        livePlayers: 0);
  }
}

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

  Future<void> getLeagueSquads(
      dynamic leagueData, String gameweek, String leagueId) async {
    try {
      state.teams![leagueId] = {};
      for (var team in leagueData['league_entries']) {
        DraftTeam _team = DraftTeam.fromJson(team);
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
        }
        state.teams![leagueId]![_team.id!] = _team;
      }
    } catch (error) {
      print(error);
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
          team.squad!.forEach((int playerId, int position) {
            DraftPlayer _player = players[playerId]!;
            for (Match match in _player.matches!) {
              PlMatch plMatch = plMatches[match.matchId.toString()]!;
              if (position < 12) {
                if (plMatch.started!) {
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

  void makeAutoSubs(
      Map<int, DraftPlayer> players, Map<String, PlMatch> plMatches) {
    state.teams!.forEach((
      leagueId,
      Map<int, DraftTeam> _teams,
    ) {
      _teams.forEach((teamId, DraftTeam team) {
        if (team.teamName != "Average") {
          int firstSub = team.squad![13]!;
          int secondSub = team.squad![14]!;
          int thirdSub = team.squad![15]!;
          team.squad!.forEach((int playerId, int position) {
            DraftPlayer _player = players[playerId]!;
            bool needsSubbed = false;
            if (position < 12) {
              for (Match match in _player.matches!) {
                PlMatch plMatch = plMatches[match.matchId.toString()]!;
                for (Stat stat in match.stats!) {
                  if (stat.statName == "Minutes played" &&
                      stat.value == 0 &&
                      plMatch.finished!) {
                    needsSubbed = true;
                  }
                }
              }
              if (needsSubbed) {
                DraftPlayer firstSubPlayer = players[firstSub]!;
                bool eligibleSub = false;
                for (Match match in firstSubPlayer.matches!) {
                  PlMatch plMatch = plMatches[match.matchId.toString()]!;
                  for (Stat stat in match.stats!) {
                    if (stat.statName == "Minutes played" &&
                        stat.value != 0 &&
                        plMatch.finished!) {
                      eligibleSub = true;
                    }
                  }
                }
                if (eligibleSub) {
                  int startingDefenders = 0;
                  int startingMids = 0;
                  int startingForwards = 0;
                  team.squad!.forEach((int playerId, int position) {
                    DraftPlayer _squadPlayer = players[playerId]!;
                    switch (_squadPlayer.position) {
                      case "DEF":
                        startingDefenders += 1;
                        break;
                      case "MID":
                        startingMids += 1;
                        break;
                      case "FWD":
                        startingForwards += 1;
                        break;
                    }
                  });
                  bool validSub = true;
                  // Check if valid sub
                  switch (_player.position) {
                    case "DEF":
                      if (startingDefenders == 3 &&
                          firstSubPlayer.position != "DEF") {
                        validSub = false;
                      }
                      break;
                    case "MID":
                      if (startingMids == 2 &&
                          firstSubPlayer.position != "MID") {
                        validSub = false;
                      }
                      break;
                    case "FWD":
                      if (startingMids == 1 &&
                          firstSubPlayer.position != "FWD") {
                        validSub = false;
                      }
                      break;
                  }
                  // if (validSub) {
                  //   print("valid Sub");
                  // }
                }
              }
            }
            // Check each starter, if starter had 0 minutes, check for first sub
            // Check if eligible to be subbed on. Swap Positions if valid
            //  If not valid move to sub no.2 etc.
            // If position is outfieldSub(13-15) flag for sub
          });
        }
      });
    });
  }

  // bool isValidSub()
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

  DraftTeam(
      {this.entryId,
      this.id,
      this.teamName,
      this.managerName,
      this.points,
      this.bonusPoints,
      required this.remainingPlayersMatches,
      required this.completedPlayersMatches,
      required this.remainingSubsMatches,
      required this.completedSubsMatches});

  factory DraftTeam.fromJson(Map<String, dynamic> json) {
    String firstName = json['player_first_name'] ?? "";
    String secondName = json['player_last_name'] ?? "";
    return DraftTeam(
        entryId: json['entry_id'] ?? 0,
        id: json['id'],
        teamName: json['entry_name'] ?? "Average",
        managerName: firstName + " " + secondName,
        points: 0,
        bonusPoints: 0,
        remainingPlayersMatches: 0,
        completedPlayersMatches: 0,
        remainingSubsMatches: 0,
        completedSubsMatches: 0);
  }
}

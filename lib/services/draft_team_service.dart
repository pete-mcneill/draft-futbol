import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/services/api_service.dart';

import '../models/draft_leagues.dart';
import '../models/draft_player.dart';
import '../models/draft_team.dart';
import '../models/fixture.dart';
import '../models/league_standing.dart';
import '../models/pl_match.dart';
import '../models/players/match.dart';
import '../models/players/stat.dart';
import '../models/sub.dart';

class DraftTeamService {
  Future<Map<int, DraftTeam>> getLeagueSquads(DraftLeague league, int gameweek,
      int leagueId, Map<dynamic, dynamic> subs) async {
    final _api = Api();
    try {
      Map<int, DraftTeam> teams = {};
      for (var team in league.teams) {
        DraftTeam _team = DraftTeam.fromJson(team, leagueId);
        if (_team.teamName != "Average") {
          var squad = await _api.getSquad(_team.entryId!, gameweek);
          for (var player in squad['picks']) {
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
        teams[_team.id!] = _team;
      }

      return teams;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Map<int, DraftPlayer> setPlayerStatus(
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

  Map<int, DraftTeam> updateFinishedTeamScores(
      List<Fixture> fixtures, Map<int, DraftTeam> teams) {
    for (Fixture fixture in fixtures) {
      teams[fixture.homeTeamId]!.points = fixture.homeStaticPoints!;
      teams[fixture.homeTeamId]!.bonusPoints = fixture.homeStaticPoints!;
      teams[fixture.awayTeamId]!.points = fixture.awayStaticPoints!;
      teams[fixture.awayTeamId]!.bonusPoints = fixture.awayStaticPoints!;
    }
    return teams;
  }

  Map<int, DraftTeam> updateClasicTeamScores(
      List<LeagueStanding> standings, Map<int, DraftTeam> teams) {
    try {
      for (var standing in standings) {
        teams[standing.teamId]!.points = standing.pointsFor;
        teams[standing.teamId]!.bonusPoints = standing.pointsFor;
      }
    } catch (e) {
      print(e);
    }
    return teams;
  }

  Map<int, DraftTeam> updateLiveTeamScores(
      Map<int, DraftPlayer> players, Map<int, DraftTeam> draftTeams) {
    int leagueScore = 0;
    int leagueBonusScore = 0;
    int averageId = 0;
    int averageScore = 0;
    int averageBonusScore = 0;
    // Map<String, Map<int, DraftTeam>> _updatedTeams = state.teams!@
    draftTeams.forEach((teamId, DraftTeam team) {
      if (team.teamName != "Average") {
        team = getTeamScore(team, players);
        leagueScore += team.points!;
        leagueBonusScore += team.bonusPoints!;
      } else {
        averageId = teamId;
      }
    });
    if (averageId != 0) {
      averageScore = leagueScore ~/ (draftTeams.length - 1).round();
      averageBonusScore = leagueBonusScore ~/ (draftTeams.length - 1).round();
      draftTeams[averageId]!.points = averageScore;
      draftTeams[averageId]!.bonusPoints = averageBonusScore;
    }
    return draftTeams;
  }

  DraftTeam getTeamScore(DraftTeam team, Map<int, DraftPlayer> players) {
    int score = 0;
    int liveBonusScore = 0;
    team.squad!.forEach((int playerId, int position) {
      DraftPlayer _player = players[playerId]!;
      for (PlMatchStats match in _player.matches!) {
        if (position < 12) {
          for (Stat stat in match.stats!) {
            if (stat.statName != "Live Bonus Points") {
              score += stat.fantasyPoints!;
              liveBonusScore += stat.fantasyPoints!;
            } else {
              liveBonusScore += stat.fantasyPoints!;
            }
          }
        }
      }
    });
    team.points = score;
    team.bonusPoints = liveBonusScore;
    return team;
  }

  Map<int, DraftTeam> calculateRemainingPlayers(Map<int, DraftPlayer> players,
      Map<int, PlMatch> plMatches, Map<int, DraftTeam> teams) {
    teams.forEach((teamId, DraftTeam team) {
      if (team.teamName != "Average") {
        team.completedPlayersMatches = 0;
        team.remainingPlayersMatches = 0;
        team.completedSubsMatches = 0;
        team.remainingSubsMatches = 0;
        team.livePlayers = 0;
        team.squad!.forEach((int playerId, int position) {
          DraftPlayer _player = players[playerId]!;
          for (PlMatchStats match in _player.matches!) {
            PlMatch plMatch = plMatches[match.matchId]!;
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
    return teams;
  }
}

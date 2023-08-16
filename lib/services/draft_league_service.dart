import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/players/match.dart';

import '../models/draft_leagues.dart';
import '../models/draft_team.dart';
import '../models/fixture.dart';
import '../models/league_standing.dart';
import '../models/players/stat.dart';

class DraftleagueService {
  Map<int, List<Fixture>> getAllH2HFixtures(DraftLeague league) {
    Map<int, List<Fixture>> fixtures = {};
    try {
      for (var match in league.allH2hFixtures) {
        Fixture _fixture = Fixture.fromJson(match);
        if (fixtures[match['event']] != null) {
          fixtures[match['event']]!.add(_fixture);
        } else {
          fixtures[match['event']] = [_fixture];
        }
      }
      return fixtures;
    } catch (error) {
      print(error);
      return fixtures;
    }
  }

  Map<int, DraftTeam> updateFinishedH2HTeamScores(
      List<Fixture> fixtures, Map<int, DraftTeam> draftTeams) {
    for (Fixture fixture in fixtures) {
      draftTeams[fixture.homeTeamId]!.points = fixture.homeStaticPoints!;
      draftTeams[fixture.homeTeamId]!.bonusPoints = fixture.homeStaticPoints!;
      draftTeams[fixture.awayTeamId]!.points = fixture.awayStaticPoints!;
      draftTeams[fixture.awayTeamId]!.bonusPoints = fixture.awayStaticPoints!;
    }
    return draftTeams;
  }

  // League Standings
  List<LeagueStanding> getStaticStandings(
      List staticStandings, Map<int, DraftTeam> teams) {
    List<LeagueStanding> standings = [];
    try {
      for (var standing in staticStandings) {
        DraftTeam _team = teams[standing['league_entry']]!;
        LeagueStanding _standing = LeagueStanding.fromJson(standing, _team);
        standings.add(_standing);
      }
      return standings;
    } catch (error) {
      return standings;
    }
  }

  List<LeagueStanding> getH2hLiveStandings(
      List standings,
      int leagueId,
      Map<int, List<Fixture>> fixtures,
      Map<int, DraftTeam> draftTeams,
      int gameweek,
      bool bonus) {
    List<LeagueStanding> liveStandings = [];
    try {
      for (Fixture _fixture in fixtures[gameweek]!) {
        var homeStanding;
        var awayStanding;
        DraftTeam homeTeam = draftTeams[_fixture.homeTeamId]!;
        DraftTeam awayTeam = draftTeams[_fixture.awayTeamId]!;
        int homeTeamPoints = (bonus ? homeTeam.bonusPoints : homeTeam.points)!;
        int awayTeamPoints = (bonus ? awayTeam.bonusPoints : awayTeam.points)!;

        for (var standing in standings) {
          if (standing['league_entry'] == _fixture.homeTeamId) {
            homeStanding = standing;
          }
          if (standing['league_entry'] == _fixture.awayTeamId) {
            awayStanding = standing;
          }
        }
        if (homeTeamPoints > awayTeamPoints) {
          // Home Victory
          homeStanding['matches_won'] += 1;
          homeStanding['points_for'] += homeTeamPoints;
          homeStanding['points_against'] += awayTeamPoints;
          homeStanding['total'] += 3;
          // Away Points update
          awayStanding['matches_lost'] += 1;
          awayStanding['points_for'] += awayTeamPoints;
          awayStanding['points_against'] += homeTeamPoints;
        } else if (homeTeamPoints < awayTeamPoints) {
          // Away Win
          homeStanding['matches_lost'] += 1;
          homeStanding['points_for'] += homeTeamPoints;
          homeStanding['points_against'] += awayTeamPoints;
          // Away Points update
          awayStanding['matches_won'] += 1;
          awayStanding['points_for'] += awayTeamPoints;
          awayStanding['points_against'] += homeTeamPoints;
          awayStanding['total'] += 3;
        } else if (homeTeamPoints == awayTeamPoints) {
          // Draw
          homeStanding['matches_drawn'] += 1;
          homeStanding['points_for'] += homeTeamPoints;
          homeStanding['points_against'] += awayTeamPoints;
          homeStanding['total'] += 1;
          // Away Points update
          awayStanding['matches_drawn'] += 1;
          awayStanding['points_for'] += awayTeamPoints;
          awayStanding['points_against'] += homeTeamPoints;
          awayStanding['total'] += 1;
        }
        LeagueStanding _homeStanding = LeagueStanding.fromJson(
            homeStanding, draftTeams[homeStanding['league_entry']]!);
        LeagueStanding _awayStanding = LeagueStanding.fromJson(
            awayStanding, draftTeams[awayStanding['league_entry']]!);
        liveStandings.add(_homeStanding);
        liveStandings.add(_awayStanding);
      }
      liveStandings.sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        if (nameComp == 0) {
          return b.pointsFor!.compareTo(a.pointsFor!); // '-' for descending
        }
        return nameComp;
      });
      for (var i = 0; i < liveStandings.length; i++) {
        int rank = i + 1;
        liveStandings[i].rank = rank;
      }
      return liveStandings;
    } catch (error) {
      print(error);
      return liveStandings;
    }
  }

  List<LeagueStanding> getClassicLiveStandings(
      List standings,
      Map<int, DraftTeam> draftTeams,
      bool bonus,
      Map<int, DraftPlayer> players,
      Map<int, PlMatch> plMatches) {
    List<LeagueStanding> liveStandings = [];
    try {
      for (var standing in standings) {
        DraftTeam team = draftTeams[standing['league_entry']]!;
        int liveScore = 0;
        for (MapEntry entry in team.squad!.entries) {
          int playerId = entry.key;
          int playerPosition = entry.value;
          if (playerPosition < 12) {
            DraftPlayer _player = players[playerId]!;
            for (PlMatchStats match in _player.matches!) {
              PlMatch _match = plMatches[match.matchId]!;
              if (_match.started! && !_match.finished!) {
                for (Stat stat in match.stats!) {
                  if (stat.statName != "Live Bonus Points") {
                    liveScore += stat.fantasyPoints!;
                  } else if (bonus) {
                    liveScore += stat.fantasyPoints!;
                  }
                }
              }
            }
          }
        }
        standing['total'] += liveScore;
        LeagueStanding _standing = LeagueStanding.fromJson(
            standing, draftTeams[standing['league_entry']]!);
        liveStandings.add(_standing);
      }
      liveStandings.sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        return nameComp;
      });
      for (var i = 0; i < liveStandings.length; i++) {
        int rank = i + 1;
        liveStandings[i].rank = rank;
      }
      return liveStandings;
    } catch (error) {
      return liveStandings;
    }
  }
}

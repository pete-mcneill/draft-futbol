import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standing.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_repository.g.dart';

/// API for reading, watching and writing local cart data (guest user)
class DraftRepository {
  DraftRepository();
  final _api = Api();
    /// Preload with the default list of products when the app starts
  Map<int, DraftLeague> leagues = {};
  Map<int, DraftTeam> teams = {};
  Map<int, Map<int, List<Fixture>>> head2HeadFixtures = {};
  Map<int, LeagueStandings> leagueStandings = {};

  Future<DraftLeague> createDraftLeague(int leagueId) async {
    var leagueDetails = await _api.getLeagueDetails(leagueId);
    DraftLeague _league = DraftLeague.fromJson(leagueDetails);
    leagues[leagueId] = _league;
    return _league;
  }

  Future<void> getLeagueSquads(DraftLeague league, int gameweek,
      int leagueId, Map<dynamic, dynamic> subs) async {
    final _api = Api();
    try {
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
    } catch (error) {
      print(error);
    }
  }

  void getAllH2HFixtures(DraftLeague league) {
    try {
      Map<int, List<Fixture>> leagueFixtures = head2HeadFixtures[league.leagueId] ?? {};
      for (var match in league.allH2hFixtures) {
        Fixture _fixture = Fixture.fromJson(match);
        if (leagueFixtures[match['event']] != null) {
          leagueFixtures[match['event']]!.add(_fixture);
        } else {
          leagueFixtures[match['event']] = [_fixture];
        }
      }
      head2HeadFixtures[league.leagueId] = leagueFixtures;
    } catch (error) {
      print(error);
    }
  }

  void setFinalTeamScores(DraftLeague league) {
    try {
      LeagueStandings standings = leagueStandings[league.leagueId]!;
      for(LeagueStanding standing in standings.staticStandings!){
        DraftTeam team = teams[standing.teamId]!;
        team.points = standing.gwScore;
        team.bonusPoints = standing.bpsScore;
      }
    } catch (error) {
      print(error);
    }
  }

  void setLiveTeamScores(DraftLeague league, Map<int, DraftPlayer> players) {
    try {
      // Odd Number of teams in H2H so team has an Average
      if(league.teams.length % 2 != 0){
        setH2HAverageScore(league);
      }
      for (var _team in league.teams) {
        int score = 0;
        int liveBonusScore = 0;
        teams[_team['id']]!.squad!.forEach((int playerId, int position) {
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
     teams[_team['id']]!.points = score;
     teams[_team['id']]!.bonusPoints = liveBonusScore;
      }
    } catch (error) {
      print(error);
    }
  }

  void setH2HAverageScore(DraftLeague league){
    int leagueScore = 0;
    int leagueBonusScore = 0;
    int averageId = 0;
    for(var team in league.teams){
      if(team.teamName != "Average"){
        leagueScore += teams[team.id]!.points!;
        leagueBonusScore += teams[team.id]!.bonusPoints!;
      } else {
        averageId = team.id!;
      }
    }
    if (averageId != 0) {
      int averageScore = leagueScore ~/ (league.teams.length - 1).round();
      int averageBonusScore = leagueBonusScore ~/ (teams.length - 1).round();
      teams[averageId]!.points = averageScore;
      teams[averageId]!.bonusPoints = averageBonusScore;
    }
  }

  void getHead2HeadStandings(var latestFplStandings, DraftLeague league) {
    List<LeagueStanding> standings = [];
    try {
      for (var standing in latestFplStandings) {
        DraftTeam _team = teams[standing['league_entry']]!;
        LeagueStanding _standing = LeagueStanding.fromJson(standing, _team);
        standings.add(_standing);
      }
      leagueStandings.update(league.leagueId, (value) => LeagueStandings(staticStandings: standings, liveBpsStandings: value.liveBpsStandings, liveStandings: value.liveStandings), ifAbsent: () => LeagueStandings(staticStandings: standings));
    } catch (error) {
      print(error);
    }
  }
 
  void getStaticStandings(
      List staticStandings, DraftLeague league) {
    List<LeagueStanding> standings = [];
    try {
      for (var standing in staticStandings) {
        DraftTeam _team = teams[standing['league_entry']]!;
        LeagueStanding _standing = LeagueStanding.fromJson(standing, _team);
        standings.add(_standing);
      }
      leagueStandings.update(league.leagueId, (value) => LeagueStandings(staticStandings: standings, liveBpsStandings: value.liveBpsStandings, liveStandings: value.liveStandings), ifAbsent: () => LeagueStandings(staticStandings: standings));
    } catch (error) {
      print(error);
    }
  }

  void updateClasicTeamScores(
      DraftLeague league) {
    try {
      List<LeagueStanding> standings = leagueStandings[league.leagueId]!.staticStandings!;
      for (var standing in standings) {
        teams[standing.teamId]!.points = standing.pointsFor;
        teams[standing.teamId]!.bonusPoints = standing.pointsFor;
      }
    } catch (e) {
      print(e);
    }
  }

    void calculateRemainingPlayers(Map<int, DraftPlayer> players,
      Map<int, PlMatch> plMatches, DraftLeague league) {
    for (var _team in league.teams) {
      DraftTeam team = teams[_team['id']]!;
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
    }
  }

  void getH2hLiveStandings(
      List standings,
      DraftLeague league,
      int gameweek,
      bool bonus) {
    List<LeagueStanding> liveStandings = [];
    try {
      Map<int, List<Fixture>> fixtures = head2HeadFixtures[league.leagueId]!;
      for (Fixture _fixture in fixtures[gameweek]!) {
        var homeStanding;
        var awayStanding;
        DraftTeam homeTeam = teams[_fixture.homeTeamId]!;
        DraftTeam awayTeam = teams[_fixture.awayTeamId]!;
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
            homeStanding, teams[homeStanding['league_entry']]!);
        LeagueStanding _awayStanding = LeagueStanding.fromJson(
            awayStanding, teams[awayStanding['league_entry']]!);
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
      if(bonus){
        leagueStandings[league.leagueId]!.liveBpsStandings = liveStandings;
      } else {
        leagueStandings[league.leagueId]!.liveStandings = liveStandings;
      }
    } catch (error) {
      print(error);
    }
  }

  List<LeagueStanding> getClassicLiveStandings(
      List standings,
      bool bonus,
      Map<int, DraftPlayer> players,
      Map<int, PlMatch> plMatches) {
    List<LeagueStanding> liveStandings = [];
    try {
      for (var standing in standings) {
        DraftTeam team = teams[standing['league_entry']]!;
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
            standing, teams[standing['league_entry']]!);
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

@Riverpod(keepAlive: true)
DraftRepository draftRepository(DraftRepositoryRef ref) {
  // * Override this in the main method
  return DraftRepository();
}
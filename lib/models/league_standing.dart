import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'draft_team.dart';

class H2HLeagueStandingsNotifier extends StateNotifier<H2HLeagueStandings> {
  H2HLeagueStandingsNotifier() : super(H2HLeagueStandings());

  void addStaticStanding(LeagueStanding standing, String leagueId) {
    state = state..staticStandings[leagueId]!.add(standing);
  }

  void addliveStandings(LeagueStanding standing, String leagueId) {
    state = state..liveStandings[leagueId]!.add(standing);
  }

  void addBpsStandings(LeagueStanding standing, String leagueId) {
    state = state..liveBpsStandings[leagueId]!.add(standing);
  }

  void getStaticStandings(
      List standings, Map<int, DraftTeam> teams, String leagueId) async {
    state.staticStandings[leagueId] = [];
    try {
      for (var standing in standings) {
        DraftTeam _team = teams[standing['league_entry']]!;
        LeagueStanding _standing = LeagueStanding.fromJson(standing, _team);
        state.staticStandings[leagueId]!.add(_standing);
      }
    } catch (error) {}
  }

  void getLiveStandings(
      List standings,
      String leagueId,
      Map<String, List<Fixture>> fixtures,
      Map<String, Map<int, DraftTeam>> draftTeams,
      int gameweek) async {
    state.liveStandings[leagueId] = [];
    try {
      for (Fixture _fixture in fixtures[gameweek]!) {
        var homeStanding;
        var awayStanding;
        DraftTeam homeTeam = draftTeams[leagueId]![_fixture.homeTeamId]!;
        DraftTeam awayTeam = draftTeams[leagueId]![_fixture.awayTeamId]!;
        for (var standing in standings) {
          if (standing['league_entry'] == _fixture.homeTeamId) {
            homeStanding = standing;
          }
          if (standing['league_entry'] == _fixture.awayTeamId) {
            awayStanding = standing;
          }
        }
        if (homeTeam.points! > awayTeam.points!) {
          // Home Victory
          homeStanding['matches_won'] += 1;
          homeStanding['points_for'] += homeTeam.points!;
          homeStanding['points_against'] += awayTeam.points!;
          homeStanding['total'] += 3;
          // Away Points update
          awayStanding['matches_lost'] += 1;
          awayStanding['points_for'] += awayTeam.points!;
          awayStanding['points_against'] += homeTeam.points!;
        } else if (homeTeam.points! < awayTeam.points!) {
          // Away Win
          homeStanding['matches_lost'] += 1;
          homeStanding['points_for'] += homeTeam.points!;
          homeStanding['points_against'] += awayTeam.points!;
          // Away Points update
          awayStanding['matches_won'] += 1;
          awayStanding['points_for'] += awayTeam.points!;
          awayStanding['points_against'] += homeTeam.points!;
          awayStanding['total'] += 3;
        } else if (homeTeam.points! == awayTeam.points!) {
          // Draw
          homeStanding['matches_drawn'] += 1;
          homeStanding['points_for'] += homeTeam.points!;
          homeStanding['points_against'] += awayTeam.points!;
          homeStanding['total'] += 1;
          // Away Points update
          awayStanding['matches_drawn'] += 1;
          awayStanding['points_for'] += awayTeam.points!;
          awayStanding['points_against'] += homeTeam.points!;
          awayStanding['total'] += 1;
        }
        LeagueStanding _homeStanding = LeagueStanding.fromJson(
            homeStanding, draftTeams[leagueId]![homeStanding['league_entry']]!);
        LeagueStanding _awayStanding = LeagueStanding.fromJson(
            awayStanding, draftTeams[leagueId]![awayStanding['league_entry']]!);
        state.liveStandings[leagueId]!.add(_homeStanding);
        state.liveStandings[leagueId]!.add(_awayStanding);
      }
      state.liveStandings[leagueId]!.sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        if (nameComp == 0) {
          return b.pointsFor!.compareTo(a.pointsFor!); // '-' for descending
        }
        return nameComp;
      });
      for (var i = 0; i < state.liveStandings[leagueId]!.length; i++) {
        int rank = i + 1;
        state.liveStandings[leagueId]![i].rank = rank;
      }
    } catch (error) {
      print(error);
    }
  }

  void getLiveBonusPointStandings(
      List standings,
      String leagueId,
      Map<String, List<Fixture>> fixtures,
      Map<String, Map<int, DraftTeam>> draftTeams,
      int gameweek) async {
    state.liveBpsStandings[leagueId] = [];
    try {
      for (Fixture _fixture in fixtures[gameweek]!) {
        var homeStanding;
        var awayStanding;
        DraftTeam homeTeam = draftTeams[leagueId]![_fixture.homeTeamId]!;
        DraftTeam awayTeam = draftTeams[leagueId]![_fixture.awayTeamId]!;
        for (var standing in standings) {
          if (standing['league_entry'] == _fixture.homeTeamId) {
            homeStanding = standing;
          }
          if (standing['league_entry'] == _fixture.awayTeamId) {
            awayStanding = standing;
          }
        }
        if (homeTeam.bonusPoints! > awayTeam.bonusPoints!) {
          // Home Victory
          homeStanding['matches_won'] += 1;
          homeStanding['points_for'] += homeTeam.bonusPoints!;
          homeStanding['points_against'] += awayTeam.bonusPoints!;
          homeStanding['total'] += 3;
          // Away Points update
          awayStanding['matches_lost'] += 1;
          awayStanding['points_for'] += awayTeam.bonusPoints!;
          awayStanding['points_against'] += homeTeam.bonusPoints!;
        } else if (homeTeam.bonusPoints! < awayTeam.bonusPoints!) {
          // Away Win
          homeStanding['matches_lost'] += 1;
          homeStanding['points_for'] += homeTeam.bonusPoints!;
          homeStanding['points_against'] += awayTeam.bonusPoints!;
          // Away Points update
          awayStanding['matches_won'] += 1;
          awayStanding['points_for'] += awayTeam.bonusPoints!;
          awayStanding['points_against'] += homeTeam.bonusPoints!;
          awayStanding['total'] += 3;
        } else if (homeTeam.bonusPoints! == awayTeam.bonusPoints!) {
          // Draw
          homeStanding['matches_drawn'] += 1;
          homeStanding['points_for'] += homeTeam.bonusPoints!;
          homeStanding['points_against'] += awayTeam.bonusPoints!;
          homeStanding['total'] += 1;
          // Away Points update
          awayStanding['matches_drawn'] += 1;
          awayStanding['points_for'] += awayTeam.bonusPoints!;
          awayStanding['points_against'] += homeTeam.bonusPoints!;
          awayStanding['total'] += 1;
        }
        LeagueStanding _homeStanding = LeagueStanding.fromJson(
            homeStanding, draftTeams[leagueId]![homeStanding['league_entry']]!);
        LeagueStanding _awayStanding = LeagueStanding.fromJson(
            awayStanding, draftTeams[leagueId]![awayStanding['league_entry']]!);
        state.liveBpsStandings[leagueId]!.add(_homeStanding);
        state.liveBpsStandings[leagueId]!.add(_awayStanding);
      }
      state.liveBpsStandings[leagueId]!
          .sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        if (nameComp == 0) {
          return b.pointsFor!.compareTo(a.pointsFor!); // '-' for descending
        }
        return nameComp;
      });
      for (var i = 0; i < state.liveBpsStandings[leagueId]!.length; i++) {
        int rank = i + 1;
        state.liveBpsStandings[leagueId]![i].rank = rank;
      }
    } catch (error) {}
  }
}

class ClassicLeagueStandingsNotifier
    extends StateNotifier<ClassicLeagueStandings> {
  ClassicLeagueStandingsNotifier() : super(ClassicLeagueStandings());

  void addStaticStanding(LeagueStanding standing, String leagueId) {
    state = state..staticStandings[leagueId]!.add(standing);
  }

  void addliveStandings(LeagueStanding standing, String leagueId) {
    state = state..liveStandings[leagueId]!.add(standing);
  }

  void addBpsStandings(LeagueStanding standing, String leagueId) {
    state = state..liveBpsStandings[leagueId]!.add(standing);
  }

  Future<Map<String, List<LeagueStanding>>> getStaticStandings(List standings,
      String leagueId, Map<String, Map<int, DraftTeam>> draftTeams) async {
    state.staticStandings[leagueId] = [];
    try {
      for (var standing in standings) {
        DraftTeam _team = draftTeams[leagueId]![standing['league_entry']]!;
        LeagueStanding _standing = LeagueStanding.fromJson(standing, _team);
        state.staticStandings[leagueId]!.add(_standing);
      }
      return state.staticStandings;
    } catch (error) {
      return {};
    }
  }

  void updateFinishedTeamScores(List standings, String leagueId,
      Map<String, Map<int, DraftTeam>> draftTeams) {
    try {
      for (var standing in standings) {
        draftTeams[leagueId]![standing['league_entry']]!.points =
            standing['event_total'];
        draftTeams[leagueId]![standing['league_entry']]!.bonusPoints =
            standing['event_total'];
      }
    } catch (e) {
      print(e);
    }
  }

  void getLiveStandings(List standings, String leagueId,
      Map<String, Map<int, DraftTeam>> draftTeams) async {
    state.liveStandings[leagueId] = [];
    try {
      for (var standing in standings) {
        DraftTeam team = draftTeams[leagueId]![standing['league_entry']]!;
        standing['total'] += team.points;
        LeagueStanding _standing = LeagueStanding.fromJson(
            standing, draftTeams[leagueId]![standing['league_entry']]!);
        state.liveStandings[leagueId]!.add(_standing);
      }
      state.liveStandings[leagueId]!.sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        return nameComp;
      });
      for (var i = 0; i < state.liveStandings[leagueId]!.length; i++) {
        int rank = i + 1;
        state.liveStandings[leagueId]![i].rank = rank;
      }
    } catch (error) {}
  }

  void getLiveBonusPointStandings(List standings, String leagueId,
      Map<String, Map<int, DraftTeam>> draftTeams) async {
    state.liveBpsStandings[leagueId] = [];
    try {
      for (var standing in standings) {
        DraftTeam team = draftTeams[leagueId]![standing['league_entry']]!;
        standing['total'] += team.bonusPoints;
        LeagueStanding _standing = LeagueStanding.fromJson(
            standing, draftTeams[leagueId]![standing['league_entry']]!);
        state.liveBpsStandings[leagueId]!.add(_standing);
      }
      state.liveBpsStandings[leagueId]!
          .sort((LeagueStanding a, LeagueStanding b) {
        int nameComp = b.leaguePoints!.compareTo(a.leaguePoints!);
        // if (nameComp == 0) {
        //   return b.pointsFor!.compareTo(a.pointsFor!); // '-' for descending
        // }
        return nameComp;
      });
      for (var i = 0; i < state.liveBpsStandings[leagueId]!.length; i++) {
        int rank = i + 1;
        state.liveBpsStandings[leagueId]![i].rank = rank;
      }
    } catch (error) {}
  }
}

class H2HLeagueStandings {
  Map<String, List<LeagueStanding>> staticStandings = {};
  Map<String, List<LeagueStanding>> liveStandings = {};
  Map<String, List<LeagueStanding>> liveBpsStandings = {};

  H2HLeagueStandings() : super();
}

class ClassicLeagueStandings {
  Map<String, List<LeagueStanding>> staticStandings = {};
  Map<String, List<LeagueStanding>> liveStandings = {};
  Map<String, List<LeagueStanding>> liveBpsStandings = {};

  ClassicLeagueStandings() : super();
}

class LeagueStanding {
  int? teamId;
  String? teamName;
  int? matchesWon;
  int? matchesDrawn;
  int? matchesLost;
  int? pointsFor;
  int? pointsAgainst;
  int? leaguePoints;
  int? rank;
  int? gwScore;
  int? bpsScore;

  LeagueStanding(
      {this.teamId,
      this.teamName,
      this.matchesWon,
      this.matchesDrawn,
      this.matchesLost,
      this.pointsFor,
      this.pointsAgainst,
      this.leaguePoints,
      this.rank,
      this.gwScore,
      this.bpsScore});

  factory LeagueStanding.fromFirestoreJson(
      var json, Map<String, dynamic>? team) {
    return LeagueStanding(
        teamId: int.parse(json['team_id']),
        teamName: team!['alias'],
        matchesWon: json['wins'] ?? 0,
        matchesDrawn: json['draws'] ?? 0,
        matchesLost: json['losses'] ?? 0,
        pointsFor: json['fpl_points'] ?? 0,
        pointsAgainst: 0,
        leaguePoints: json['points'] ?? 0,
        rank: json['rank'],
        gwScore: json['fpl_points'],
        bpsScore: 0);
  }

  factory LeagueStanding.fromJson(var json, DraftTeam team) {
    return LeagueStanding(
        teamId: json['league_entry'],
        teamName: team.teamName,
        matchesWon: json['matches_won'] ?? 0,
        matchesDrawn: json['matches_drawn'] ?? 0,
        matchesLost: json['matches_lost'] ?? 0,
        pointsFor: json['points_for'] ?? 0,
        pointsAgainst: json['points_against'] ?? 0,
        leaguePoints: json['total'] ?? 0,
        rank: json['rank'] ?? 0,
        gwScore: team.points ?? 0,
        bpsScore: team.bonusPoints ?? 0);
  }
}

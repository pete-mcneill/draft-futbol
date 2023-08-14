import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/ui/screens/league_standings.dart';

import 'DraftTeam.dart';
import 'draft_leagues.dart';
import 'draft_team.dart';
import 'fixture.dart';
import 'gameweek.dart';
import 'league_standing.dart';

class FplData {
  // FplData() : super();

  FplData(
      {this.gameweek,
      this.leagues,
      this.players,
      this.teams,
      this.h2hFixtures,
      this.plTeams,
      this.plMatches,
      this.staticStandings,
      this.liveStandings,
      this.bonusStanding});

  Gameweek? gameweek;
  Map<int, DraftLeague>? leagues;
  Map<int, DraftPlayer>? players = {};
  Map<int, Map<int, DraftTeam>>? teams = {};
  Map<int, Map<int, List<Fixture>>>? h2hFixtures = {};
  Map<int, PlTeam>? plTeams = {};
  Map<int, PlMatch>? plMatches = {};
  Map<int, List<LeagueStanding>>? staticStandings = {};
  Map<int, List<LeagueStanding>>? liveStandings = {};
  Map<int, List<LeagueStanding>>? bonusStanding = {};

  void addLeague(DraftLeague league) {
    leagues![league.leagueId] = league;
  }

  void removeLeague(DraftLeague league) {
    leagues!.remove(league.leagueId);
  }

  void addPlayers(List<dynamic> players) {
    for (var player in players) {
      try {
        DraftPlayer _player = DraftPlayer.fromJson(player);
        players[player.playerId] = player;
      } on Exception catch (e) {
        print(e);
      }
    }
  }

  void updateTeam(Map<int, Map<int, DraftTeam>> _teams) {
    teams = _teams;
  }

  FplData copyWith(
      {Gameweek? gameweek,
      Map<int, DraftLeague>? leagues,
      Map<int, DraftPlayer>? players,
      Map<int, Map<int, DraftTeam>>? teams,
      Map<int, Map<int, List<Fixture>>>? h2hFixtures,
      Map<int, PlTeam>? plTeams,
      Map<int, PlMatch>? plMatches,
      Map<int, List<LeagueStanding>>? staticStandings,
      Map<int, List<LeagueStanding>>? liveStandings,
      Map<int, List<LeagueStanding>>? bonusStanding}) {
    return FplData(
      gameweek: gameweek ?? this.gameweek,
      leagues: leagues ?? this.leagues,
      players: players ?? this.players,
      teams: teams ?? this.teams,
      h2hFixtures: h2hFixtures ?? this.h2hFixtures,
      plTeams: plTeams ?? this.plTeams,
      plMatches: plMatches ?? this.plMatches,
      staticStandings: staticStandings ?? this.staticStandings,
      liveStandings: liveStandings ?? this.liveStandings,
      bonusStanding: bonusStanding ?? this.bonusStanding,
    );
  }
}

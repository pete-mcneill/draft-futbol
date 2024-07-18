import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';

class DraftData {
  DraftData({
    this.leagues = const {},
    this.teams = const {},
    this.head2HeadFixtures = const {},
    this.leagueStandings = const {},
  });

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  Map<int, DraftLeague> leagues = {};
  Map<int, DraftTeam> teams = {};
  Map<int, Map<int, List<Fixture>>> head2HeadFixtures = {};
  Map<int, LeagueStandings> leagueStandings = {};


    DraftData copyWith({
    Map<int, DraftLeague>? leagues,
    Map<int, DraftTeam>? teams,
    Map<int, Map<int, List<Fixture>>>? head2HeadFixtures,
    Map<int, LeagueStandings>? leagueStandings,
  }) {
    return DraftData(
      leagues: leagues ?? this.leagues,
      teams: teams ?? this.teams,
      head2HeadFixtures: head2HeadFixtures ?? this.head2HeadFixtures,
      leagueStandings: leagueStandings ?? this.leagueStandings,
    );
  }
}
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_data.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/live_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_data_controller.g.dart';

@Riverpod(keepAlive: true)
class DraftDataController extends _$DraftDataController {
  @override
  DraftData build() {
    return DraftData();
  }

  Map<int, DraftLeague> get getLeagues => state.leagues;

  Map<int, DraftTeam> get getTeams => state.teams;

  Map<int, Map<int, List<Fixture>>> get getHead2HeadFixtures => state.head2HeadFixtures;

  Map<int, LeagueStandings> get getLeagueStandings => state.leagueStandings;

  void addLeague(DraftLeague league) {
    Map<int, DraftLeague> leagues = Map.from(state.leagues);
    leagues[league.leagueId] = league;
    state = state.copyWith(leagues: leagues);
    print('Added League: ${league.leagueId}');
  }

  void updateTeams(Map<int, DraftTeam> teams){
    state = state.copyWith(teams: teams);
  }

  void updateHead2HeadFixtures(Map<int, Map<int, List<Fixture>>> fixtures){
    state.head2HeadFixtures = fixtures;
  }

  void updateLeagueStandings(Map<int, LeagueStandings> standings){
    state.leagueStandings = standings;
  }
}
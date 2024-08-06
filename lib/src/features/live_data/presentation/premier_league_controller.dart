import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/live_data.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_data.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premier_league_controller.g.dart';

@Riverpod(keepAlive: true)
class PremierLeagueController extends _$PremierLeagueController {
  @override
  PremierLeagueData build() {
    return PremierLeagueData();
  }

  Map<int, DraftPlayer> get getPremierLeaguePlayers => state.players;

  Map<int, PlTeam> get getPremierLeagueTeams => state.teams;

  Map<int, PlMatch> get getPremierLeagueMatches => state.matches;

  void setPremierLeaguePlayers(Map<int,DraftPlayer> players) {
    state = state.copyWith(players: players);
  }

  void setPremierLeagueTeams(Map<int, PlTeam> teams) {
    state = state.copyWith(teams: teams);
  }

  void setPremierLeagueMatches(Map<int, PlMatch> matches) {
    state = state.copyWith(matches: matches);
  }

}
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';

class PremierLeagueData {
  PremierLeagueData({
    this.players = const {},
    this.teams = const {},
    this.matches = const {},
  });

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  Map<int, DraftPlayer> players = {};
  Map<int, PlTeam> teams = {};
  Map<int, PlMatch> matches = {};


    PremierLeagueData copyWith({
    Map<int, DraftPlayer>? players,
    Map<int, PlTeam>? teams,
    Map<int, PlMatch>? matches,
  }) {
    return PremierLeagueData(
      players: players ?? this.players,
      teams: teams ?? this.teams,
      matches: matches ?? this.matches,
    );
  }
}
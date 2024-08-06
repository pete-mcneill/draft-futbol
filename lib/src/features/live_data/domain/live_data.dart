import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';

class LiveData {
  LiveData({
    this.leagueIds = const [],
    this.leagues = const {},
    this.draftPlayers = const {},
    this.draftLeagues = const {},
    this.plTeams = const {},
    this.gameweek});

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  List<int> leagueIds;
  Map<int, DraftLeague> leagues;
  Map<int, DraftPlayer> draftPlayers;
  Map<int, DraftLeague> draftLeagues;
  Map<int, PlTeam> plTeams;
  Gameweek? gameweek;


    LiveData copyWith({
    Gameweek? gameweek
  }) {
    return LiveData(
      leagueIds: leagueIds,
      leagues: leagues,
      draftPlayers: draftPlayers,
      draftLeagues: draftLeagues,
      plTeams: plTeams,
      gameweek: gameweek ?? this.gameweek,
    );
  }
}
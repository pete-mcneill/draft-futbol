import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_repository.g.dart';

/// API for reading, watching and writing local cart data (guest user)
class LiveDataRepository {
  LiveDataRepository({this.leagueIds = const []});
    /// Preload with the default list of products when the app starts
  List<int> leagueIds;
  Map<int, DraftLeague> leagues = {};
  Map<int, DraftPlayer> draftPlayers = {};
  Map<int, DraftLeague> draftLeagues = {};
  Map<int, PlTeam> plTeams = {};  
  Gameweek? gameweek;

  final _api = Api();
  

  Future<Gameweek> getCurrentGameweek() async {
    try {
      var _gameweek = await _api.getCurrentGameweek();
      Gameweek currentGameweek = Gameweek.fromJson(_gameweek);
      return currentGameweek;
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  Gameweek get getGameweek => gameweek!;

  void createPremierLeagueTeams(var teams) {
    for (var team in teams) {
      PlTeam _team = PlTeam.fromJson(team);
      plTeams[_team.id!] = _team;
    }
  }

  // Future<void> getLiveData(var staticData) async {
  //   // Null Means Season has not started
  //   // Therefore no live Data yet
  //   if (gameweek!.currentGameweek != 0) {
  //     var liveData = await _api.getLiveData(gameweek!.currentGameweek);
  //     getLivePlayerData(liveData);

  //     state.plMatches = await PremierLeagueMatchService()
  //         .getLivePlFixtures(staticData, liveData);

  //     state.players = DraftMatchService()
  //         .updateLiveBonusPoints(state.plMatches!, state.players!);
  //   }
  // }

  // void getLivePlayerData(var liveData) async {
  //   try {
  //     liveData['elements'].forEach((k, v) {
  //       List<PlMatchStats> _matches = [];
  //       for (var liveMatch in v['explain']) {
  //         PlMatchStats _match = PlMatchStats.fromJson(liveMatch);
  //         _matches.add(_match);
  //       }
  //       state.players![int.parse(k)]!.updateMatches(_matches);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<DraftLeague> createDraftLeague(int leagueId) async {
  //   var leagueDetails = await _api.getLeagueDetails(leagueId);
  //   DraftLeague _league = DraftLeague.fromJson(leagueDetails);
  //   state.addLeague(_league);
  //   return _league;
  // }

  // Future<void> refreshData(WidgetRef ref) async {
  //   Map<int, dynamic> leagueIds =
  //       ref.read(utilsProvider.select((value) => value.leagueIds!));
  //   await getFplGameweekData(leagueIds.keys.toList());
  // }

  // void subScorePreview(Map<int, int>? squad, int leagueId, int teamId) {
  //   Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
  //   Map<int, DraftTeam> _leagueTeams = allTeams[leagueId]!;
  //   DraftTeam team = _leagueTeams[teamId]!;

  //   team = DraftTeamService().getTeamScore(team, state.players!);
  //   allTeams[leagueId]![teamId] = team;

  //   state = state.copyWith(teams: allTeams);
  //   print("Updated State");
  // }

  // void resetSelectedSubs(Map<int, Sub> resetSubs, DraftTeam team) {
  //   for (Sub sub in resetSubs.values) {
  //     int subInPoition = team.squad![sub.subInId]!;
  //     int subOutPosition = team.squad![sub.subOutId]!;
  //     team.squad![sub.subInId] = subOutPosition;
  //     team.squad![sub.subOutId] = subInPoition;
  //   }
  //   team = DraftTeamService().getTeamScore(team, state.players!);
  //   Map<int, Map<int, DraftTeam>> allTeams = {...state.teams!};
  //   allTeams[team.leagueId]![team.id!] = team;
  //   state = state.copyWith(teams: allTeams);
  // }
}

@Riverpod(keepAlive: true)
LiveDataRepository liveDataRepository(LiveDataRepositoryRef ref) {
  // * Override this in the main method
  return LiveDataRepository();
}
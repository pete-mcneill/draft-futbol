import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_service.g.dart';

class LiveService {
  LiveService(this.ref);
  final Ref ref;

  final _api = Api();

  LiveDataRepository get liveDataRepository =>
      ref.watch(liveDataRepositoryProvider);

  PremierLeagueRepository get premierLeagueDataRepository => ref.watch(premierLeagueDataRepositoryProvider);

  DraftRepository get draftRepository => ref.watch(draftRepositoryProvider);

  Future<void> getLiveData(var staticData) async {
    Gameweek gameweek = ref.read(liveDataRepositoryProvider).gameweek!;
    // Null Means Season has not started
    // Therefore no live Data yet
    if (gameweek.currentGameweek != 0) {
      var liveData = await _api.getLiveData(gameweek.currentGameweek);
      premierLeagueDataRepository.getLivePlayerData(liveData);
      premierLeagueDataRepository.getLivePlFixtures(staticData, liveData);
      premierLeagueDataRepository.updateLiveBonusPoints(premierLeagueDataRepository.matches);
    }
  }
  // Get initial Data on App load from FPL API
  // Probably should be a backend service but that costs money...
  Future<void> getDraftData(List<int> leagueIds) async {
    await liveDataRepository.getCurrentGameweek();

    var staticData = await _api.getStaticData();
    // Creates all Premier League Player Models from FPL Data
    await premierLeagueDataRepository.getAllPremierLeaguePlayers(staticData['elements']);
    // Creates all Premier Team models
    await premierLeagueDataRepository.createPremierLeagueTeams(staticData['teams']);

    await getLiveData(staticData);
    // Map<dynamic, dynamic> subs = {};

    for (int leagueId in leagueIds) {
      DraftLeague league = await draftRepository.createDraftLeague(leagueId);
      var playerStatus = await _api.getPlayerStatus(leagueId);
      premierLeagueDataRepository.setPlayerOwnershipState(playerStatus!['element_status'], leagueId);
      Gameweek gameweek = ref.read(liveDataRepositoryProvider).gameweek!;
      if (league.draftStatus != "pre" && gameweek.currentGameweek != 0) {
        // Common League fetches
        //  Get all Squads
        await draftRepository.getLeagueSquads(
            league, gameweek.currentGameweek, leagueId, {});
        // Calculate Remaining players
        if (league.scoring == "h") {
          // Get League Fixtures
          draftRepository.getAllH2HFixtures(league);
          // Get Static League Standings
          draftRepository.getHead2HeadStandings(league.rawStandings, league);
          if (!gameweek.gameweekFinished) {
              draftRepository.setFinalTeamScores(league);
          } else {
            try {
              draftRepository.setLiveTeamScores(league, premierLeagueDataRepository.players);
              draftRepository.calculateRemainingPlayers(premierLeagueDataRepository.players, premierLeagueDataRepository.matches, league);
              // Get Live Standings
              draftRepository.getH2hLiveStandings(List.from(league.rawStandings), 
                                                    league,  
                                                    gameweek.currentGameweek, 
                                                    false);
              // Get Live Bonus Point Standings
              draftRepository.getH2hLiveStandings(List.from(league.rawStandings), 
                                                    league,  
                                                    gameweek.currentGameweek, 
                                                    true);
            } catch (e) {
              print(e);
            }
          }
        } else if (league.scoring == 'c') {
          draftRepository.getStaticStandings(league.rawStandings, league);
          if (gameweek.gameweekFinished) {
            draftRepository.updateClasicTeamScores(league);
          } else {
            try {
              draftRepository.setLiveTeamScores(league, premierLeagueDataRepository.players);
              draftRepository.calculateRemainingPlayers(premierLeagueDataRepository.players, premierLeagueDataRepository.matches, league);
              draftRepository.getClassicLiveStandings(List.from(draftRepository.leagueStandings[leagueId]!.staticStandings!), false, premierLeagueDataRepository.players, premierLeagueDataRepository.matches);
              draftRepository.getClassicLiveStandings(List.from(draftRepository.leagueStandings[leagueId]!.staticStandings!), true, premierLeagueDataRepository.players, premierLeagueDataRepository.matches);
            } catch (e) {
              print(e);
            }
          }
        }
      }
    }
    //     state.teams![leagueId] = _teams;
    //     // Update Team Scores
    //   }
    // }
    // return state;
  }

//   Future<void> _setSubsStatus(bool status) async {
//     final user = ref.read()
//     if (user != null) {
//       await ref.read(remoteCartRepositoryProvider).setSubsStatus(user.uid, status);
//     } else {
//       await ref.read(localCartRepositoryProvider).setSubsStatus(status);
//     }
//   }
}

@riverpod
Future<dynamic> loadDataOnStart(LoadDataOnStartRef ref, List<int> ids) async {
  await ref.watch(liveServiceProvider).getDraftData(ids);
  return true;
}

@riverpod
LiveService liveService(LiveServiceRef ref) {
  return LiveService(ref);
}

import 'dart:ffi';

import 'package:draft_futbol/src/features/cup/application/cup_service.dart';
import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_round.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/live_data/data/gameweek_repository.dart/gameweek_repository.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_service.g.dart';

class LiveService {
  LiveService(this.ref);
  final Ref ref;

  final _api = Api();

  LiveDataRepository get liveDataRepository =>
      ref.watch(liveDataRepositoryProvider);

  GameweekRepository get gameweekRepo => ref.read(gameweekRepositoryProvider);

  PremierLeagueRepository get premierLeagueDataRepository =>
      ref.watch(premierLeagueDataRepositoryProvider);

  DraftRepository get draftRepository => ref.watch(draftRepositoryProvider);

  PremierLeagueController get premierLeagueController =>
      ref.read(premierLeagueControllerProvider.notifier);

  DraftDataController get draftDataController =>
      ref.read(draftDataControllerProvider.notifier);

  Future<void> getLiveData(
      var staticData, Gameweek gameweek, Map<int, DraftPlayer> players) async {
    // Null Means Season has not started
    // Therefore no live Data yet
    if (gameweek.currentGameweek != 0) {
      var liveData = await _api.getLiveData(gameweek.currentGameweek);
      players = await premierLeagueDataRepository.getLivePlayerData(
          liveData, players, gameweek.currentGameweek);
      Map<int, PlMatch> matches = await premierLeagueDataRepository
          .getLivePlFixtures(staticData, liveData);
      matches = premierLeagueDataRepository.updateLiveBonusPoints(
          matches, players, gameweek.currentGameweek);
      premierLeagueController.setPremierLeagueMatches(matches);
    }
  }

  // Get initial Data on App load from FPL API
  // Probably should be a backend service but that costs money...
  Future<void> getDraftData(List<int> leagueIds) async {
    Gameweek gameweek = await liveDataRepository.getCurrentGameweek();
    ref.read(liveDataControllerProvider.notifier).setGameweek(gameweek);

    var staticData = await _api.getStaticData();
    // Creates all Premier League Player Models from FPL Data
    Map<int, DraftPlayer> players = premierLeagueDataRepository
        .getAllPremierLeaguePlayers(staticData['elements']);
    ref
        .read(premierLeagueControllerProvider.notifier)
        .setPremierLeaguePlayers(players);
    // Creates all Premier Team models
    Map<int, PlTeam> teams = await premierLeagueDataRepository
        .createPremierLeagueTeams(staticData['teams']);
    premierLeagueController.setPremierLeagueTeams(teams);

    await getLiveData(staticData, gameweek, players);
    // Map<dynamic, dynamic> subs = {};

    for (int leagueId in leagueIds) {
      DraftLeague league = await draftRepository.createDraftLeague(leagueId);
      draftDataController.addLeague(league);

      var playerStatus = await _api.getPlayerStatus(leagueId);
      players = premierLeagueDataRepository.setPlayerOwnershipState(
          playerStatus!['element_status'], leagueId, players);
      premierLeagueController.setPremierLeaguePlayers(players);

      if (league.draftStatus != "pre" && gameweek.currentGameweek != 0) {
        // Common League fetches
        //  Get all Squads
        Map<int, DraftTeam> teams = await draftRepository.getLeagueSquads(
            league,
            gameweek.currentGameweek,
            leagueId,
            Map.from(draftDataController.getTeams));
        draftDataController.updateTeams(teams);

        // Calculate Remaining players
        if (league.scoring == "h") {
          // Get League Fixtures
          Map<int, Map<int, List<Fixture>>> head2HeadFixtures =
              draftRepository.getAllH2HFixtures(
                  league, Map.from(draftDataController.getHead2HeadFixtures));
          draftDataController.updateHead2HeadFixtures(head2HeadFixtures);
          // Get Static League Standings
          Map<int, LeagueStandings> standings =
              draftRepository.getHead2HeadStandings(
                  league.rawStandings,
                  league,
                  Map.from(draftDataController.getLeagueStandings),
                  Map.from(draftDataController.getTeams));
          draftDataController.updateLeagueStandings(standings);

          if (gameweek.gameweekFinished) {
            teams = draftRepository.setFinalTeamScores(
                league, gameweek, head2HeadFixtures, teams);
            draftDataController.updateTeams(teams);
          } else {
            try {
              teams = draftRepository.setLiveTeamScores(
                  league, players, teams, gameweek.currentGameweek);
              teams = draftRepository.calculateRemainingPlayers(
                  players,
                  Map.from(premierLeagueController.getPremierLeagueMatches),
                  league,
                  teams,
                  gameweek.currentGameweek);
              draftDataController.updateTeams(teams);
              // Get Live Standings
              standings = draftRepository.getH2hLiveStandings(
                  league,
                  gameweek.currentGameweek,
                  false,
                  head2HeadFixtures,
                  teams,
                  standings);
              // Get Live Bonus Point Standings
              standings = draftRepository.getH2hLiveStandings(
                  league,
                  gameweek.currentGameweek,
                  true,
                  head2HeadFixtures,
                  teams,
                  standings);
              draftDataController.updateLeagueStandings(standings);
            } catch (e) {
              print(e);
              throw Error();
            }
          }
        } else if (league.scoring == 'c') {
          Map<int, LeagueStandings> standings =
              draftRepository.getStaticStandings(league.rawStandings, league,
                  draftDataController.getLeagueStandings, teams);
          draftDataController.updateLeagueStandings(standings);
          if (gameweek.gameweekFinished) {
            teams =
                draftRepository.setFinalTeamScores(league, gameweek, {}, teams);
            draftDataController.updateTeams(teams);
          } else {
            try {
              teams = draftRepository.setLiveTeamScores(
                  league, players, teams, gameweek.currentGameweek);
              teams = draftRepository.calculateRemainingPlayers(
                  players,
                  premierLeagueController.getPremierLeagueMatches,
                  league,
                  teams,
                  gameweek.currentGameweek);
              draftDataController.updateTeams(teams);

              standings = draftRepository.getClassicLiveStandings(
                  league,
                  false,
                  players,
                  premierLeagueController.getPremierLeagueMatches,
                  teams,
                  standings);
              standings = draftRepository.getClassicLiveStandings(
                  league,
                  true,
                  players,
                  premierLeagueController.getPremierLeagueMatches,
                  teams,
                  standings);
              draftDataController.updateLeagueStandings(standings);
            } catch (e) {
              print(e);
              throw Error();
            }
          }
        }
      }
    }
    await ref.read(cupServiceProvider).getCups();
    print("Finished Draft Data");
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

@Riverpod(keepAlive: true)
LiveService liveService(LiveServiceRef ref) {
  return LiveService(ref);
}

@Riverpod(keepAlive: true)
Gameweek gameweekInformation(GameweekInformationRef ref) {
  return ref.watch(liveDataRepositoryProvider).getGameweek;
}

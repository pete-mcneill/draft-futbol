

import 'dart:async';

import 'package:draft_futbol/src/features/league_standings/domain/league_standing.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'league_standings_controller.g.dart';

@riverpod
class LeagueStandingsScreenController extends _$LeagueStandingsScreenController {
  @override
  FutureOr<void> build() {
  }

  PremierLeagueRepository get premierLeagueDataRepository => ref.read(premierLeagueDataRepositoryProvider);

  DraftRepository get draftRepository => ref.read(draftRepositoryProvider);

  LiveDataRepository get liveRepository => ref.read(liveDataRepositoryProvider);

  Gameweek get gameweek => liveRepository.gameweek!;

  // AppSettingsRepository get settingsRepository => ref.watch(appSettingsRepositoryProvider);

  List<Fixture> getGameweekFixtures(int leagueId) {
    // Todo Uplift Active League to new Settings Service
    Gameweek gameweek = liveRepository.gameweek!;
    return draftRepository.head2HeadFixtures[leagueId]![gameweek.currentGameweek]!;
  }

  List<LeagueStanding> getStaticLeagueStandings(int leagueId) {
    return draftRepository.leagueStandings[leagueId]!.staticStandings!;
  } 

  List<LeagueStanding> getLiveLeagueStandings(int leagueId) {
    if(gameweek.gameweekFinished) {
      return draftRepository.leagueStandings[leagueId]!.staticStandings!;
    } else {
      return draftRepository.leagueStandings[leagueId]!.liveStandings!;
    }
    
  }

  List<LeagueStanding> getBonusLeagueStandings(int leagueId) {
    if(gameweek.gameweekFinished) {
      return draftRepository.leagueStandings[leagueId]!.staticStandings!;
    } else {
      return draftRepository.leagueStandings[leagueId]!.liveBpsStandings!;
    }
  }

  // Add your state and logic here
}
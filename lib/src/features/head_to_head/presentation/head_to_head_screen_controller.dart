

import 'dart:async';

import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'head_to_head_screen_controller.g.dart';

@riverpod
class HeadToHeadScreenController extends _$HeadToHeadScreenController {
  @override
  FutureOr<void> build() {
  }

  PremierLeagueRepository get premierLeagueDataRepository => ref.read(premierLeagueDataRepositoryProvider);

  DraftRepository get draftRepository => ref.read(draftRepositoryProvider);

  DraftDataController get draftDataController => ref.read(draftDataControllerProvider.notifier);

  LiveDataController get liveDataController => ref.read(liveDataControllerProvider.notifier);

  // AppSettingsRepository get settingsRepository => ref.watch(appSettingsRepositoryProvider);

  bool liveBonusPointsEnabled() {
    return ref.watch(appSettingsRepositoryProvider).bonusPointsEnabled;}

  List<Fixture> getGameweekFixtures(int leagueId) {
    // Todo Uplift Active League to new Settings Service
    Gameweek gameweek = liveDataController.getGameweek;
    return draftDataController.getHead2HeadFixtures[leagueId]![gameweek.currentGameweek]!;
  }

  String activeLeagueId() {
    
    return ref.watch(appSettingsRepositoryProvider).activeLeagueId.toString();
  }

  bool gameweekFinished() {
    Gameweek gameweek = liveDataController.getGameweek;
    return gameweek.gameweekFinished;
  }

  DraftTeam getTeam(int teamId) {
    return draftDataController.getTeams[teamId]!;
  }

  int getActiveLeague() {
    return ref.watch(appSettingsRepositoryProvider).activeLeagueId;
  }

  // Add your state and logic here
}
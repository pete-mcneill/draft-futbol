

import 'dart:async';

import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
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

  LiveDataRepository get liveRepository => ref.read(liveDataRepositoryProvider);

  // AppSettingsRepository get settingsRepository => ref.watch(appSettingsRepositoryProvider);

  List<Fixture> getGameweekFixtures() {
    // Todo Uplift Active League to new Settings Service
    String activeLeagueId = ref.watch(appSettingsRepositoryProvider).activeLeagueId.toString();
    Gameweek gameweek = liveRepository.gameweek!;
    return draftRepository.head2HeadFixtures[int.parse(activeLeagueId)]![gameweek.currentGameweek]!;
  }

  String activeLeagueId() {
    
    return ref.watch(appSettingsRepositoryProvider).activeLeagueId.toString();
  }

  bool gameweekFinished() {
    Gameweek gameweek = liveRepository.gameweek!;
    return gameweek.gameweekFinished;
  }

  DraftTeam getTeam(int teamId) {
    return draftRepository.teams[teamId]!;
  }

  int getActiveLeague() {
    return ref.watch(appSettingsRepositoryProvider).activeLeagueId;
  }

  // Add your state and logic here
}
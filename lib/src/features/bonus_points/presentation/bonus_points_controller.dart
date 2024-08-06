import 'dart:math';

import 'package:draft_futbol/src/features/live_data/data/gameweek_repository.dart/gameweek_repository.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bonus_points_controller.g.dart';

@riverpod
class BonusPointsController extends _$BonusPointsController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  // AppSettingsService get _appSettingsService => ref.read(appSettingsServiceProvider);

  get _appSettingsService => ref.read(appSettingsRepositoryProvider);

  bool get liveBonusPointsState => ref.watch(appSettingsRepositoryProvider).bonusPointsEnabled;

  Gameweek get gameweek => ref.watch(gameweekRepositoryProvider).gameweek;

  Gameweek getGameweek() {
    return ref.watch(gameweekRepositoryProvider).gameweek;
  }

  Future<void> toggleLiveBonusPoints() async {
    ref.read(appSettingsRepositoryProvider.notifier).toggleLiveBonusPoints();
  }

  Future<void> updateActiveLeague(String id) async {
    final appTest = ref.read(appSettingsRepositoryProvider);
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => appTest.setActiveLeagueId(Random().nextInt(1000)));
  }

  // Future<void> removeItemById(ProductID productId) async {
  //   state = const AsyncLoading();
  //   state =
  //       await AsyncValue.guard(() => _cartService.removeItemById(productId));
  // }
}
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'league_standings_controller.g.dart';

@riverpod
class LeagueStandingsController extends _$LeagueStandingsController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  // AppSettingsService get _appSettingsService => ref.read(appSettingsServiceProvider);

  get _appSettingsService => ref.read(appSettingsRepositoryProvider);


  Future<void> updateBonusPointsSetting(bool status) async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _appSettingsService.toggleLiveBonusPoints());
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
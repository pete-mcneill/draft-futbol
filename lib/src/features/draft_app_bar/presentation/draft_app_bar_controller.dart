import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_app_bar_controller.g.dart';

@riverpod
class DraftAppBarController extends _$DraftAppBarController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  get _appSettingsService => ref.read(appSettingsRepositoryProvider);

  

  List<LocalLeagueMetadata> get leaguesMetadata => ref.read(dataStoreProvider).getLeagues();

  Future<void> updateBonusPointsSetting(bool status) async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _appSettingsService.toggleLiveBonusPoints());
  }

  void updateActiveLeague(String id) async {
    ref.read(appSettingsRepositoryProvider.notifier).setActiveLeagueId(int.parse(id));
  }

  // Future<void> removeItemById(ProductID productId) async {
  //   state = const AsyncLoading();
  //   state =
  //       await AsyncValue.guard(() => _cartService.removeItemById(productId));
  // }
}
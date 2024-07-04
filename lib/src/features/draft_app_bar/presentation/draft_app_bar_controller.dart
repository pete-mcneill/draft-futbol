import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_app_bar_controller.g.dart';

@riverpod
class DraftAppBarController extends _$DraftAppBarController {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  // AppSettingsService get _appSettingsService => ref.read(appSettingsServiceProvider);

  Future<void> updateBonusPointsSetting(bool status) async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _appSettingsService.toggleLiveBonusPoints());
  }

  Future<void> updateActiveLeague(String id) async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _appSettingsService.toggleActiveLeagueId(int.parse(id)));
  }

  // Future<void> removeItemById(ProductID productId) async {
  //   state = const AsyncLoading();
  //   state =
  //       await AsyncValue.guard(() => _cartService.removeItemById(productId));
  // }
}
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

/// API for reading, watching and writing local cart data (guest user)
@Riverpod(keepAlive: true)
class AppSettingsRepository extends _$AppSettingsRepository {

  @override
  AppSettings build() {
    return AppSettings();
  }

  void toggleLiveBonusPoints() {
    state = state.copyWith(bonusPointsEnabled: !state.bonusPointsEnabled);
  }
  
  void setActiveLeagueId(int newLeagueId) {
    state = state.copyWith(activeLeagueId: newLeagueId);
  }
}
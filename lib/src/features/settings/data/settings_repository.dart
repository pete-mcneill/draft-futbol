import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

/// API for reading, watching and writing local cart data (guest user)
@Riverpod(keepAlive: true)
class AppSettingsRepository extends _$AppSettingsRepository {

  @override
  AppSettings build() {
    List<LocalLeagueMetadata> leagues = ref.read(dataStoreProvider).getLeagues();
    return AppSettings(activeLeagueId: leagues[0].id);
  }

  void toggleLiveBonusPoints() {
    state = state.copyWith(bonusPointsEnabled: !state.bonusPointsEnabled);
  }
  
  void setActiveLeagueId(int newLeagueId) {
    state = state.copyWith(activeLeagueId: newLeagueId);
  }
}
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/transactions/domain/trades.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_controller.g.dart';

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  TransactionsData build() {
    return TransactionsData();
  }

  // AppSettingsService get _appSettingsService => ref.read(appSettingsServiceProvider);

  get _appSettingsService => ref.read(appSettingsRepositoryProvider);


  void addWaiver(Transaction waiver, DraftLeague league) {
    Map<int, List<Transaction>> waivers = Map.from(state.waivers);
    if (waivers[league.leagueId] == null) {
      waivers[league.leagueId] = [];
    }
    waivers[league.leagueId]!.add(waiver);
    state = state.copyWith(waivers: waivers); 
  }

  void addFreeAgent(Transaction freeAgent, DraftLeague league) {
    Map<int, List<Transaction>> freeAgents = Map.from(state.freeAgents);
    if (freeAgents[league.leagueId] == null) {
      freeAgents[league.leagueId] = [];
    }
    freeAgents[league.leagueId]!.add(freeAgent);
    state = state.copyWith(freeAgents: freeAgents);
  }

  void addTrade(Trade trade, DraftLeague league) {
    Map<int, List<Trade>> trades = Map.from(state.trades);
    if (trades[league.leagueId] == null) {
      trades[league.leagueId] = [];
    }
    trades[league.leagueId]!.add(trade);
    state = state.copyWith(trades: trades);
  }

  Future<void> updateBonusPointsSetting(bool status) async {
    // state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _appSettingsService.toggleLiveBonusPoints());
  }

  Future<void> updateActiveLeague(String id) async {
    final appTest = ref.read(appSettingsRepositoryProvider);
    // state = const AsyncLoading();
    // state = await AsyncValue.guard(() => appTest.setActiveLeagueId(Random().nextInt(1000)));
  }
}
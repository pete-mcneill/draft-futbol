import 'package:draft_futbol/models/app_state.dart';
import 'package:draft_futbol/models/draft_leagues.dart';
import 'package:draft_futbol/models/trades.dart';
import 'package:draft_futbol/models/transactions.dart';
import 'package:draft_futbol/providers/fpl_data_provider.dart';
import 'package:draft_futbol/services/api_service.dart';
import 'package:draft_futbol/utils/utilities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _api = Api();

final getFplData = FutureProvider.autoDispose
    .family<FplData, List<int>>((ref, leagueIds) async {
  await ref.read(fplGwDataProvider.notifier).getFplGameweekData(leagueIds);
  var data = ref.read(fplGwDataProvider);
  Map<int, dynamic> _leagueIds = {};
  for (int leagueId in leagueIds) {
    DraftLeague league = data.leagues![leagueId]!;
    _leagueIds[leagueId] = {"name": league.leagueName, "season": "23/24"};
  }
  ref.read(utilsProvider.notifier).setLeagueIds(_leagueIds);
  // if(ref.read(utilsProvider).activeLeagueId == null) {
  //   ref.read(utilsProvider.notifier).updateActiveLeague(leagueIds[0]);
  // }
  return data;
});

final fplGwDataProvider =
    StateNotifierProvider<FplDataNotifier, FplData>((ref) {
  return FplDataNotifier();
});

final tradesProvider = StateNotifierProvider<TradesNotifier, Trades>((ref) {
  return TradesNotifier();
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, Transactions>((ref) {
  return TransactionsNotifier();
});

final utilsProvider =
    StateNotifierProvider<UtilitiesProvider, Utilities>((ref) {
  return UtilitiesProvider();
});

final allTransactions = FutureProvider((ref) async {
  try {
    Map<int, DraftLeague> leagues = ref.read(fplGwDataProvider).leagues!;
    for (int leagueId in leagues.keys) {
      var transactions = await _api.getTransactions(leagueId);
      ref
          .read(transactionsProvider.notifier)
          .addAllTransactions(transactions!['transactions'], leagueId);
      // var trades = await _api.getLeagueTrades(leagueId);
      // ref.read(transactionsProvider.notifier).addAllTrades(trades['transactions'], leagueId);
    }
    Map<int, Map<int, List<Transaction>>> transactions = ref.read(transactionsProvider).transactions;
    return transactions;
  } catch (Exception) {
    print(Exception);
  }
});

final allTrades = FutureProvider((ref) async {
  try {
    Map<int, DraftLeague> leagues = ref.read(fplGwDataProvider).leagues!;
    for (int leagueId in leagues.keys) {
      var trades = await _api.getLeagueTrades(leagueId);
      ref.read(tradesProvider.notifier).addAllTrades(trades, leagueId);
    }
  } catch (Exception) {
    print(Exception);
  }
});

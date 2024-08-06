import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/substitutes/domain/sub.dart';
import 'package:draft_futbol/src/features/transactions/application/transactions_controller.dart';
import 'package:draft_futbol/src/features/transactions/domain/trades.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subs_service.g.dart';

class SubsService {
  SubsService(this.ref);
  final Ref ref;

  final _api = Api();

  // Map<int, Sub> getSubsForTeam(int teamId) {
  //   Map<int, Map<int,Sub>> subs = Hive.box('subs').toMap().cast<int, Map<int,Sub>>();
  //   Map<int, Sub> teamSubs = {};
  //   subs.forEach((key, value) {
  //     if (value.teamId == teamId) {
  //       _subs[key] = (value);
  //     }
  //   });
  //   return _subs;
  // }

  Future<void> getTransactions() async {
    Map<int, DraftLeague> leagues = ref.read(draftDataControllerProvider).leagues;
    for(DraftLeague league in leagues.values){
      // Waivers and Free Agents
      final transactions = await _api.getTransactions(league.leagueId);
      for(var transactions in transactions!.values){
        for(var transaction in transactions){
          Transaction _transaction = Transaction.fromJson(transaction);
          if(_transaction.type == 'w'){
            ref.read(transactionsControllerProvider.notifier).addWaiver(_transaction, league);
          }
          if(_transaction.type == 'f'){
            ref.read(transactionsControllerProvider.notifier).addFreeAgent(_transaction, league);
          }
        }
      }

      // Trades
      final trades = await _api.getLeagueTrades(league.leagueId);
      for(var trades in trades!.values){
        for(var trade in trades){
          Trade _trade = Trade.fromJson(trade);
          ref.read(transactionsControllerProvider.notifier).addTrade(_trade, league);
        }
      }
    }
  }
}

@riverpod
SubsService subsService(SubsServiceRef ref) {
  return SubsService(ref);
}

import 'package:draft_futbol/src/features/transactions/domain/trades.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions.dart';

class TransactionsData {
  TransactionsData({
    this.waivers = const {},
    this.freeAgents = const {},
    this.trades = const {},
  });

  // All Transactions are scored by league id and then team id in the Nested Map
  Map<int, List<Transaction>> waivers = {};
  Map<int, List<Transaction>> freeAgents = {};
  Map<int, List<Trade>> trades = {};

  TransactionsData copyWith({
    Map<int, List<Transaction>>? waivers,
    Map<int, List<Transaction>>? freeAgents,
    Map<int, List<Trade>>? trades,
  }) {
    return TransactionsData(
      waivers: waivers ?? this.waivers,
      freeAgents: freeAgents ?? this.freeAgents,
      trades: trades ?? this.trades,
    );
  }
}
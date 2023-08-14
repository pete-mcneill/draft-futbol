import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsNotifier extends StateNotifier<Transactions> {
  TransactionsNotifier() : super(Transactions());
  void addAllTransactions(var transactions, int leagueId) {
    state.transactions[leagueId] = {};
    for (var transaction in transactions) {
      Transaction _transaction = Transaction.fromJson(transaction);
      try {
        if (state.transactions[leagueId]![transaction['event']] != null) {
          state.transactions[leagueId]![transaction['event']]!
              .add(_transaction);
        } else {
          state.transactions[leagueId]![transaction['event']] = [_transaction];
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void addAllTrades(var trades, int leagueId) {
    state.trades[leagueId] = {};
    for (var transaction in trades) {
      Transaction _transaction = Transaction.fromJson(transaction);
      try {
        if (state.trades[leagueId]![transaction['event']] != null) {
          state.trades[leagueId]![transaction['event']]!.add(_transaction);
        } else {
          state.trades[leagueId]![transaction['event']] = [_transaction];
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class Transactions {
  Transactions() : super();
  Map<int, Map<int, List<Transaction>>> transactions = {};
  Map<int, Map<int, List<Transaction>>> trades = {};
}

class Transaction {
  Transaction(
      {required this.playerInId,
      required this.playerOutId,
      required this.teamId,
      required this.gameweek,
      required this.priority,
      required this.result,
      required this.type,
      this.visible = true});

  final String playerInId;
  final String playerOutId;
  final String teamId;
  final int gameweek;
  final String priority;
  final String result;
  final String type;
  bool visible;

  factory Transaction.fromJson(var transactionData) {
    return Transaction(
        playerInId: transactionData['element_in'].toString(),
        playerOutId: transactionData['element_out'].toString(),
        teamId: transactionData['entry'].toString(),
        gameweek: transactionData['event'],
        priority: transactionData['index'].toString(),
        result: transactionData['result'],
        type: transactionData['kind']);
  }
}

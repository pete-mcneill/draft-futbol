import 'package:draft_futbol/models/transactions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradesNotifier extends StateNotifier<Trades> {
  TradesNotifier() : super(Trades());

  void addAllTrades(var leagueTrades, String leagueId) {
    state.trades[leagueId] = [];
    for (var trade in leagueTrades['trades']) {
      Trade _trade = Trade.fromJson(trade);
      try {
        if (state.trades[leagueId] != null) {
          state.trades[leagueId]!.add(_trade);
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class Trades {
  Trades() : super();
  Map<String, List<Trade>> trades = {};
}

class Trade {
  Trade(
      {required this.players,
      required this.gameweek,
      required this.offeringTeam,
      required this.receivingTeam,
      this.visible = true});

  final List<TradePlayers> players;
  final int offeringTeam;
  final int receivingTeam;
  final int gameweek;
  bool visible;

  factory Trade.fromJson(var tradeData) {
    List<TradePlayers> _players = [];
    for (var set in tradeData['tradeitem_set']) {
      TradePlayers _tradeSet = TradePlayers(
          playerIn: set['element_in'], playerOut: set['element_out']);
      _players.add(_tradeSet);
    }
    return Trade(
        players: _players,
        gameweek: tradeData['event'],
        offeringTeam: tradeData['offered_entry'],
        receivingTeam: tradeData['received_entry']);
  }
}

class TradePlayers {
  TradePlayers({required this.playerIn, required this.playerOut});

  final int playerIn;
  final int playerOut;
}

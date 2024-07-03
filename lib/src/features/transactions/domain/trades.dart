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

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
        type: transactionData['kind'],
        visible: true);
  }
}

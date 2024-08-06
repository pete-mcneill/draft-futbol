import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
// import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../live_data/domain/draft_domains/draft_team.dart';
import '../../domain/trades.dart' as playerTrade;
import '../../domain/trades.dart';
import '../../../../common_widgets/loading.dart';

class Trade extends ConsumerStatefulWidget {
  playerTrade.Trade? transaction;
  DraftPlayer? playerIn;
  DraftPlayer? playerOut;
  DraftTeam? team;
  bool visible;
  Trade(
      {Key? key,
      this.transaction,
      this.playerIn,
      this.playerOut,
      this.team,
      this.visible = true})
      : super(key: key);

  @override
  _TradeState createState() => _TradeState();
}

class _TradeState extends ConsumerState<Trade> {
  Map<int, DraftTeam>? teams;
  Map<int, DraftPlayer>? _players;

  @override
  Widget build(BuildContext context) {
    return Text("Trades");
    // ref.watch(allTrades).when(
    //     loading: () => const Loading(),
    //     error: (err, stack) => Text('Error: $err'),
    //     data: (config) {
    //       int activeLeague = ref.watch(utilsProvider).activeLeagueId!;
    //       teams = ref.read(fplGwDataProvider).teams![activeLeague];
    //       if (ref.read(tradesProvider).trades[activeLeague] != null) {
    //         List<playerTrade.Trade> _trades =
    //             ref.read(tradesProvider).trades[activeLeague]!;
    //         _players = ref.read(fplGwDataProvider).players;
    //         return Scaffold(
    //           appBar: DraftAppBar(
    //             leading: true,
    //             settings: false,
    //           ),
    //           body: RefreshIndicator(
    //             color: Theme.of(context).colorScheme.secondaryContainer,
    //             onRefresh: () async {
    //               ref.refresh(allTrades);
    //             },
    //             child: _trades.isEmpty
    //                 ? const Center(child: Text("No trades processed yet...."))
    //                 : SingleChildScrollView(
    //                     child: Column(children: [
    //                       const SizedBox(
    //                         height: 10,
    //                       ),
    //                       const Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                         children: [
    //                           Expanded(
    //                             flex: 6,
    //                             child: Text(
    //                               "Offered",
    //                               textAlign: TextAlign.center,
    //                             ),
    //                           ),
    //                           Expanded(
    //                             flex: 6,
    //                             child: Text(
    //                               "Requested",
    //                               textAlign: TextAlign.center,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       for (var trade in _trades) ...[
    //                         generateTrade(trade),
    //                         const SizedBox(
    //                           height: 10,
    //                         )
    //                       ],
    //                     ]),
    //                   ),
    //           ),
    //         );
    //       } else {
    //         return Scaffold(
    //             appBar: DraftAppBar(
    //               leading: true,
    //               settings: false,
    //             ),
    //             body: RefreshIndicator(
    //                 color: Theme.of(context).colorScheme.secondaryContainer,
    //                 onRefresh: () async {
    //                   ref.refresh(allTrades);
    //                 },
    //                 child: const Text("No Trades processed yet")));
    //       }
    //     });
  }

  Container generateTrade(playerTrade.Trade trade) {
    DraftTeam offeringTeam = teams!.entries.firstWhere((team) => team.value.entryId == trade.offeringTeam).value;
    DraftTeam receivingTeam = teams!.entries.firstWhere((team) => team.value.entryId == trade.receivingTeam).value;
    return Container(
      // height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
        elevation: 10,
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Text("${offeringTeam.teamName}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))),
                Expanded(
                  child: Column(
                    children: [
                      Text('GW${trade.gameweek.toString()}'),
                      IconButton(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                          icon: const FaIcon(FontAwesomeIcons.rightLeft),
                          onPressed: () {
                            print("Pressed");
                          }),
                    ],
                  ),
                ),
                Expanded(
                    child: Text("${receivingTeam.teamName}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)))
              ],
            ),
            for (var set in trade.players) getPlayers(set),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }

  Row getPlayers(TradePlayers tradeSet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 3,
            child: Text(
              _players![tradeSet.playerIn]!.playerName!,
              textAlign: TextAlign.center,
            )),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 70,
            height: 70,
            child: ClipOval(
              child: Image.network(
                "https://resources.premierleague.com/premierleague/photos/players/110x140/p${_players![tradeSet.playerIn]!.playerCode}.png",
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 70,
            height: 70,
            child: ClipOval(
              child: Image.network(
                "https://resources.premierleague.com/premierleague/photos/players/110x140/p${_players![tradeSet.playerOut]!.playerCode}.png",
              ),
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Text(_players![tradeSet.playerOut]!.playerName!,
                textAlign: TextAlign.center))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

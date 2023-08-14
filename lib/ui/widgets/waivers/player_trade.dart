import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/draft_team.dart';
import '../../../models/trades.dart' as playerTrade;
import '../../../models/trades.dart';
import '../loading.dart';

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
  void initState() {
    super.initState();
  }

  Container generateTrade(playerTrade.Trade trade) {
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
                    child: Text("${teams![trade.offeringTeam]!.teamName}",
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
                    child: Text("${teams![trade.receivingTeam]!.teamName}",
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
  Widget build(BuildContext context) {
    return ref.refresh(allTrades).when(
        loading: () => const Loading(),
        error: (err, stack) => Text('Error: $err'),
        data: (config) {
          int activeLeague = ref.watch(utilsProvider).activeLeagueId!;
          teams = ref.read(fplGwDataProvider).teams![activeLeague];
          if (ref.read(tradesProvider).trades[activeLeague] != null) {
            List<playerTrade.Trade> _trades =
                ref.read(tradesProvider).trades[activeLeague]!;
            _players = ref.read(fplGwDataProvider).players;
            return Scaffold(
              appBar: DraftAppBar(
                leading: true,
                settings: false,
              ),
              body: RefreshIndicator(
                color: Theme.of(context).colorScheme.secondaryContainer,
                onRefresh: () async {
                  ref.refresh(allTrades);
                },
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            "Offered",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            "Requested",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    for (var trade in _trades) ...[
                      generateTrade(trade),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ]),
                ),
              ),
            );
          } else {
            return Scaffold(
                appBar: DraftAppBar(
                  leading: true,
                  settings: false,
                ),
                body: RefreshIndicator(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    onRefresh: () async {
                      ref.refresh(allTrades);
                    },
                    child: Text("No Trades processed yet")));
          }
        });
  }
}

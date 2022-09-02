import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';

class PlMatchesScreen extends ConsumerStatefulWidget {
  const PlMatchesScreen({Key? key}) : super(key: key);

  @override
  _PlMatchesScreenState createState() => _PlMatchesScreenState();
}

class _PlMatchesScreenState extends ConsumerState<PlMatchesScreen> {
  Map<int, DraftPlayer> players = {};
  List elementNames = [];
  @override
  void initState() {
    super.initState();
  }

  Widget createPlMatchWidget(PlMatch match) {
    return Card(
        child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
                    match.homeTeam!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Image.network(
                      "https://resources.premierleague.com/premierleague/badges/70/t${match.homeCode}.png",
                      fit: BoxFit.fill),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    "${match.homeScore} - ${match.awayScore}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 13,
                    maxLines: 2,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Image.network(
                      "https://resources.premierleague.com/premierleague/badges/70/t${match.awayCode}.png",
                      fit: BoxFit.fill),
                ),
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
                    match.awayTeam!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 10,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            children: [for (var stats in match.stats!) getStats(stats)]));
  }

  Widget getStats(var stats) {
    if (stats['h'].length > 0 || stats['a'].length > 0) {
      List homeStats = [];
      List awayStats = [];
      try {
        for (var stat in stats['h']) {
          DraftPlayer player = players[stat['element']]!;
          homeStats
              .add({"playerName": player.playerName, "value": stat['value']});
        }
      } catch (e) {}

      try {
        for (var stat in stats['a']) {
          DraftPlayer player = players[stat['element']]!;
          awayStats
              .add({"playerName": player.playerName, "value": stat['value']});
        }
      } catch (e) {}
      String statDisplay = "";
      for (var statName in elementNames) {
        if (statName['name'] == stats['s']) {
          statDisplay = statName['label'];
        }
      }
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(stats['name'])],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                for (var stats in homeStats)
                  if (stats['value'] > 1)
                    Text("${stats['playerName']}(${stats['value']})")
                  else
                    Text(stats['playerName'])
              ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const <Widget>[
                    VerticalDivider(
                      thickness: 1,
                    ),
                    VerticalDivider(
                      thickness: 1,
                    ),
                  ]),
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                for (var stats in awayStats)
                  if (stats['value'] > 1)
                    Text("${stats['playerName']}(${stats['value']})")
                  else
                    Text(stats['playerName'])
              ]),
            ],
          )
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    // elementNames = Provider.of<StaticDataProvider>(context, listen: true)
    //     .staticData!['element_stats'];
    players = ref.watch(draftPlayersProvider).players;
    Map<String, PlMatch> matches = ref.watch(plMatchesProvider).plMatches!;
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!ref.watch(purchasesProvider).noAdverts!)
            SizedBox(
              height: 120,
              // color: Colors.deepOrange,
              child: FutureBuilder<Widget>(
                future: getBannerWidget(
                    context: context,
                    adSize: AdSize.largeBanner,
                    noAdverts: ref.watch(purchasesProvider).noAdverts!),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    return Column(
                      children: [
                        Center(
                            child: ValueListenableBuilder<Box>(
                          valueListenable: Hive.box('adverts')
                              .listenable(keys: ['adCounter']),
                          builder: (context, box, _) {
                            int adRefresh = box.get('adCounter');
                            adRefresh = 10 - adRefresh;
                            return Text(
                                "Video Advert will appear in $adRefresh refreshes",
                                style: const TextStyle(fontSize: 12));
                          },
                        )),
                        SizedBox(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: snapshot.data,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          for (String matchId in matches.keys)
            createPlMatchWidget(matches[matchId]!)
        ],
      ),
    );
  }
}

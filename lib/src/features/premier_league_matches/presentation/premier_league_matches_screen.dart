import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/bps.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class PlMatchesScreen extends ConsumerStatefulWidget {
  const PlMatchesScreen({Key? key}) : super(key: key);

  @override
  _PlMatchesScreenState createState() => _PlMatchesScreenState();
}

class _PlMatchesScreenState extends ConsumerState<PlMatchesScreen> {
  Map<int, DraftPlayer> players = {};
  List elementNames = [];
  @override
  Widget build(BuildContext context) {
    // elementNames = Provider.of<StaticDataProvider>(context, listen: true)
    //     .staticData!['element_stats'];
    players = ref.watch(premierLeagueControllerProvider).players;
    Map<int, PlMatch> matches =
        ref.watch(premierLeagueControllerProvider).matches;
    return SingleChildScrollView(
      child: Column(
        children: [
          buyaCoffeebutton(context),
          for (int matchId in matches.keys) createMatchWidget(matches[matchId]!)
          // createPlMatchWidget(matches[matchId]!)
        ],
      ),
    );
  }

  createMatchWidget(PlMatch match) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 10,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...getTeam(match)],
          ),
          ...getBonusPoints(match.bpsPlayers, match),
          if (match.started!)
            ExpansionTile(
                title: Container(
                    child: const Center(child: Text("Detailed Stats"))),
                children: [...getStats(match)]),
        ]));
  }

  Widget createPlMatchWidget(PlMatch match) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            children: [...getStats(match)]));
  }

  getBonusPoints(Map<int, List<Bps>> bpsPlayers, PlMatch match) {
    if (match.finished!) {
      List<String> bonusPoints = [];
      for (var stat in match.stats!) {
        if (stat['s'] == 'bonus') {
          var bonusList = [stat['h'], stat['a']].expand((x) => x).toList();
          bonusList.sort((a, b) => b['value'].compareTo(a['value']));
          for (var bonus in bonusList) {
            DraftPlayer player = players[bonus['element']]!;
            bonusPoints.add("${player.playerName}(${bonus['value']})");
          }
        }
      }
      return [
        const Text("Offical Bonus Points",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(children: [
          Text(
            bonusPoints.join(" "),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
        ]),
      ];
    } else if (match.started!) {
      List<String> _bpsPlayers = [];
      for (Bps bpsPlayer in bpsPlayers[3]!) {
        DraftPlayer _player = players[bpsPlayer.element!]!;
        _bpsPlayers.add(_player.playerName! + ("(3)"));
      }
      for (Bps bpsPlayer in bpsPlayers[2]!) {
        DraftPlayer _player = players[bpsPlayer.element!]!;
        _bpsPlayers.add(_player.playerName! + ("(2)"));
      }
      for (Bps bpsPlayer in bpsPlayers[1]!) {
        DraftPlayer _player = players[bpsPlayer.element!]!;
        _bpsPlayers.add(_player.playerName! + ("(1)"));
      }
      return [
        const Text("Live Bonus Points",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(children: [
          Text(_bpsPlayers.join(" "),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w300)),
        ]),
      ];
    } else {
      return [];
    }
  }

  getCardStats(int elementId, int value) {
    DraftPlayer player = players[elementId]!;
    if (value > 1) {
      return Text("${player.playerName}($value)",
          style: const TextStyle(fontWeight: FontWeight.w300));
    } else {
      return Text("${player.playerName}",
          style: const TextStyle(fontWeight: FontWeight.w300));
    }
  }

  Widget getMatchText(PlMatch match) {
    if (!match.started!) {
      var kickoffTime = DateTime.parse(match.kickOffTime!).toUtc();
      var localKickOffTime = kickoffTime.toLocal();
      var formatter = DateFormat('H:ms');
      return Column(
        children: [
          Text(
            "${DateFormat('EEEE').format(localKickOffTime)} ${localKickOffTime.day} ${DateFormat('MMMM').format(localKickOffTime)} ${localKickOffTime.year}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formatter.format(localKickOffTime),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Text(
        "${match.homeScore} - ${match.awayScore}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  List<Column> getStats(PlMatch match) {
    List<Column> widgetStats = [];
    for (var stats in match.stats!) {
      if ((stats['h'].length > 0 || stats['a'].length > 0) &&
          stats['s'] != 'goals_scored' &&
          stats['s'] != 'assists') {
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
        widgetStats.add(Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stats['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  for (var stats in homeStats)
                    if (stats['value'] > 1)
                      Text("${stats['playerName']}(${stats['value']})",
                          style: const TextStyle(fontWeight: FontWeight.w300))
                    else
                      Text(stats['playerName'],
                          style: const TextStyle(fontWeight: FontWeight.w300))
                ]),
                const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      VerticalDivider(
                        thickness: 1,
                      ),
                      VerticalDivider(
                        thickness: 1,
                      ),
                    ]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var stats in awayStats)
                    if (stats['value'] > 1)
                      Text(
                        "${stats['playerName']}(${stats['value']})",
                        style: const TextStyle(fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        stats['playerName'],
                        style: const TextStyle(fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      )
                ]),
              ],
            )
          ],
        ));
      }
    }
    return widgetStats;
  }

  List<Widget> getTeam(PlMatch match) {
    var goals;
    var assists;

    for (var stat in match.stats!) {
      if (stat['s'] == 'goals_scored') {
        goals = stat;
      }
      if (stat['s'] == 'assists') {
        assists = stat;
      }
    }
    return [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Image.asset(
                'assets/images/logos/' + match.homeCode.toString() + '.png',
                height: 40,
                width: 40),
            Text(match.homeShortName!)
          ],
        ),
      ),
      Expanded(
        flex: 8,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 2.0,
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Center(child: getMatchText(match))],
              ),
            ),
            if (match.started! &&
                (!match.finishedProvisional! || !match.finished!))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        shape: BoxShape.circle,
                        // You can use like this way or like the below line
                        //borderRadius: new BorderRadius.circular(30.0),
                        color: Colors.red,
                      )),
                  const Text(
                    "Live",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (goals != null && goals['h'].length != 0)
                        ...getTeamSummaryStat(goals, "Goals", 'h'),
                      if (assists != null && assists['a'].length != 0)
                        ...getTeamSummaryStat(assists, "Assists", 'h'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (goals != null && goals['a'].length != 0)
                        ...getTeamSummaryStat(goals, "Goals", 'a'),
                      if (assists != null && assists['a'].length != 0)
                        ...getTeamSummaryStat(assists, "Assists", 'a'),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
      Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'assets/images/logos/' + match.awayCode.toString() + '.png',
                  height: 40,
                  width: 40),
              Text(match.awayShortName!)
            ],
          )),
    ];
  }

  getTeamSummaryStat(var stats, String statName, String homeOrAway) {
    return [
      Text(statName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          )),
      for (var stat in stats[homeOrAway]!)
        getCardStats(stat['element'], stat['value'])
    ];
  }

  @override
  void initState() {
    super.initState();
  }
}

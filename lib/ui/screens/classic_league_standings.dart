import 'package:badges/badges.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/classic_view/classic_pitch.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../models/Gameweek.dart';

class ClassicLeagueStandings extends ConsumerStatefulWidget {
  const ClassicLeagueStandings({Key? key}) : super(key: key);

  @override
  _ClassicLeagueStandingsState createState() => _ClassicLeagueStandingsState();
}

class _ClassicLeagueStandingsState
    extends ConsumerState<ClassicLeagueStandings> {
  var standings;
  Map<int, DraftTeam> teams = {};
  List<Fixture> fixtures = [];
  var leagueData;
  bool liveBps = false;
  int view = 1;
  late String currentGameweek;
  List<LeagueStanding> staticStandings = [];
  List<LeagueStanding> liveStandings = [];
  List<LeagueStanding> liveBpsStandings = [];
  String activeLeague = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getLeagueStanding(LeagueStanding standing) {
    DraftTeam? team = teams[standing.teamId];
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    return Container(
      height: 50,
      color: rowColor,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClassicPitch(team: team!)));
        },
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  standing.rank.toString(),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                )),
            Expanded(
                flex: 4,
                child: Text(
                  team!.teamName!,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  liveBps
                      ? standing.bpsScore.toString()
                      : standing.gwScore.toString(),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  standing.leaguePoints.toString(),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }

  updateView(index) {
    setState(() {
      view = index!;
    });
  }

  Widget iconsSummary(LeagueStanding standing) {
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    Map<int, DraftPlayer> players = ref.watch(draftPlayersProvider).players;
    DraftTeam? team = teams[standing.teamId]!;
    int goals = 0;
    int assists = 0;
    int cleanSheets = 0;
    for (int _id in team.squad!.keys) {
      if (team.squad![_id]! < 12) {
        DraftPlayer player = players[_id]!;
        for (Match match in player.matches!) {
          for (Stat stat in match.stats!) {
            if (stat.statName == "Goals scored") {
              goals += stat.value!;
            }
            if (stat.statName == "Assists") {
              assists += stat.value!;
            }
            if (stat.statName == "Clean sheets" &&
                (player.position == "DEF" || player.position == "GK")) {
              cleanSheets += stat.value!;
            }
          }
        }
      }
    }
    return Container(
      color: rowColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (goals > 0) ...[
            FaIcon(
              FontAwesomeIcons.futbol,
              color: Theme.of(context).colorScheme.secondary,
            ),
            if (goals > 1)
              Text(goals > 1 ? "x" + goals.toString() : "" + goals.toString(),
                  style: const TextStyle(fontSize: 15))
          ],
          if (assists > 0) ...[
            FaIcon(
              FontAwesomeIcons.adn,
              color: Theme.of(context).colorScheme.secondary,
            ),
            if (assists > 1)
              Text(
                  assists > 1
                      ? "x" + assists.toString()
                      : "" + assists.toString(),
                  style: const TextStyle(fontSize: 15))
          ],
          if (cleanSheets > 0) ...[
            FaIcon(
              FontAwesomeIcons.shieldHalved,
              color: Theme.of(context).colorScheme.secondary,
            ),
            if (cleanSheets > 1)
              Text("x" + cleanSheets.toString(),
                  style: const TextStyle(fontSize: 15))
          ]
          // homeGoals == 0 && homeAssists == 0 && cleanSheets == 0 ?
          // Icon(LineIcons.values['duck']);
        ],
      ),
    );
  }

  Container remainingPlayers(LeagueStanding standing) {
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    DraftTeam? team = teams[standing.teamId]!;
    final String remainingMatches = team.remainingPlayersMatches.toString();
    final String completedMatches = team.completedPlayersMatches.toString();
    final String remainingSubsMatches = team.remainingSubsMatches.toString();
    final String completedSubsMatches = team.completedSubsMatches.toString();
    return Container(
      color: rowColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Tooltip(
            decoration: null,
            showDuration: const Duration(seconds: 3),
            message: "Starting XI: Remaining/Played",
            child: Badge(
                toAnimate: false,
                shape: BadgeShape.square,
                badgeColor: Theme.of(context).chipTheme.backgroundColor!,
                borderRadius: BorderRadius.circular(8),
                badgeContent: Row(
                  children: [
                    const Icon(Icons.people),
                    Text(remainingMatches + "/" + completedMatches,
                        style: const TextStyle(fontSize: 12))
                  ],
                )),
            // Badge(

            // )),
          ),
          Tooltip(
            showDuration: const Duration(seconds: 3),
            message: "Subs: Remaining/Played",
            child: Badge(
                toAnimate: false,
                shape: BadgeShape.square,
                badgeColor: Theme.of(context).chipTheme.backgroundColor!,
                borderRadius: BorderRadius.circular(8),
                badgeContent: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.couch),
                    Text(remainingSubsMatches + "/" + completedSubsMatches,
                        style: const TextStyle(fontSize: 12))
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    Gameweek? gameweek = ref.watch(gameweekProvider);
    activeLeague = ref.watch(utilsProvider).activeLeagueId!;
    staticStandings =
        ref.watch(classicStandingsProvider).staticStandings[activeLeague]!;
    if (gameweek!.gameweekFinished) {
      liveStandings = staticStandings;
      liveBpsStandings = staticStandings;
    } else {
      liveStandings =
          ref.watch(classicStandingsProvider).liveStandings[activeLeague]!;
      liveBpsStandings =
          ref.watch(classicStandingsProvider).liveBpsStandings[activeLeague]!;
    }

    teams = ref.watch(draftTeamsProvider).teams![activeLeague]!;

    currentGameweek = gameweek.currentGameweek;
    String lastGw = (int.parse(currentGameweek) - 1).toString();
    liveBps = ref.watch(utilsProvider).liveBps!;

    bool remainingPlayersView = ref.watch(
        utilsProvider.select((connection) => connection.remainingPlayersView!));
    bool iconsSummaryView = ref.watch(
        utilsProvider.select((connection) => connection.iconSummaryView!));

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!ref.watch(purchasesProvider).noAdverts!)
            Center(
                child: ValueListenableBuilder<Box>(
              valueListenable:
                  Hive.box('adverts').listenable(keys: ['adCounter']),
              builder: (context, box, _) {
                int adRefresh = box.get('adCounter');
                adRefresh = 10 - adRefresh;
                return Text("Video Advert will appear in $adRefresh refreshes",
                    style: const TextStyle(fontSize: 12));
              },
            )),
          if (!gameweek.gameweekFinished)
            ToggleSwitch(
              customWidths: const [120.0, 90.0, 120.0],
              minHeight: 30.0,
              activeBgColors: [
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary]
              ],
              // activeFgColor:
              // Theme.of(context).buttonTheme.colorScheme!.secondary,
              // inactiveBgColor: themeProvider.themeData().cardColor,
              inactiveFgColor: Colors.white,
              initialLabelIndex: view,
              totalSwitches: 2,
              labels: ["GW $lastGw", 'Live'],
              onToggle: (index) => updateView(index),
            ),
          if (!ref.watch(purchasesProvider).noAdverts!)
            SizedBox(
              height: 100,
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
                    return SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: snapshot.data,
                    );
                  }
                },
              ),
            ),
          Container(
            color: Theme.of(context).cardColor,
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    "Team",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "GW",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Pts",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          if (view == 0)
            for (LeagueStanding standing in staticStandings) ...[
              getLeagueStanding(standing),
              if (iconsSummaryView) iconsSummary(standing)
            ]
          else if (view == 1 && !liveBps)
            for (LeagueStanding standing in liveStandings) ...[
              getLeagueStanding(standing),
              if (remainingPlayersView) remainingPlayers(standing),
              if (iconsSummaryView) iconsSummary(standing)
            ]
          else if (view == 1 && liveBps)
            for (LeagueStanding standing in liveBpsStandings) ...[
              getLeagueStanding(standing),
              if (remainingPlayersView) remainingPlayers(standing),
              if (iconsSummaryView) iconsSummary(standing)
            ]
        ],
      ),
    );
  }
}

import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../widgets/adverts/adverts.dart';
import '../widgets/filter_ui.dart';

class LeagueStandings extends ConsumerStatefulWidget {
  const LeagueStandings({Key? key}) : super(key: key);

  @override
  _LeagueStandingsState createState() => _LeagueStandingsState();
}

class _LeagueStandingsState extends ConsumerState<LeagueStandings> {
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
    // if (standing.rank!.isEven) {
    //   rowColor = Theme.of(context).;
    // }
    return Container(
      height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: EdgeInsets.all(0),
        color: rowColor,
        elevation: 10,
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  standing.rank.toString(),
                  style: standing.rank == 1
                      ? const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                )),
            Expanded(
                flex: 4,
                child: Text(
                  team!.teamName!,
                  style: standing.rank == 1
                      ? const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  standing.pointsFor.toString(),
                  style: standing.rank == 1
                      ? const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  standing.leaguePoints.toString(),
                  style: standing.rank == 1
                      ? const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : const TextStyle(fontSize: 14),
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

  List<ChipOptions> getFilterOptions() {
    List<ChipOptions> options = [
      // if (!gameweek!.gameweekFinished)
      ChipOptions(
          label: "Live Bonus Points",
          selected: liveBps,
          onSelected: (bool selected) {
            ref.read(utilsProvider.notifier).updateLiveBps(selected);
          }),
      // if (!gameweek!.gameweekFinished)
      //   ChipOptions(
      //       label: "Remaining Players",
      //       selected: remainingPlayersFilter,
      //       onSelected: (bool selected) {
      //         ref
      //             .read(utilsProvider.notifier)
      //             .setRemainingPlayersView(selected);
      //       }),
      // ChipOptions(
      //     label: "Icons Summary",
      //     selected: iconsSummaryFilter,
      //     onSelected: (bool selected) {
      //       ref.read(utilsProvider.notifier).setIconSummaryView(selected);
      //     })
    ];
    return options;
  }

  @override
  Widget build(BuildContext context) {
    liveBps =
        ref.watch(utilsProvider.select((connection) => connection.liveBps!));
    Gameweek? gameweek = ref.watch(gameweekProvider);
    activeLeague = ref.watch(utilsProvider).activeLeagueId!;
    staticStandings =
        ref.watch(h2hStandingsProvider).staticStandings[activeLeague]!;

    if (gameweek!.gameweekFinished) {
      liveStandings = staticStandings;
      liveBpsStandings = staticStandings;
    } else {
      liveStandings =
          ref.watch(h2hStandingsProvider).liveStandings[activeLeague]!;
      liveBpsStandings =
          ref.watch(h2hStandingsProvider).liveBpsStandings[activeLeague]!;
    }

    teams = ref.watch(draftTeamsProvider).teams![activeLeague]!;
    currentGameweek = gameweek.currentGameweek;
    String lastGw = (int.parse(currentGameweek) - 1).toString();
    liveBps = ref.watch(utilsProvider).liveBps!;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!ref.watch(purchasesProvider).noAdverts!)
            SizedBox(
              height: 120,
              // color: Colors.deepOrange,
              child: FutureBuilder<Widget>(
                future: getBannerWidget(
                    context: context,
                    adSize: AdSize.banner,
                    noAdverts: ref.watch(purchasesProvider).noAdverts!),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: const CircularProgressIndicator());
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
          if (!gameweek.gameweekFinished)
            ToggleSwitch(
              customWidths: const [120.0, 90.0, 120.0],
              minHeight: 30.0,
              activeBgColors: [
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary]
              ],
              inactiveBgColor: Theme.of(context).cardColor,
              inactiveFgColor: Colors.white,
              borderColor: [Theme.of(context).dividerColor],
              borderWidth: 1.0,
              // inactiveFgColor: Colors.white,
              initialLabelIndex: view,
              totalSwitches: 2,
              labels: ["GW $lastGw", 'Live'],
              onToggle: (index) => updateView(index),
            ),
          if (!gameweek.gameweekFinished)
            FilterH2HMatches(options: getFilterOptions()),
          Container(
            // color: Theme.of(context).cardColor,
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
                    "+",
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
            for (LeagueStanding standing in staticStandings)
              getLeagueStanding(standing)
          else if (view == 1 && !liveBps)
            for (LeagueStanding standing in liveStandings)
              getLeagueStanding(standing)
          else if (view == 1 && liveBps)
            for (LeagueStanding standing in liveBpsStandings)
              getLeagueStanding(standing)
        ],
      ),
    );
  }
}

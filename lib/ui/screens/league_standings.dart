import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../models/draft_team.dart';
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
  int? currentGameweek;
  List<LeagueStanding> staticStandings = [];
  List<LeagueStanding> liveStandings = [];
  List<LeagueStanding> liveBpsStandings = [];
  int? activeLeague;

  @override
  Widget build(BuildContext context) {
    liveBps =
        ref.watch(utilsProvider.select((connection) => connection.liveBps!));
    Gameweek? gameweek =
        ref.watch(fplGwDataProvider.select((value) => value.gameweek));
    activeLeague = ref.watch(utilsProvider).activeLeagueId;
    staticStandings = ref.watch(fplGwDataProvider
        .select((value) => value.staticStandings))![activeLeague]!;

    if (gameweek!.gameweekFinished) {
      liveStandings = staticStandings;
      liveBpsStandings = staticStandings;
    } else {
      liveStandings = ref.watch(fplGwDataProvider
          .select((value) => value.liveStandings))![activeLeague]!;
      liveBpsStandings = ref.watch(fplGwDataProvider
          .select((value) => value.bonusStanding))![activeLeague]!;
    }

    teams = ref.watch(
        fplGwDataProvider.select((value) => value.teams))![activeLeague]!;
    currentGameweek = gameweek.currentGameweek;
    String lastGw = (currentGameweek! - 1).toString();
    liveBps = ref.watch(utilsProvider).liveBps!;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buyaCoffeebutton(context),
          if (!gameweek.gameweekFinished)
            ToggleSwitch(
              customWidths: const [120.0, 90.0, 120.0],
              minHeight: 30.0,
              activeFgColor: Colors.black,
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
            child: const Row(
              children: [
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

  @override
  void dispose() {
    super.dispose();
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

  Widget getLeagueStanding(LeagueStanding standing) {
    DraftTeam? team = teams[standing.teamId];
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    // if (standing.rank!.isEven) {
    //   rowColor = Theme.of(context).;
    // }
    return SizedBox(
      height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
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

  @override
  void initState() {
    super.initState();
  }

  updateView(index) {
    setState(() {
      view = index!;
    });
  }
}

import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/classic_view/classic_pitch.dart';
import 'package:draft_futbol/ui/widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../models/draft_team.dart';
import '../widgets/filter_ui.dart';

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
  int? currentGameweek;
  List<LeagueStanding> staticStandings = [];
  List<LeagueStanding> liveStandings = [];
  List<LeagueStanding> liveBpsStandings = [];
  int? activeLeague;

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    Gameweek? gameweek =
        ref.watch(fplGwDataProvider.select((value) => value.gameweek));
    activeLeague = ref.watch(utilsProvider).activeLeagueId;
    staticStandings =
        ref.watch(fplGwDataProvider).staticStandings![activeLeague]!;
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
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buyaCoffeebutton(context),
          if (!gameweek.gameweekFinished)
            ToggleSwitch(
              customWidths: const [120.0, 90.0, 120.0],
              minHeight: 30.0,
              activeBgColors: [
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary],
                [Theme.of(context).buttonTheme.colorScheme!.secondary]
              ],
              activeFgColor: Colors.black,
              inactiveBgColor: Theme.of(context).cardColor,
              inactiveFgColor: Colors.white,
              borderColor: [Theme.of(context).dividerColor],
              borderWidth: 1.0,
              initialLabelIndex: view,
              totalSwitches: 2,
              labels: ["GW $lastGw", 'Live'],
              onToggle: (index) => updateView(index),
            ),
          if (!gameweek.gameweekFinished)
            FilterH2HMatches(options: getFilterOptions()),
          Container(
            color: Theme.of(context).cardColor,
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
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
          else if (view == 1 && !liveBps)
            for (LeagueStanding standing in liveStandings) ...[
              getLeagueStanding(standing),
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
          else if (view == 1 && liveBps)
            for (LeagueStanding standing in liveBpsStandings) ...[
              getLeagueStanding(standing),
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
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
    ];
    return options;
  }

  Widget getLeagueStanding(LeagueStanding standing) {
    DraftTeam? team = teams[standing.teamId];
    Color rowColor = Theme.of(context).cardColor;
    FontWeight weight = FontWeight.normal;
    if (standing.rank == 1) {
      rowColor = Colors.green.shade900;
      weight = FontWeight.bold;
    }
    if (standing.rank == staticStandings.length) {
      rowColor = Colors.red.shade900;
      weight = FontWeight.bold;
    }
    return SizedBox(
      height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
        color: rowColor,
        elevation: 10,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClassicPitch(team: team)));
          },
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    standing.rank.toString(),
                    style:  TextStyle(fontSize: 14, fontWeight: weight),
                    textAlign: TextAlign.left,
                  )),
              Expanded(
                  flex: 4,
                  child: Text(
                    team!.teamName!,
                    style: TextStyle(fontSize: 14, fontWeight: weight),
                    textAlign: TextAlign.left,
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    liveBps
                        ? standing.bpsScore.toString()
                        : standing.gwScore.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: weight),
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    standing.leaguePoints.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: weight),
                    textAlign: TextAlign.center,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget iconsSummary(LeagueStanding standing) {
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    Map<int, DraftPlayer> players =
        ref.watch(fplGwDataProvider.select((value) => value.players!));
    DraftTeam? team = teams[standing.teamId]!;
    int goals = 0;
    int assists = 0;
    int cleanSheets = 0;
    for (int _id in team.squad!.keys) {
      if (team.squad![_id]! < 12) {
        DraftPlayer player = players[_id]!;
        for (PlMatchStats match in player.matches!) {
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

  @override
  void initState() {
    super.initState();
  }

  Container remainingPlayers(LeagueStanding standing) {
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green.shade900;
    }
    if (standing.rank == staticStandings.length) {
      rowColor = Colors.red.shade900;
    }
    DraftTeam? team = teams[standing.teamId]!;
    final String remainingMatches = team.remainingPlayersMatches.toString();
    final String completedMatches = team.completedPlayersMatches.toString();
    final String remainingSubsMatches = team.remainingSubsMatches.toString();
    final String completedSubsMatches = team.completedSubsMatches.toString();
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
        color: rowColor,
        elevation: 10,
        child: Column(
          children: [
            const Text("Remaining Players",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                badges.Badge(
                    toAnimate: false,
                    shape: BadgeShape.square,
                    badgeColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    badgeContent: Row(
                      children: [
                        const Text("Live: ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(team.livePlayers.toString(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black))
                      ],
                    )),
                badges.Badge(
                    toAnimate: false,
                    shape: BadgeShape.square,
                    badgeColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    badgeContent: Row(
                      children: [
                        const Text("Starting XI: ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(team.remainingPlayersMatches.toString(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black))
                      ],
                    )),
                badges.Badge(
                    toAnimate: false,
                    shape: BadgeShape.square,
                    badgeColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    badgeContent: Row(
                      children: [
                        const Text("Subs: ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(team.remainingSubsMatches.toString(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black))
                      ],
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            )
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
}

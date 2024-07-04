import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standing.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LeagueStandings extends ConsumerStatefulWidget {
  const LeagueStandings({Key? key}) : super(key: key);

  @override
  _LeagueStandingsState createState() => _LeagueStandingsState();
}

class _LeagueStandingsState extends ConsumerState<LeagueStandings> {
  Map<int, DraftTeam> teams = {};
  List<Fixture> fixtures = [];
  bool liveBps = false;
  int view = 1;
  int? currentGameweek;
  List<LeagueStanding> staticStandings = [];
  List<LeagueStanding> liveStandings = [];
  List<LeagueStanding> liveBpsStandings = [];
  int? activeLeague;

  Map<int, dynamic> customLeagues = {
    145: {
      1: {
        "iconColour": Colors.green,
        "fontWeight": FontWeight.bold,
        "rowColour": Colors.green.shade900
      },
      7: {
        "iconColour": Colors.black,
        "fontWeight": FontWeight.bold,
        "rowColour": Colors.red.shade900
      },
      8: {
        "iconColour": Colors.black,
        "fontWeight": FontWeight.bold,
        "rowColour": Colors.red.shade900
      }
    },
    687: {
      1: {
        "iconColour": Colors.green,
        "fontWeight": FontWeight.bold,
        "rowColour": Colors.green.shade900
      },
      2: {
        "iconColour": Colors.green,
        "fontWeight": FontWeight.normal,
        "rowColour": Colors.green.shade700
      },
      8: {
        "iconColour": Colors.red,
        "fontWeight": FontWeight.bold,
        "rowColour": Colors.red.shade900
      }
    }
  };


  @override
  Widget build(BuildContext context) {
    // TODO: Move to Controller Logic
    liveBps = ref.watch(appSettingsRepositoryProvider.select((value) => value.bonusPointsEnabled));
        
    Gameweek? gameweek = ref.watch(liveDataRepositoryProvider).gameweek;

    activeLeague = ref.watch(appSettingsRepositoryProvider).activeLeagueId;

    final liveData = ref.watch(liveDataRepositoryProvider);
    staticStandings = ref.watch(draftRepositoryProvider).leagueStandings[activeLeague]!.staticStandings!;

    if (!gameweek!.gameweekFinished) {
      liveStandings = staticStandings;
      liveBpsStandings = staticStandings;
    } else {
      liveStandings = ref.watch(draftRepositoryProvider.select((value) => value.leagueStandings))[activeLeague]!.liveStandings!;
      liveBpsStandings = ref.watch(draftRepositoryProvider.select((value) => value.leagueStandings))[activeLeague]!.liveBpsStandings!;
    }
    teams = ref.watch(draftRepositoryProvider).teams;

    String lastGw = (gameweek.currentGameweek - 1).toString();
    liveBps = ref.watch(appSettingsRepositoryProvider.select((value) => value.bonusPointsEnabled));



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
          Container(
            // color: Theme.of(context).cardColor,
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
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
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    getLeagueStanding(staticStandings[index]),
                separatorBuilder: (context, index) => const Divider(
                      height: 0.5,
                      color: Colors.grey,
                    ), // here u can customize the space.
                itemCount: liveStandings.length)
          else if (view == 1 && !liveBps)
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    getLeagueStanding(liveStandings[index]),
                separatorBuilder: (context, index) => const Divider(
                      height: 0.5,
                      color: Colors.grey,
                    ), // here u can customize the space.
                itemCount: liveStandings.length)
          // for (LeagueStanding standing in liveStandings)
          //   getLeagueStanding(standing)
          else if (view == 1 && liveBps)
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    getLeagueStanding(liveBpsStandings[index]),
                separatorBuilder: (context, index) => const Divider(
                      height: 0.5,
                      color: Colors.grey,
                    ), // here u can customize the space.
                itemCount: liveStandings.length)
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getTeamRank(int ranking) {
    int leagueSize = teams.length;
    // if (ranking == 1 || ranking == leagueSize || ranking == leagueSize - 1) {
    //   if(ranking == 1) {
    //   return IconButton(
    //   // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
    //   color: Colors.yellow,
    //   icon: FaIcon(FontAwesomeIcons.crown), onPressed: () {  },
    //  );
    //   // return CircleAvatar(
    //   //   backgroundColor: ranking == 1 ? Colors.yellow : Colors.red,
    //   //   child: Text(ranking.toString(), style: TextStyle(color: Colors.black),),
    //   // );
    // } else {
    //   return CircleAvatar(
    //     backgroundColor: Colors.red,
    //     child: Text(ranking.toString(), style: const TextStyle(color: Colors.black)),
    //   );
    // }
    // } else {
    return Text(
      ranking.toString(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
    // }
  }

  // Widget getBaguleyTeamRanks(int ranking) {

  // }

  // List<ChipOptions> getFilterOptions() {
  //   List<ChipOptions> options = [
  //     // if (!gameweek!.gameweekFinished)
  //     ChipOptions(
  //         label: "Live Bonus Points",
  //         selected: liveBps,
  //         onSelected: (bool selected) {
  //           ref.read(utilsProvider.notifier).updateLiveBps(selected);
  //         }),
  //     // if (!gameweek!.gameweekFinished)
  //     //   ChipOptions(
  //     //       label: "Remaining Players",
  //     //       selected: remainingPlayersFilter,
  //     //       onSelected: (bool selected) {
  //     //         ref
  //     //             .read(utilsProvider.notifier)
  //     //             .setRemainingPlayersView(selected);
  //     //       }),
  //     // ChipOptions(
  //     //     label: "Icons Summary",
  //     //     selected: iconsSummaryFilter,
  //     //     onSelected: (bool selected) {
  //     //       ref.read(utilsProvider.notifier).setIconSummaryView(selected);
  //     //     })
  //   ];
  //   return options;
  // }




  Widget getLeagueStanding(LeagueStanding standing) {
    DraftTeam? team = teams[standing.teamId];
    Color rowColor = Theme.of(context).cardColor;
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }
    if (standing.rank == staticStandings.length) {
      rowColor = Colors.red.shade900;
    }

    if(customLeagues[activeLeague]?[standing.rank!]?["rowColour"] != null){
      rowColor = customLeagues[activeLeague]?[standing.rank!]?["rowColour"];
    }

    FaIcon icon = FaIcon(
      FontAwesomeIcons.solidCircle,
      color: Colors.grey,
    );
    
    if (standing.rank! > standing.lastRank!) {
      Color iconColour = Colors.redAccent;
      icon = FaIcon(
        FontAwesomeIcons.arrowDown,
        color: iconColour,

      );
    }
    if(standing.rank! < standing.lastRank!) {
       Color iconColour = standing.rank == 1 ? Colors.black : Colors.green;
      // if(customLeagues[activeLeague]?[standing.rank!]?["iconColour"] != null){
      //   iconColour = customLeagues[activeLeague]?[standing.rank!]?["iconColour"];
      // }
      icon = FaIcon(
        FontAwesomeIcons.arrowUp,
        color: iconColour,
      );
    }

    return SizedBox(
      height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
        color: rowColor,
        elevation: 10,
        child: Row(
          children: [
            Expanded(flex: 1, child: getTeamRank(standing.rank!)),
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: icon,
                    onPressed: () {}),
              ),
            ),
            Expanded(
                flex: 4,
                child: Text(
                  team!.teamName!,
                  style: TextStyle(fontSize: 14, fontWeight: customLeagues[activeLeague]?[standing.rank!]?["fontWeight"] ?? FontWeight.normal),
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
                      : TextStyle(fontSize: 14, fontWeight: customLeagues[activeLeague]?[standing.rank!]?["fontWeight"] ?? FontWeight.normal),
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
                      : TextStyle(fontSize: 14, fontWeight: customLeagues[activeLeague]?[standing.rank!]?["fontWeight"] ?? FontWeight.normal),
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

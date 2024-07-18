import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:draft_futbol/src/features/league_standings/application/league_standings_controller.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/league_standings_controller.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standing.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/classic_view/classic_pitch.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../live_data/domain/draft_domains/draft_team.dart';

class ClassicLeagueStandings extends ConsumerStatefulWidget {
  final int leagueId;
  const ClassicLeagueStandings({Key? key, required this.leagueId}) : super(key: key);

  @override
  _ClassicLeagueStandingsState createState() => _ClassicLeagueStandingsState();
}


class _ClassicLeagueStandingsState extends ConsumerState<ClassicLeagueStandings> {
  Map<int, DraftTeam> teams = {};
  List<Fixture> fixtures = [];
  bool liveBps = false;
  int view = 1;
  List<LeagueStanding> staticStandings = [];
  List<LeagueStanding> liveStandings = [];
  List<LeagueStanding> liveBpsStandings = [];
  Color? rowColor;
  Color? secondaryColor;
  Map<int, DraftPlayer> players = {};

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    liveBps = ref.watch(appSettingsRepositoryProvider).bonusPointsEnabled;
    Gameweek? gameweek = ref.watch(leagueStandingsScreenControllerProvider.notifier).gameweek;
    players = ref.watch(premierLeagueControllerProvider.select((value) => value.players));
    DraftRepository repo = ref.watch(draftRepositoryProvider);
    staticStandings = ref.watch(draftDataControllerProvider).leagueStandings[widget.leagueId]!.staticStandings!;
    liveStandings = ref.watch(draftDataControllerProvider).leagueStandings[widget.leagueId]!.liveStandings!; 
    liveBpsStandings = ref.watch(draftDataControllerProvider).leagueStandings[widget.leagueId]!.liveBpsStandings!; 
    // TODO Screen Controllers are not correct but work for now...
    teams = ref.watch(draftDataControllerProvider).teams;
    String lastGw = ( gameweek.currentGameweek - 1).toString();

    rowColor = Theme.of(context).cardColor;
    secondaryColor = Theme.of(context).colorScheme.secondaryContainer;

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
              getLeagueStanding(standing, context),
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
          else if (view == 1 && !liveBps)
            for (LeagueStanding standing in liveStandings) ...[
              getLeagueStanding(standing, context),
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
          else if (view == 1 && liveBps)
            for (LeagueStanding standing in liveBpsStandings) ...[
              getLeagueStanding(standing, context),
              if (!gameweek.gameweekFinished) remainingPlayers(standing),
              const SizedBox(
                height: 5,
              ),
            ]
        ],
      ),
    );
  }

  Widget getLeagueStanding(LeagueStanding standing, BuildContext context) {
    DraftTeam? team = teams[standing.teamId];
    FontWeight weight = FontWeight.normal;
    Color customRowColor = rowColor!;
    if (standing.rank == 1) {
      customRowColor = Colors.green.shade900;
      weight = FontWeight.bold;
    }
    if (standing.rank == staticStandings.length) {
      customRowColor = Colors.red.shade900;
      weight = FontWeight.bold;
    }
    
    return SizedBox(
      height: 50,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: const EdgeInsets.all(0),
        color: customRowColor,
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
    if (standing.rank == 1) {
      rowColor = Colors.green;
    }

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
              color: secondaryColor,
            ),
            if (goals > 1)
              Text(goals > 1 ? "x" + goals.toString() : "" + goals.toString(),
                  style: const TextStyle(fontSize: 15))
          ],
          if (assists > 0) ...[
            FaIcon(
              FontAwesomeIcons.adn,
              color: secondaryColor,
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
              color: secondaryColor,
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
    Color customRowColor = rowColor!;
    if (standing.rank == 1) {
      customRowColor = Colors.green.shade900;
    }
    if (standing.rank == staticStandings.length) {
      customRowColor = Colors.red.shade900;
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
        color: customRowColor,
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
                    badgeColor:secondaryColor!,
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
                    badgeColor: secondaryColor!,
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
                    badgeColor: secondaryColor!,
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

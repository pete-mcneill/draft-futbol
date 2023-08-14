import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

import '../../../models/draft_team.dart';

class H2hMatchPreview extends ConsumerStatefulWidget {
  final DraftTeam homeTeam;
  final DraftTeam awayTeam;
  const H2hMatchPreview(
      {Key? key, required this.homeTeam, required this.awayTeam})
      : super(key: key);

  @override
  _H2hMatchPreviewState createState() => _H2hMatchPreviewState();
}

class _H2hMatchPreviewState extends ConsumerState<H2hMatchPreview> {
  bool liveBonus = false;

  Widget iconsSummary(int goals, int assists, int cleanSheets) {
    return Row(
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
    );
  }

  List<Expanded> getTeamAndScores(
      String bonusScore, String score, String teamName, String team) {
    Expanded scoreWidget = Expanded(
      flex: 1,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: AutoSizeText(
                  liveBonus ? bonusScore : score,
                  style: const TextStyle(fontFamily: 'Inter-Bold'),
                  minFontSize: 20,
                  maxLines: 1,
                ),
              ),
            )
          ]),
    );

    Expanded teamWidget = Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: AutoSizeText(
                teamName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
                minFontSize: 10,
                maxLines: 2,
              ),
            ),
          ),
          // if (remainingPlayersView)
          //   remainingPlayers(remainingMatchesAway, completedMatchesAway,
          //       remainingSubsMatchesAway, completedSubsMatchesAway),
          // if (iconsSummaryView)
          //   iconsSummary(awayGoals, awayAssists, awayCleanSheets)
        ],
      ),
    );
    if (team == "home") {
      return [teamWidget, scoreWidget];
    } else {
      return [scoreWidget, teamWidget];
    }
  }

  Expanded getRemainingPlayers(DraftTeam homeTeam, DraftTeam awayTeam) {
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text("Live",
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
            Expanded(
              child: Text("${homeTeam.livePlayers} - ${awayTeam.livePlayers}",
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const Text(
              "Starting XI",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            Text(
                "${homeTeam.remainingPlayersMatches} - ${awayTeam.remainingPlayersMatches}",
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text("Subs",
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
            Text(
                "${homeTeam.remainingSubsMatches} - ${awayTeam.remainingSubsMatches}",
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
            // Expanded(
            //     child: VerticalDivider(
            //   thickness: 1,
            // )),
            // Expanded(
            //     child: VerticalDivider(
            //   thickness: 1,
            // )),
          ]),
    );
  }

  getTeamSummaryStats(DraftTeam team, Map<int, DraftPlayer> players) {
    int goals = 0;
    int assists = 0;
    int cleanSheets = 0;
    int bonusPoints = 0;
    int topPlayerPoints = 0;
    DraftPlayer? topPlayer;
    for (int _id in team.squad!.keys) {
      if (team.squad![_id]! < 12) {
        DraftPlayer player = players[_id]!;
        int score = 0;
        for (PlMatchStats match in player.matches!) {
          for (Stat stat in match.stats!) {
            score += stat.fantasyPoints!;
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
            if (stat.statName == "Bonus") {
              bonusPoints += stat.value!;
            }
          }
        }
        if (score > topPlayerPoints) {
          topPlayer = player;
          topPlayerPoints = score;
        }
      }
    }
    return {
      "goals": goals,
      "assists": assists,
      "cleanSheets": cleanSheets,
      "bonus": bonusPoints,
      "topPlayer": topPlayer,
      "topPlayerPoints": topPlayerPoints
    };
  }

  getMatchSummary(
      DraftTeam homeTeam, DraftTeam awayTeam, Map<int, DraftPlayer> players) {
    String topPlayerName = '';
    String topPlayerTeam = '';
    String topPoints = '';
    DraftPlayer topPlayer;
    var homeStats = getTeamSummaryStats(homeTeam, players);
    var awayStats = getTeamSummaryStats(awayTeam, players);
    if (homeStats['topPlayerPoints'] == awayStats['topPlayerPoints']) {
      topPlayerName = "Multiple Players";
      topPlayerTeam = '';
      topPoints = homeStats['topPlayerPoints'].toString();
    } else if (homeStats['topPlayerPoints'] < awayStats['topPlayerPoints']) {
      topPlayerName = awayStats['topPlayer'].playerName!;
      topPlayerTeam = awayTeam.teamName!;
      topPoints = awayStats['topPlayerPoints'].toString();
    } else {
      topPlayerName = homeStats['topPlayer'].playerName!;
      topPlayerTeam = homeTeam.teamName!;
      topPoints = homeStats['topPlayerPoints'].toString();
    }
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          const Text("Top Player",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          Text(
            topPlayerName + "($topPoints)",
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(topPlayerTeam,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          const Text("Goals",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(homeStats['goals'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
              const Text(" - "),
              Text(awayStats['goals'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
            ],
          ),
          const Text("Assists",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(homeStats['assists'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
              const Text(" - "),
              Text(awayStats['assists'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
            ],
          ),
          const Text("Clean Sheets",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(homeStats['cleanSheets'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
              const Text(" - "),
              Text(awayStats['cleanSheets'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
            ],
          ),
          const Text("Bonus Points",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(homeStats['bonus'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)),
              const Text(" - "),
              Text(awayStats['bonus'].toString(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<int, DraftPlayer> players =
        ref.watch(fplGwDataProvider.select((data) => data.players!));
    liveBonus = ref.watch(utilsProvider).liveBps!;
    bool gameweekFinished = ref.watch(
        fplGwDataProvider.select((data) => data.gameweek!.gameweekFinished));

    final String score1 = widget.homeTeam.points.toString();
    final String score2 = widget.awayTeam.points.toString();
    final String bonusScore1 = widget.homeTeam.bonusPoints.toString();
    final String bonusScore2 = widget.awayTeam.bonusPoints.toString();
    final String homeTeam = widget.homeTeam.teamName.toString();
    final String awayTeam = widget.awayTeam.teamName.toString();

    // ref
    //     .read(fixturesProvider)
    //     .fixtures[activeLeague]![gameweek!.currentGameweek];
    // teams = {};
    // ref.watch(fplGwDataProvider.select((data) => data.teams))[activeLeague];

    Row remainingPlayers(String remainingXi, String completedXi,
        String remainingSubs, String completedSubs) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Tooltip(
            decoration: null,
            showDuration: const Duration(seconds: 3),
            message: "Starting XI: Remaining/Played",
            child: badges.Badge(
                toAnimate: false,
                shape: BadgeShape.square,
                badgeColor: Theme.of(context).chipTheme.backgroundColor!,
                borderRadius: BorderRadius.circular(8),
                badgeContent: Row(
                  children: [
                    const Icon(Icons.people),
                    Text(remainingXi + "/" + completedXi,
                        style: const TextStyle(fontSize: 12))
                  ],
                )),
            // Badge(

            // )),
          ),
          Tooltip(
            showDuration: const Duration(seconds: 3),
            message: "Subs: Remaining/Played",
            child: badges.Badge(
                toAnimate: false,
                shape: BadgeShape.square,
                badgeColor: Theme.of(context).chipTheme.backgroundColor!,
                borderRadius: BorderRadius.circular(8),
                badgeContent: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.couch),
                    Text(remainingSubs + "/" + completedSubs,
                        style: const TextStyle(fontSize: 12))
                  ],
                )),
          )
        ],
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      shadowColor: Colors.transparent,
      elevation: 4,
      child: IntrinsicHeight(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                gameweekFinished
                    ? const Center(
                        child: Text(
                          "Summary",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Remaining Players",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  ...getTeamAndScores(bonusScore1, score1, homeTeam, "home"),
                  gameweekFinished
                      ? getMatchSummary(
                          widget.homeTeam, widget.awayTeam, players)
                      : getRemainingPlayers(widget.homeTeam, widget.awayTeam),
                  ...getTeamAndScores(bonusScore2, score2, awayTeam, "away")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

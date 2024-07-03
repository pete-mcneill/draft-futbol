

import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen_controller.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadToHeadSummary extends ConsumerWidget {
  HeadToHeadSummary({Key? key, required this.homeTeam, required this.awayTeam}) : super(key: key);
  final DraftTeam homeTeam;
  final DraftTeam awayTeam;

  List<Expanded> getTeamAndScores(
      DraftTeam team, String homeOrAway) {
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
                   team.points.toString(),
                  // liveBonus ? team.bonusPoints.toString() : team.points.toString(),
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
                team.teamName!,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
                minFontSize: 10,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
    if (homeOrAway == "home") {
      return [teamWidget, scoreWidget];
    } else {
      return [scoreWidget, teamWidget];
    }
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
          const Text("Bonus Removed TEST",
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
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(headToHeadScreenControllerProvider);
    final headToHeadScreenController = ref.watch(headToHeadScreenControllerProvider.notifier);
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
                    Center(
                        child: Text(
                           headToHeadScreenController.gameweekFinished() 
                           ? "Summary"
                           : "Remaining Players",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  ...getTeamAndScores(homeTeam, "home"),
                  if (headToHeadScreenController.gameweekFinished())
                    getMatchSummary(
                        homeTeam, awayTeam, headToHeadScreenController.premierLeagueDataRepository.players)
                  else
                    getRemainingPlayers(homeTeam, awayTeam),
                  ...getTeamAndScores(awayTeam, "away")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
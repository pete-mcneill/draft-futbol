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

  @override
  Widget build(BuildContext context) {
    Map<int, DraftPlayer> players = ref.watch(draftPlayersProvider).players;
    int homeGoals = 0;
    int homeAssists = 0;
    int homeCleanSheets = 0;
    for (int _id in widget.homeTeam.squad!.keys) {
      if (widget.homeTeam.squad![_id]! < 12) {
        DraftPlayer player = players[_id]!;
        for (Match match in player.matches!) {
          for (Stat stat in match.stats!) {
            if (stat.statName == "Goals scored") {
              homeGoals += stat.value!;
            }
            if (stat.statName == "Assists") {
              homeAssists += stat.value!;
            }
            if (stat.statName == "Clean sheets" &&
                (player.position == "DEF" || player.position == "GK")) {
              homeCleanSheets += stat.value!;
            }
          }
        }
      }
    }
    int awayGoals = 0;
    int awayAssists = 0;
    int awayCleanSheets = 0;
    for (int _id in widget.awayTeam.squad!.keys) {
      if (widget.awayTeam.squad![_id]! < 12) {
        DraftPlayer player = players[_id]!;
        for (Match match in player.matches!) {
          for (Stat stat in match.stats!) {
            if (stat.statName == "Goals scored") {
              awayGoals += stat.value!;
            }
            if (stat.statName == "Assists") {
              awayAssists += stat.value!;
            }
            if (stat.statName == "Clean sheets" &&
                (player.position == "DEF" || player.position == "GK")) {
              awayCleanSheets += stat.value!;
            }
          }
        }
      }
    }
    bool liveBonus = ref.watch(utilsProvider).liveBps!;
    final String score1 = widget.homeTeam.points.toString();
    final String score2 = widget.awayTeam.points.toString();
    final String bonusScore1 = widget.homeTeam.bonusPoints.toString();
    final String bonusScore2 = widget.awayTeam.bonusPoints.toString();
    final String homeTeam = widget.homeTeam.teamName.toString();
    final String awayTeam = widget.awayTeam.teamName.toString();
    final String homeManager = widget.homeTeam.managerName.toString();
    final String awayManager = widget.awayTeam.managerName.toString();
    final String remainingMatchesHome =
        widget.homeTeam.remainingPlayersMatches.toString();
    final String completedMatchesHome =
        widget.homeTeam.completedPlayersMatches.toString();
    final String remainingMatchesAway =
        widget.awayTeam.remainingPlayersMatches.toString();
    final String completedMatchesAway =
        widget.awayTeam.completedPlayersMatches.toString();
    final String remainingSubsMatchesHome =
        widget.homeTeam.remainingSubsMatches.toString();
    final String completedSubsMatchesHome =
        widget.homeTeam.completedSubsMatches.toString();
    final String remainingSubsMatchesAway =
        widget.awayTeam.remainingSubsMatches.toString();
    final String completedSubsMatchesAway =
        widget.awayTeam.completedSubsMatches.toString();
    bool remainingPlayersView = ref.watch(
        utilsProvider.select((connection) => connection.remainingPlayersView!));
    bool iconsSummaryView = ref.watch(
        utilsProvider.select((connection) => connection.iconSummaryView!));

    Row remainingPlayers(String remainingXi, String completedXi,
        String remainingSubs, String completedSubs) {
      return Row(
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
            child: Badge(
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

    return Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        child: AutoSizeText(
                          homeTeam,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: AutoSizeText(
                          homeManager,
                          style: const TextStyle(fontSize: 15),
                          minFontSize: 10,
                          maxLines: 2,
                        ),
                      ),
                      if (remainingPlayersView)
                        remainingPlayers(
                            remainingMatchesHome,
                            completedMatchesHome,
                            remainingSubsMatchesHome,
                            completedSubsMatchesHome),
                      if (iconsSummaryView)
                        iconsSummary(homeGoals, homeAssists, homeCleanSheets)
                    ]),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: AutoSizeText(
                        liveBonus ? bonusScore1 : score1,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        minFontSize: 10,
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Expanded(
                          child: VerticalDivider(
                        thickness: 1,
                      )),
                      Expanded(
                          child: VerticalDivider(
                        thickness: 1,
                      )),
                    ]),
              ),
              Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        child: AutoSizeText(
                          liveBonus ? bonusScore2 : score2,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          minFontSize: 10,
                          maxLines: 2,
                        ),
                      )
                    ]),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: AutoSizeText(
                        awayTeam,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: AutoSizeText(
                        awayManager,
                        style: const TextStyle(fontSize: 15),
                        minFontSize: 10,
                        maxLines: 2,
                      ),
                    ),
                    if (remainingPlayersView)
                      remainingPlayers(
                          remainingMatchesAway,
                          completedMatchesAway,
                          remainingSubsMatchesAway,
                          completedSubsMatchesAway),
                    if (iconsSummaryView)
                      iconsSummary(awayGoals, awayAssists, awayCleanSheets)
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

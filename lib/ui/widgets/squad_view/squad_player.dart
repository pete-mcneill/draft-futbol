import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SquadPlayer extends ConsumerStatefulWidget {
  DraftPlayer player;
  SquadPlayer({Key? key, required this.player}) : super(key: key);

  @override
  _SquadPlayerState createState() => _SquadPlayerState();
}

class _SquadPlayerState extends ConsumerState<SquadPlayer> {
  late Map<String, PlMatch> matches;

  List<Widget> getPlayerFixtures() {
    List<Widget> fixtures = [];
    for (Match _match in widget.player.matches!) {
      PlMatch _plMatch = matches[_match.matchId.toString()]!;
      if (!_plMatch.started!) {
        if (_plMatch.homeTeamId == widget.player.teamId) {
          fixtures.add(
            AutoSizeText.rich(
              TextSpan(text: "${_plMatch.awayShortName}(H)"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  // color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
              minFontSize: 7,
              maxLines: 1,
              maxFontSize: 10,
            ),
          );
        } else {
          fixtures.add(
            AutoSizeText.rich(
              TextSpan(text: "${_plMatch.homeShortName}(A)"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  // color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
              minFontSize: 7,
              maxLines: 1,
              maxFontSize: 10,
            ),
          );
        }
      }
    }
    return fixtures;
  }

  @override
  Widget build(BuildContext context) {
    // matches = ref.watch(plMatchesProvider).plMatches!;
    String playerImage;
    // Store team metadata
    PlTeam team =
        ref.watch(plTeamsProvider).plTeams[widget.player.teamId.toString()]!;
    if (widget.player.position == "GK") {
      playerImage =
          'assets/images/kits/' + team.code.toString() + '-keeper.png';
    } else {
      playerImage =
          'assets/images/kits/' + team.code.toString() + '-outfield.png';
    }
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 50,
          maxWidth: MediaQuery.of(context).size.width / 5,
          maxHeight: MediaQuery.of(context).size.height / 6,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 6,
          child: ListView(
            padding: const EdgeInsets.only(top: 0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      playerImage,
                      height: (MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height) /
                          15,
                    ),
                    Container(
                      constraints: BoxConstraints(minHeight: 50, minWidth: 100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        // border: if(!bonus && !liveBonus) Border.all(),
                        // boxShadow: [
                        //   if (bonus &&
                        //       (liveBonus || matchesFinished) &&
                        //       !widget.subModeEnabled)
                        //     BoxShadow(
                        //       color: bonusColour,
                        //       spreadRadius: 5.0,
                        //       blurRadius: 7.5,
                        //       offset: const Offset(0.0, 0.0),
                        //     ),
                        // ],
                      ),
                      child: Card(
                        // color: Colors.yellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        elevation: 10,
                        // margin: const EdgeInsets.all(2.0),
                        // padding: const EdgeInsets.all(3.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText.rich(
                              TextSpan(text: widget.player.playerName),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                // color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              minFontSize: 10,
                              maxLines: 2,
                              maxFontSize: 11,
                            ),
                            // Column(children: [
                            //   Column(children: getPlayerFixtures()),
                            // ]),
                            // if (matchesStarted)
                            //   Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         AutoSizeText.rich(
                            //           TextSpan(
                            //               text: calculatePlayerScore()
                            //                   .toString()),
                            //           textAlign: TextAlign.center,
                            //           style: const TextStyle(
                            //               fontSize: 14,
                            //               // color: Theme.of(context).accentColor,
                            //               fontWeight: FontWeight.bold),
                            //           minFontSize: 7,
                            //           maxLines: 1,
                            //           maxFontSize: 11,
                            //         ),
                            //       ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

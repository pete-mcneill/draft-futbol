import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/baguley-features/models/baguley_draft_player.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaguleyPlayer extends ConsumerStatefulWidget {
  BaguleyDraftPlayer player;
  bool highlighted;
  bool subEnabled;
  BaguleyPlayer({Key? key, required this.player, required this.highlighted, required this.subEnabled}) : super(key: key);

  @override
  _BaguleyPlayerState createState() => _BaguleyPlayerState();
}

class _BaguleyPlayerState extends ConsumerState<BaguleyPlayer> {
  bool matchesStarted = false;
  bool matchesFinished = false;
  bool liveBonus = false;
  // late Map<String, PlMatch> matches;


  String calculatePlayerScore() {
    int playerScore = 0;
    for (Match _match in widget.player.matches!) {
      for (Stat stat in _match.stats!) {
          playerScore += stat.fantasyPoints!.toInt();
      }
    }
    return playerScore.toString();
  }

  @override
  Widget build(BuildContext context) {
    Color bonusColour = Theme.of(context).canvasColor;
    // matches = ref.watch(plMatchesProvider).plMatches!;
    bool bonus = false;
    // liveBonus = ref.watch(utilsProvider).liveBps!;
    for (Match match in widget.player.matches!) {
      for (Stat stat in match.stats!) {
        if (stat.statName == "Bonus") {
          if (stat.value == 3) {
            bonusColour = const Color(0xFFd4af37);
            bonus = true;
          } else if (stat.value == 2) {
            bonusColour = const Color(0xFFc0c0c0);
            bonus = true;
          } else if (stat.value == 1) {
            bonusColour = const Color(0xFFcd7f32);
            bonus = true;
          }
        }
      }
    }
    String playerImage;
    // Store team metadata
    // PlTeam team =
    //     ref.watch(plTeamsProvider).plTeams[widget.player.teamId.toString()]!;
    if (widget.player.position == "GK") {
      playerImage =
          'assets/images/historic_kits/' + widget.player.teamId.toString() + '-keeper.png';
    } else {
      playerImage =
          'assets/images/historic_kits/' + widget.player.teamId.toString() + '-outfield.png';
    }
    Color backgroundColor;
    if(widget.subEnabled){
      backgroundColor = Colors.grey;
    }
    if(widget.highlighted){
      backgroundColor = Colors.green;
    }
    return Container(
      
      child: ConstrainedBox(
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
                  color: widget.highlighted ? Colors.red : null,
                  child: Column(
                    children: [
                      Image.asset(
                        playerImage,
                        height: (MediaQuery.of(context).size.height -
                                AppBar().preferredSize.height) /
                            15,
                      ),
                      Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        // border: !bonus && !liveBonus ? Border.all() : null,
                        boxShadow: [
                          bonus
                              ? BoxShadow(
                                  color: bonusColour,
                                  spreadRadius: 10.0,
                                  blurRadius: 5.0,
                                  offset: const Offset(0.0, 0.0),
                                )
                              : BoxShadow(
                                  color: bonusColour,
                                  blurRadius: 0.0,
                                  offset: const Offset(0.0, 0.0),
                                )
                        ],
                        color: Theme.of(context).canvasColor),
                    constraints: const BoxConstraints(
                        minWidth: 11, maxWidth: 110, minHeight: 45),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText.rich(
                          TextSpan(text: widget.highlighted ? "Highlighted" : widget.player.playerName),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            // color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                          maxFontSize: 11,
                        ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText.rich(
                                  TextSpan(text: calculatePlayerScore()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      // color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.bold),
                                  minFontSize: 7,
                                  maxLines: 1,
                                  maxFontSize: 11,
                                ),
                              ]),
                      ],
                    ),
                  ),
                    ],
                  ),
                ),
                
              ],
            ),
          )),
    );
  }
}

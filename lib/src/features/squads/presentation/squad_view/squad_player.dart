import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
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


  @override
  Widget build(BuildContext context) {
    // matches = ref.watch(plMatchesProvider).plMatches!;
    String playerImage;
    // Store team metadata
    PlTeam team = ref.read(premierLeagueDataRepositoryProvider.select((value) => value.teams))[
        widget.player.teamId]!;
    if (widget.player.position == "GK") {
      playerImage =
          'assets/images/kits/' + team.code.toString() + '-keeper.png';
    } else {
      playerImage =
          'assets/images/kits/' + team.code.toString() + '-outfield.png';
    }
    double pitchWidth = MediaQuery.of(context).size.width > 1000
        ? 1000
        : MediaQuery.of(context).size.width;
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 50,
          maxWidth: pitchWidth / 5,
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
                      constraints:
                          const BoxConstraints(minHeight: 50, minWidth: 100),
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
                            Column(children: [
                              for (var fixture
                                  in widget.player.gameweekFixtures!)
                                AutoSizeText.rich(
                                  TextSpan(text: fixture.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      // color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.bold),
                                  minFontSize: 7,
                                  maxLines: 1,
                                  maxFontSize: 10,
                                ),
                            ]),
                  
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

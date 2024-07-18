import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerPopup extends ConsumerStatefulWidget {
  DraftPlayer player;
  PlayerPopup({Key? key, required this.player}) : super(key: key);

  @override
  _PlayerPopupState createState() => _PlayerPopupState();
}

class _PlayerPopupState extends ConsumerState<PlayerPopup> {
  bool liveBonus = false;
  Map<int, PlMatch>? livePlMatches;
  @override
  void initState() {
    super.initState();
    livePlMatches = ref.read(premierLeagueControllerProvider).matches;
  }

  List<Widget> getMatchStats() {
    List<Widget> widgets = [];
    if (widget.player.matches!.isEmpty) {
      return [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text("Blank GW",
                    style: TextStyle(fontFamily: "Inter-SemiBold")),
                Text("No Matches", style: TextStyle(fontFamily: "Inter-Thin"))
              ],
            )
          ],
        )
      ];
    } else {
      for (PlMatchStats _match in widget.player.matches!) {
        int? matchId = _match.matchId;
        String matchTeams =
            "${livePlMatches![matchId]!.homeTeam} v ${livePlMatches![matchId]!.awayTeam}";
        widgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(matchTeams,
                style: const TextStyle(fontFamily: "Inter-SemiBold")),
          ],
        ));
        widgets.add(
          const Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  "Statistic",
                  style: TextStyle(fontFamily: "Inter-Thin"),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Value",
                  style: TextStyle(fontFamily: "Inter-Thin"),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Pts",
                  style: TextStyle(fontFamily: "Inter-Thin"),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );

        List<Widget> stats = [];
        for (Stat stat in _match.stats!) {
          if (stat.statName == "Live Bonus Points") {
            if (liveBonus) {
              widgets.add(
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(stat.statName!),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        stat.value.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        stat.fantasyPoints.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            widgets.add(
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(stat.statName!),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      stat.value.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      stat.fantasyPoints.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
        }
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    liveBonus = ref.watch(appSettingsRepositoryProvider
        .select((value) => value.bonusPointsEnabled));
    Color bonusColour = Theme.of(context).primaryColorDark;
    for (PlMatchStats match in widget.player.matches!) {
      for (Stat stat in match.stats!) {
        if (stat.statName == "Bonus") {
          if (stat.value == 3) {
            bonusColour = const Color(0xFFd4af37);
          } else if (stat.value == 2) {
            bonusColour = const Color(0xFFc0c0c0);
          } else if (stat.value == 1) {
            bonusColour = const Color(0xFFcd7f32);
          }
        }
      }
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            // width: _screenWidth >= 600 ? 500 : _screenWidth,
            padding: const EdgeInsets.only(
              top: 45.0 + 16.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: const EdgeInsets.only(top: 55.0),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: bonusColour,
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  widget.player.playerName!,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16.0),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getMatchStats())),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          Positioned(
              left: 16.0,
              right: 16.0,
              child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 55.0,
                  child: SizedBox(
                      width: 110,
                      height: 110,
                      child: ClipOval(
                        child: Image.network(
                          "https://resources.premierleague.com/premierleague/photos/players/110x140/p${widget.player.playerCode}.png",
                        ),
                      )))),
        ],
      ),
    );
  }
}

import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/player_popup.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SquadPitch extends ConsumerStatefulWidget {
  List<DraftPlayer> squad;
  SquadPitch({Key? key, required this.squad}) : super(key: key);

  @override
  _SquadPitchState createState() => _SquadPitchState();
}

class _SquadPitchState extends ConsumerState<SquadPitch> {
  Map<String, PlMatch>? plMatches;
  Map<int, DraftPlayer>? players;
  @override
  void initState() {
    super.initState();
  }

  void _showPlayerPopup(DraftPlayer player) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return PlayerPopup(player: player);
      },
    );
  }

  GestureDetector generatePlayer(DraftPlayer player) {
    return GestureDetector(
        // onTap: () => _showPlayerPopup(player),
        child: SquadPlayer(
      player: player,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<DraftPlayer>> _squad = {
      "GK": [],
      "DEF": [],
      "MID": [],
      "FWD": [],
      "SUBS": []
    };
    try {
      for (DraftPlayer player in widget.squad) {
        if (player.position == "GK") {
          _squad["GK"]!.add(player);
        }
        if (player.position == "DEF") {
          _squad["DEF"]!.add(player);
        }
        if (player.position == "MID") {
          _squad["MID"]!.add(player);
        }
        if (player.position == "FWD") {
          _squad["FWD"]!.add(player);
        }
      }
    } catch (e) {
      print(e);
    }

    return Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // GK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['GK']!) generatePlayer(player)
            ],
          ),
          // DEF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['DEF']!) generatePlayer(player)
            ],
          ),
          // MID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['MID']!) generatePlayer(player)
            ],
          ),
          // FWD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['FWD']!) generatePlayer(player)
            ],
          ),
        ],
      ),
    ]);
  }
}

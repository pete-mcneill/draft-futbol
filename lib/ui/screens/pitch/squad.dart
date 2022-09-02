import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/player.dart';
import 'package:draft_futbol/ui/screens/pitch/player_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Squad extends ConsumerStatefulWidget {
  DraftTeam team;
  Squad({Key? key, required this.team}) : super(key: key);

  @override
  _SquadState createState() => _SquadState();
}

class _SquadState extends ConsumerState<Squad> {
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

  @override
  Widget build(BuildContext context) {
    Map<int, DraftPlayer>? _players = ref.watch(draftPlayersProvider).players;
    Map<String, List<DraftPlayer>> _squad = {
      "GK": [],
      "DEF": [],
      "MID": [],
      "FWD": [],
      "SUBS": []
    };
    try {
      Map<int, int>? test = widget.team.squad;
      widget.team.squad?.forEach((key, value) {
        DraftPlayer? _player = _players[key];
        if (value < 12) {
          _squad[_player!.position]!.add(_player);
        } else {
          _squad['SUBS']!.add(_player!);
        }
      });
    } catch (e) {
      print(e);
    }

    return Container(
      // width: MediaQuery.of(context).size.width
      // constraints: BoxConstraints(minWidth: 11, maxWidth: 110, minHeight: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // GK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['GK']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: Player(player: player))
            ],
          ),
          // DEF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['DEF']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: Player(player: player))
            ],
          ),
          // MID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['MID']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: Player(player: player))
            ],
          ),
          // FWD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['FWD']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: Player(player: player))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (DraftPlayer player in _squad['SUBS']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: Player(player: player))
            ],
          ),
        ],
      ),
    );
  }
}

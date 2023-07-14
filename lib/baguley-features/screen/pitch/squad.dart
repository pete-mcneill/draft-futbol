import 'package:draft_futbol/baguley-features/models/baguley_draft_player.dart';
import 'package:draft_futbol/baguley-features/models/baguley_draft_team.dart';
import 'package:draft_futbol/baguley-features/models/fixture.dart';
import 'package:draft_futbol/baguley-features/screen/pitch/baguley_draft_player.dart';
import 'package:draft_futbol/baguley-features/screen/pitch/player_popup.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/player.dart';
import 'package:draft_futbol/ui/screens/pitch/player_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/pl_match.dart';

class BaguleySquad extends ConsumerStatefulWidget {
  BaguleyDraftTeam team;
  BaguleySquad({Key? key, required this.team}) : super(key: key);

  @override
  _BaguleySquadState createState() => _BaguleySquadState();
}

class _BaguleySquadState extends ConsumerState<BaguleySquad> {
  bool subModeEnabled = true;

  bool defSubsValid = false;
  bool midSubsValid = false;
  bool fwdSubsValid = false;

  @override
  void initState() {
    super.initState();
  }

  void _showPlayerPopup(BaguleyDraftPlayer player) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return BaguleyPlayerPopup(player: player);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<BaguleyDraftPlayer>> _squad = {
      "GK": [],
      "DEF": [],
      "MID": [],
      "FWD": [],
      "SUBS": []
    };
    try {
      for (BaguleyDraftPlayer _player in widget.team.squad!) {
        if (_player.positionId! < 12) {
          _squad[_player.position]!.add(_player);
        } else {
          _squad['SUBS']!.add(_player);
        }
      }
      _squad['SUBS']!.sort((a, b) => a.positionId!.compareTo(b.positionId!));
    } catch (e) {
      print(e);
    }
    Map<String, PlMatch> matches = ref.watch(plMatchesProvider).plMatches!;
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
              for (BaguleyDraftPlayer player in _squad['GK']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: BaguleyPlayer(
                        highlighted: false,
                        player: player,
                        subEnabled: subModeEnabled))
            ],
          ),
          // DEF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (BaguleyDraftPlayer player in _squad['DEF']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: BaguleyPlayer(
                        highlighted: false,
                        player: player,
                        subEnabled: subModeEnabled))
            ],
          ),
          // MID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (BaguleyDraftPlayer player in _squad['MID']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: BaguleyPlayer(
                      highlighted: false,
                      player: player,
                      subEnabled: subModeEnabled,
                    ))
            ],
          ),
          // FWD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (BaguleyDraftPlayer player in _squad['FWD']!)
                GestureDetector(
                    onTap: () => _showPlayerPopup(player),
                    child: DragTarget<BaguleyDraftPlayer>(
                      builder: (context, candidateItems, rejectedItems) {
                        print(candidateItems);
                        bool valid = false;
                        if (candidateItems.isNotEmpty) {
                          // valid = widget.team.checkIfValidSub(candidateItems, player, _squad);
                          if (fwdSubsValid) {
                            valid = true;
                          }
                        }
                        return BaguleyPlayer(
                            highlighted: valid,
                            player: player,
                            subEnabled: subModeEnabled);
                      },
                      onAccept: (item) {
                        print(item);
                      },
                    ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (BaguleyDraftPlayer player in _squad['SUBS']!)
                LongPressDraggable<BaguleyDraftPlayer>(
                    data: player,
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    onDragStarted: () => {
                          // Check if Positions allow subs here.
                          midSubsValid = false,
                          defSubsValid = false,
                          fwdSubsValid = true
                        },
                    feedback: BaguleyPlayer(
                      highlighted: false,
                      player: player,
                      subEnabled: false,
                    ),
                    child: GestureDetector(
                        onTap: () => _showPlayerPopup(player),
                        child: BaguleyPlayer(
                          highlighted: false,
                          player: player,
                          subEnabled: false,
                        )))
            ],
          ),
        ],
      ),
    );
  }
}

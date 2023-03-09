import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/player.dart';
import 'package:draft_futbol/ui/screens/pitch/player_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/transactions.dart';

class PlayerPool extends ConsumerStatefulWidget {
  DraftPlayer? player;
  DraftTeam? team;
  PlayerPool({Key? key, this.player, this.team})
      : super(key: key);

  @override
  _PlayerPoolState createState() => _PlayerPoolState();
}

class _PlayerPoolState extends ConsumerState<PlayerPool> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width
      // constraints: BoxConstraints(minWidth: 11, maxWidth: 110, minHeight: 36),
      child: Column(
        children: [

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: ClipOval(
                        child: Image.network(
                          "https://resources.premierleague.com/premierleague/photos/players/110x140/p${widget.player!.playerCode}.png",
                        ),
                      ),
                    ),
                    AutoSizeText(
                    widget.player!.playerName!,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    minFontSize: 10,
                    maxLines: 2,
                  ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    widget.team != null ? widget.team!.teamName! : "Free Agent",
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                    minFontSize: 10,
                    maxLines: 2,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    widget.team != null ? widget.team!.teamName! : "Free Agent",
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                    minFontSize: 10,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

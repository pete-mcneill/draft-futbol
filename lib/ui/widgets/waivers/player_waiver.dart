import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/draft_team.dart';
import '../../../models/transactions.dart';

class Waiver extends ConsumerStatefulWidget {
  Transaction? transaction;
  DraftPlayer? playerIn;
  DraftPlayer? playerOut;
  DraftTeam? team;
  bool visible;
  Waiver(
      {Key? key,
      this.transaction,
      this.playerIn,
      this.playerOut,
      this.team,
      this.visible = true})
      : super(key: key);

  @override
  _WaiverState createState() => _WaiverState();
}

class _WaiverState extends ConsumerState<Waiver> {
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
                        width: 80,
                        height: 80,
                        child: ClipOval(
                          child: Image.network(
                            "https://resources.premierleague.com/premierleague/photos/players/110x140/p${widget.playerIn!.playerCode}.png",
                          ),
                        ),
                      ),
                      AutoSizeText(
                        widget.playerIn!.playerName!,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        minFontSize: 10,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipOval(
                          child: Image.network(
                            "https://resources.premierleague.com/premierleague/photos/players/110x140/p${widget.playerOut!.playerCode}.png",
                          ),
                        ),
                      ),
                      AutoSizeText(
                        widget.playerOut!.playerName!,
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
                      widget.team!.teamName!,
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                      maxLines: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: widget.transaction!.result == "a"
                        ? const FaIcon(
                            FontAwesomeIcons.thumbsUp,
                            color: Colors.green,
                          )
                        : const FaIcon(
                            FontAwesomeIcons.thumbsDown,
                            color: Colors.red,
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

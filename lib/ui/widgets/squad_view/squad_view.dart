import 'package:draft_futbol/ui/screens/pitch/classic_view/classic_pitch_header.dart';
import 'package:draft_futbol/ui/screens/pitch/line_painter.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_background.dart';
import 'package:draft_futbol/ui/screens/pitch/squad.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:draft_futbol/ui/widgets/pitch_app_bar.dart';
import 'package:draft_futbol/ui/widgets/squad_view/squad_app_bar.dart';
import 'package:draft_futbol/ui/widgets/squad_view/squad_header.dart';
import 'package:draft_futbol/ui/widgets/squad_view/squad_pitch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/DraftTeam.dart';
import '../../../models/draft_player.dart';
import '../../../providers/providers.dart';

class SquadView extends ConsumerStatefulWidget {
  String teamName;
  List<DraftPlayer> players;
  SquadView({Key? key, required this.players, required this.teamName})
      : super(key: key);

  @override
  _SquadViewState createState() => _SquadViewState();
}

class _SquadViewState extends ConsumerState<SquadView> {
  Map<int, DraftPlayer>? players;
  String? activeLeague;
  List<DraftPlayer> getSquad(int teamId) {
    var testing = players!.values
        .where((DraftPlayer player) =>
            player.draftTeamId!.containsKey(activeLeague))
        .toList();
    var teamSquad = testing
        .where((DraftPlayer player) =>
            player.draftTeamId![activeLeague] == teamId.toString())
        .toList();
    return teamSquad;
  }

  @override
  Widget build(BuildContext context) {
    activeLeague = ref.watch(utilsProvider).activeLeagueId;
    players = ref.read(draftPlayersProvider).players;
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 7);
    double lineLength = pitchHeight - subsLength;
    return Scaffold(
      appBar: SquadAppBar(),
      body: Container(
        child: DefaultTabController(
          animationDuration: Duration.zero,
          length: 1,
          child: Scaffold(
            appBar: SquadHeader(teamName: widget.teamName),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Stack(
                    children: [
                      PitchBackground(
                        pitchHeight: pitchHeight,
                      ),
                      SizedBox(
                          height: pitchHeight,
                          width: MediaQuery.of(context).size.width,
                          // color: Colors.black,
                          child: CustomPaint(
                            painter: LinePainter(pitchLength: lineLength),
                          )),
                      SquadPitch(squad: widget.players)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ],
      ),
    );
  }
}

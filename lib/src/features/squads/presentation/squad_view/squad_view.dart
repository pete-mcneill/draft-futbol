import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/pitch/presentation/line_painter.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_background.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_app_bar.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_header.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_pitch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../live_data/domain/draft_domains/draft_player.dart';

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
  int? activeLeague;
  Gameweek? currentGameweek;
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
    currentGameweek = ref.read(liveDataRepositoryProvider.select((value) => value.gameweek));
    activeLeague = ref.watch(appSettingsRepositoryProvider).activeLeagueId;
    players = ref.read(premierLeagueControllerProvider.select((value) => value.players));
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 7);
    double lineLength = pitchHeight - subsLength;
    double pitchWidth = MediaQuery.of(context).size.width > 1000
        ? 1000
        : MediaQuery.of(context).size.width;
    return Container(
        child: DefaultTabController(
          animationDuration: Duration.zero,
          length: 1,
          child: kIsWeb
                  ? Center(
                      child: ClipRect(
                          child: SizedBox(
                              width: 1000,
                              child: getTabBars(
                                  pitchHeight, pitchWidth, lineLength))))
                  : getTabBars(pitchHeight, pitchWidth, lineLength)),
        // ],
      );
  }

  Stack getTabBars(
      double pitchHeight, double pitchWidth, double lineLength) {
    return
        Stack(
          children: [
            PitchBackground(
              pitchHeight: pitchHeight,
              matchView: false,
            ),
            SizedBox(
                height: pitchHeight/6,
                width: pitchWidth,
                // color: Colors.black,
                child: CustomPaint(
                  painter: LinePainter(pitchLength: lineLength),
                )),
            SquadPitch(squad: widget.players)
          ],
        );
  }
}

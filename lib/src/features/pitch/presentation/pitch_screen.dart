import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/pitch/presentation/line_painter.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_background.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_header.dart';
import 'package:draft_futbol/src/features/pitch/presentation/squad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../live_data/domain/draft_domains/draft_team.dart';
import 'pitch_app_bar.dart';

class Pitch extends ConsumerStatefulWidget {
  Fixture fixture;
  DraftTeam homeTeam;
  DraftTeam awayTeam;
  Pitch(
      {Key? key,
      required this.homeTeam,
      required this.awayTeam,
      required this.fixture})
      : super(key: key);

  @override
  _PitchState createState() => _PitchState();
}

class _PitchState extends ConsumerState<Pitch> {
  @override
  Widget build(BuildContext context) {
    bool subModeEnabled = false;
    // if (ref.watch(utilsProvider).subsReset!) {
    //   Map<String, Map<int, DraftTeam>>? allTeams = {};
    //   // ref.read(draftTeamsProvider).teams;
    //   widget.homeTeam =
    //       allTeams![widget.homeTeam.leagueId.toString()]![widget.homeTeam.id]!;
    //   widget.awayTeam =
    //       allTeams[widget.awayTeam.leagueId.toString()]![widget.awayTeam.id]!;
    // }
    double pitchWidth = MediaQuery.of(context).size.width > 1000
        ? 1000
        : MediaQuery.of(context).size.width;
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 7);
    double lineLength = pitchHeight - subsLength;
    return Scaffold(
      appBar: const PitchAppBar(),
      body: DefaultTabController(
        initialIndex: widget.homeTeam.teamName == "Average" ? 1 : 0,
        animationDuration: const Duration(seconds: 1),
        length: 2,
        child: Scaffold(
            appBar: PitchHeader(
                homeTeam: widget.homeTeam,
                awayTeam: widget.awayTeam,
                fixture: widget.fixture,
                subModeEnabled: subModeEnabled),
            body: kIsWeb
                ? Center(
                    child: ClipRect(
                      child: SizedBox(
                          width: 1000,
                          child: pitchView(subModeEnabled, pitchHeight,
                              pitchWidth, lineLength)),
                    ),
                  )
                : pitchView(
                    subModeEnabled, pitchHeight, pitchWidth, lineLength)),
      ),
    );
  }

  TabBarView pitchView(bool subModeEnabled, double pitchHeight,
      double pitchWidth, double lineLength) {
    return TabBarView(
      physics: subModeEnabled ? const NeverScrollableScrollPhysics() : null,
      children: [
        SingleChildScrollView(
          child: Stack(
            children: [
              PitchBackground(
                pitchHeight: pitchHeight,
                matchView: true,
              ),
              SizedBox(
                  height: pitchHeight,
                  width: pitchWidth,
                  // color: Colors.black,
                  child: CustomPaint(
                    painter: LinePainter(pitchLength: lineLength),
                  )),
              Squad(team: widget.homeTeam)
            ],
          ),
        ),
        SingleChildScrollView(
          child: Stack(
            children: [
              PitchBackground(
                pitchHeight: pitchHeight,
                matchView: true
              ),
              SizedBox(
                  height: pitchHeight,
                  width: pitchWidth,
                  // color: Colors.black,
                  child: CustomPaint(
                    painter: LinePainter(pitchLength: lineLength),
                  )),
              Squad(team: widget.awayTeam)
            ],
          ),
        )
      ],
    );
  }
}

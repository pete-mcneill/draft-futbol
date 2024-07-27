import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/pitch/presentation/classic_view/classic_pitch_header.dart';
import 'package:draft_futbol/src/features/pitch/presentation/line_painter.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_background.dart';
import 'package:draft_futbol/src/features/pitch/presentation/squad.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_app_bar.dart';
import 'package:draft_futbol/src/features/substitutes/presentation/subs_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../live_data/domain/draft_domains/draft_team.dart';

class ClassicPitch extends ConsumerStatefulWidget {
  DraftTeam team;
  ClassicPitch({Key? key, required this.team}) : super(key: key);

  @override
  _ClassicPitchState createState() => _ClassicPitchState();
}

class _ClassicPitchState extends ConsumerState<ClassicPitch> {
  DraftTeam? team;

  @override
  Widget build(BuildContext context) {
    team = ref.read(draftDataControllerProvider).teams[widget.team.id]!;
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 6);
    double lineLength = pitchHeight - subsLength;
    return Scaffold(
      appBar: const PitchAppBar(),
      body: Container(
        child: DefaultTabController(
          animationDuration: Duration.zero,
          length: 1,
          child: Scaffold(
            appBar: ClassicPitchHeader(team: widget.team),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if(!ref.watch(liveDataControllerProvider).gameweek!.gameweekFinished)
                        SubBar(team: widget.team!),
                      Stack(
                        children: [
                          PitchBackground(
                            pitchHeight: pitchHeight,
                            matchView: true,
                          ),
                          SizedBox(
                              height: pitchHeight,
                              width: MediaQuery.of(context).size.width,
                              // color: Colors.black,
                              child: CustomPaint(
                                painter: LinePainter(pitchLength: lineLength),
                              )),
                          Squad(team: widget.team)
                        ],
                      ),
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

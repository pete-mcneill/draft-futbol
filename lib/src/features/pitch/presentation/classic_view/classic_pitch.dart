import 'package:draft_futbol/src/features/pitch/presentation/classic_view/classic_pitch_header.dart';
import 'package:draft_futbol/src/features/pitch/presentation/line_painter.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_background.dart';
import 'package:draft_futbol/src/features/pitch/presentation/squad.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../live_data/domain/draft_domains/draft_team.dart';

class ClassicPitch extends StatefulWidget {
  DraftTeam team;
  ClassicPitch({Key? key, required this.team}) : super(key: key);

  @override
  State<ClassicPitch> createState() => _ClassicPitchState();
}

class _ClassicPitchState extends State<ClassicPitch> {
  @override
  Widget build(BuildContext context) {
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 7);
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
                  child: Stack(
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

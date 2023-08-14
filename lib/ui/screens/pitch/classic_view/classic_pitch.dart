import 'package:draft_futbol/ui/screens/pitch/classic_view/classic_pitch_header.dart';
import 'package:draft_futbol/ui/screens/pitch/line_painter.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_background.dart';
import 'package:draft_futbol/ui/screens/pitch/squad.dart';
import 'package:draft_futbol/ui/widgets/pitch_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../../models/DraftTeam.dart';
import '../../../../models/draft_team.dart';

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

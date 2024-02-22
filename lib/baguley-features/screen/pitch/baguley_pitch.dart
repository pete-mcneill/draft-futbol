import 'package:draft_futbol/baguley-features/models/baguley_draft_team.dart';
import 'package:draft_futbol/baguley-features/screen/pitch/squad.dart';
import 'package:draft_futbol/ui/screens/pitch/line_painter.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_background.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:flutter/material.dart';

import 'baguley_pitch_header.dart';

class Baguleypitch extends StatefulWidget {
  BaguleyDraftTeam homeTeam;
  BaguleyDraftTeam awayTeam;
  Baguleypitch({Key? key, required this.homeTeam, required this.awayTeam})
      : super(key: key);

  @override
  State<Baguleypitch> createState() => _BaguleypitchState();
}

class _BaguleypitchState extends State<Baguleypitch> {
  @override
  Widget build(BuildContext context) {
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 7);
    double lineLength = pitchHeight - subsLength;
    return Scaffold(
      appBar: DraftAppBar(
        settings: false,
      ),
      body: DefaultTabController(
        animationDuration: Duration.zero,
        length: 2,
        child: Scaffold(
          appBar: BaguleyPitchHeader(
              homeTeam: widget.homeTeam, awayTeam: widget.awayTeam),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Stack(
                  children: [
                    PitchBackground(
                      pitchHeight: pitchHeight,
                      matchView: true
                    ),
                    SizedBox(
                        height: pitchHeight,
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.black,
                        child: CustomPaint(
                          painter: LinePainter(pitchLength: lineLength),
                        )),
                    BaguleySquad(team: widget.homeTeam)
                  ],
                ),
              ),
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
                    BaguleySquad(team: widget.awayTeam)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

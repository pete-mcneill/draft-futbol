import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/pitch/presentation/line_painter.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_background.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_header.dart';
import 'package:draft_futbol/src/features/pitch/presentation/squad.dart';
import 'package:draft_futbol/src/features/substitutes/application/subs_controller.dart';
import 'package:draft_futbol/src/features/substitutes/presentation/subs_bar.dart';
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

class _PitchState extends ConsumerState<Pitch> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  DraftTeam? homeTeam;
  DraftTeam? awayTeam;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    if(widget.homeTeam.teamName == "Average"){
      _tabController!.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    homeTeam = ref.read(draftDataControllerProvider).teams[widget.homeTeam.id]!;
    awayTeam = ref.read(draftDataControllerProvider).teams[widget.awayTeam.id]!;
    bool subModeEnabled = ref.watch(subsControllerProvider).subsModeActive;
    double pitchWidth = MediaQuery.of(context).size.width > 1000
        ? 1000
        : MediaQuery.of(context).size.width;
    double pitchHeight =
        (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double subsLength = (pitchHeight - (pitchHeight / 10) * 6);
    double lineLength = pitchHeight - subsLength;
    return Scaffold(
      appBar: const PitchAppBar(),
      body: Scaffold(
          appBar: PitchHeader(
              homeTeam: homeTeam!,
              awayTeam: awayTeam!,
              fixture: widget.fixture,
              subModeEnabled: subModeEnabled,
              tabController: _tabController!,),
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
    );
  }

  TabBarView pitchView(bool subModeEnabled, double pitchHeight,
      double pitchWidth, double lineLength) {
    return TabBarView(
      controller: _tabController,
      physics: subModeEnabled ? const NeverScrollableScrollPhysics() : null,
      children: [
          SingleChildScrollView(
            child: 
            Column(
              children: [
                if(!ref.watch(liveDataControllerProvider).gameweek!.gameweekFinished)
                SubBar(team: homeTeam!),
                Stack(
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
                  if(!ref.watch(subsControllerProvider).subsInProgress)
                    Squad(team: homeTeam!)
                  else
                   ...[SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Opacity(
                        opacity: 1,
                        child: ModalBarrier(dismissible: false, color: Colors.black),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: const Column(
                              children: [
                                Text("Saving Changes"),
                                CircularProgressIndicator(),
                              ],
                            ),
                          )),
                    ),
                    ],
                ],
              ),
              ]
            ),
          ),
        SingleChildScrollView(
          child: Column(
            children: [
              if(!ref.watch(liveDataControllerProvider).gameweek!.gameweekFinished)
                SubBar(team: awayTeam!),
              Stack(
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
                  Squad(team: awayTeam!)
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

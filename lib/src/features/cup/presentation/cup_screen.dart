import 'package:draft_futbol/src/features/cup/application/cup_service.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_app_bar.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
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
import 'package:draft_futbol/src/features/cup/domain/cup.dart';

import '../../live_data/domain/draft_domains/draft_team.dart';

class CupScreen extends ConsumerStatefulWidget {
  Cup cup;
  CupScreen({Key? key, required this.cup}) : super(key: key);

  @override
  _CupScreenState createState() => _CupScreenState();
}

class _CupScreenState extends ConsumerState<CupScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? activeRound;
  late final Future cupData;
  @override
  void initState() {
    super.initState();
    for (var round in widget.cup.rounds) {
      print(round);
    }
    _tabController =
        TabController(vsync: this, length: widget.cup.rounds.length);
    activeRound = widget.cup.rounds[0]['id'].toString();
    cupData = ref.read(cupServiceProvider).getScoresForCup(widget.cup);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  List<Widget> getRounds() {
    return <Widget>[
      for (var round in widget.cup.rounds)
        if (widget.cup.fixtures[round['id']] != null)
          buildRound(round['id'].toString())
        else
          Container(child: Text('No fixtures available for this round'))
    ];
  }

  ListView buildRound(String round) {
    final test = widget.cup.fixtures[round];
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.cup.fixtures[round]!.length,
        itemBuilder: (BuildContext context, int index) {
          CupFixture _fixture = widget.cup.fixtures[round]![index];
          DraftTeam homeTeam = ref
              .watch(draftDataControllerProvider)
              .teams[_fixture.homeTeamId]!;
          DraftTeam awayTeam = ref
              .watch(draftDataControllerProvider)
              .teams[_fixture.awayTeamId]!;
          return Card(
            child: Row(children: [
              Expanded(
                  flex: 6,
                  child: Text(
                    homeTeam.teamName!,
                    textAlign: TextAlign.left,
                  )),
              Expanded(flex: 1, child: Text("vs")),
              Expanded(
                  flex: 6,
                  child: Text(awayTeam.teamName!, textAlign: TextAlign.right)),
            ]),
          );

          // Column(
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => Pitch(
          //                       homeTeam: homeTeam,
          //                       awayTeam: awayTeam,
          //                     )));
          //       },
          //       child: CupFixtureSummary(
          //           homeTeam: homeTeam,
          //           awayTeam: awayTeam,
          //           fixture: _fixture,
          //           multipleLegs: round['multipleLegs']),
          //     ),
          //     // const SizedBox(
          //     //   height: 5,
          //     // )
          //   ],
          // );
        });
  }

  @override
  Widget build(BuildContext context) {
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        String index = _tabController!.index.toString();
        print(index);
        setState(() {
          activeRound = widget.cup.rounds[int.parse(index)]['id'].toString();
        });

        print(activeRound);
      }
    });
    return FutureBuilder<void>(
        future: cupData,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              appBar: CupAppbar(tabController: _tabController, cup: widget.cup),
              body: Column(children: [
                Text(widget.cup.name),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: getRounds(),
                  ),
                ),
              ]),
            );
          }
        });
  }
}

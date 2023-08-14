import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_screen.dart';
import 'package:draft_futbol/ui/widgets/filter_ui.dart';
import 'package:draft_futbol/ui/widgets/h2h/h2h_match_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/draft_team.dart';

class H2hWeb extends ConsumerStatefulWidget {
  const H2hWeb({Key? key}) : super(key: key);

  @override
  _H2hWebState createState() => _H2hWebState();
}

class _H2hWebState extends ConsumerState<H2hWeb> {
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  int activeLeague = 0;
  bool liveBonus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    liveBonus = ref.watch(utilsProvider).liveBps!;
    activeLeague = ref.watch(utilsProvider).activeLeagueId!;

    ref.watch(utilsProvider.select((connection) => connection.activeLeagueId!));
    gameweek = ref.watch(fplGwDataProvider.select((data) => data.gameweek!));
    Map<int, Map<int, List<Fixture>>> test =
        ref.watch(fplGwDataProvider.select((data) => data.h2hFixtures!));
    fixtures = ref.watch(fplGwDataProvider.select((data) => data.h2hFixtures))![
        activeLeague]![gameweek!.currentGameweek];

    // ref
    //     .read(fixturesProvider)
    //     .fixtures[activeLeague]![gameweek!.currentGameweek];
    teams = ref
        .watch(fplGwDataProvider.select((data) => data.teams))![activeLeague];
    // ref.watch(draftTeamsProvider).teams![activeLeague];

    return ListView(children: <Widget>[
      // if (!gameweek!.gameweekFinished)
      ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: fixtures!.length,
          itemBuilder: (BuildContext context, int index) {
            Fixture _fixture = fixtures![index];
            DraftTeam homeTeam = teams![_fixture.homeTeamId]!;
            DraftTeam awayTeam = teams![_fixture.awayTeamId]!;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // print("Pitch Change");
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => Pitch(
                    //               homeTeam: homeTeam,
                    //               awayTeam: awayTeam,
                    //               fixture: _fixture,
                    //             )));
                  },
                  child: H2hMatchPreview(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            );
          }),
    ]);
  }
}

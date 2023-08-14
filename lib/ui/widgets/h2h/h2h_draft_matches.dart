import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_screen.dart';
import 'package:draft_futbol/ui/widgets/coffee.dart';
import 'package:draft_futbol/ui/widgets/filter_ui.dart';
import 'package:draft_futbol/ui/widgets/h2h/h2h_match_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/draft_team.dart';

class H2hDraftMatches extends ConsumerStatefulWidget {
  const H2hDraftMatches({Key? key}) : super(key: key);

  @override
  _H2hDraftMatchesState createState() => _H2hDraftMatchesState();
}

class _H2hDraftMatchesState extends ConsumerState<H2hDraftMatches> {
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int? activeLeague;
  bool liveBonus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ChipOptions> getFilterOptions() {
    List<ChipOptions> options = [
      // if (!gameweek!.gameweekFinished)
      ChipOptions(
          label: "Live Bonus Points",
          selected: liveBonus,
          onSelected: (bool selected) {
            ref.read(utilsProvider.notifier).updateLiveBps(selected);
          }),
      // if (!gameweek!.gameweekFinished)
      //   ChipOptions(
      //       label: "Remaining Players",
      //       selected: remainingPlayersFilter,
      //       onSelected: (bool selected) {
      //         ref
      //             .read(utilsProvider.notifier)
      //             .setRemainingPlayersView(selected);
      //       }),
      // ChipOptions(
      //     label: "Icons Summary",
      //     selected: iconsSummaryFilter,
      //     onSelected: (bool selected) {
      //       ref.read(utilsProvider.notifier).setIconSummaryView(selected);
      //     })
    ];
    return options;
  }

  @override
  Widget build(BuildContext context) {
    liveBonus = ref.watch(utilsProvider).liveBps!;
    activeLeague = ref.watch(utilsProvider).activeLeagueId;
    gameweek = ref.watch(fplGwDataProvider.select((data) => data.gameweek));
    fixtures = ref.watch(fplGwDataProvider.select((data) => data.h2hFixtures))![
        activeLeague]![gameweek!.currentGameweek];
    teams = ref
        .watch(fplGwDataProvider.select((data) => data.teams))![activeLeague];

    return ListView(children: <Widget>[
      buyaCoffeebutton(context),
      if (!gameweek!.gameweekFinished)
        FilterH2HMatches(options: getFilterOptions()),
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
                    print("Pitch Change");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Pitch(
                                  homeTeam: homeTeam,
                                  awayTeam: awayTeam,
                                  fixture: _fixture,
                                )));
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

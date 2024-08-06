import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_fixture_summary.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen_controller.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_summary/head_to_head_summary.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/tab_bar_test.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_screen.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CupWidget extends ConsumerWidget {
  Cup cup;
  CupWidget({Key? key, required this.cup}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.read(cupDataControllerProvider).fixtures;
    final currentRound =
        ref.read(cupDataControllerProvider.notifier).getCurrentRoundName(cup);
    if (fixtures.isEmpty ||
        fixtures[cup.name]!.isEmpty ||
        fixtures[cup.name]![currentRound['id']] == null ||
        fixtures[cup.name]![currentRound['id']]!.isEmpty) {
      return Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buyaCoffeebutton(context),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                  children: const <TextSpan>[
                    TextSpan(
                      text: "No fixtures available for this round",
                    ),
                    TextSpan(
                      text: "\n Set fixtures for the round in settings",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]);
    }
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        // SizedBox(
        //   width: 100,
        //   height: 500,
        //   child: TabBarTest()),
        buyaCoffeebutton(context),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
            children: <TextSpan>[
              TextSpan(
                text: currentRound['id'],
              ),
            ],
          ),
        ),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: fixtures[cup.name]![currentRound['id']]!.length,
            itemBuilder: (BuildContext context, int index) {
              final round = ref
                  .read(cupDataControllerProvider.notifier)
                  .getCurrentRoundName(cup);
              CupFixture _fixture = fixtures[cup.name]![round['id']]![index];
              DraftTeam homeTeam = ref
                  .watch(headToHeadScreenControllerProvider.notifier)
                  .getTeam(_fixture.homeTeamId);
              DraftTeam awayTeam = ref
                  .watch(headToHeadScreenControllerProvider.notifier)
                  .getTeam(_fixture.awayTeamId);
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Pitch(
                                    homeTeam: homeTeam,
                                    awayTeam: awayTeam,
                                  )));
                    },
                    child: CupFixtureSummary(
                        homeTeam: homeTeam,
                        awayTeam: awayTeam,
                        fixture: _fixture,
                        multipleLegs: round['multipleLegs']),
                  ),
                  // const SizedBox(
                  //   height: 5,
                  // )
                ],
              );
            }),
      ],
    );
  }
}

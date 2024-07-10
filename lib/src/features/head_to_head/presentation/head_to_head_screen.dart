import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen_controller.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_summary/head_to_head_summary.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/tab_bar_test.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_screen.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadToHeadScreen extends ConsumerWidget {
  final int leagueId;
  const HeadToHeadScreen(
      {Key? key, 
       required this.leagueId}) 
  : super(key: key);

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.read(headToHeadScreenControllerProvider.notifier).getGameweekFixtures(leagueId);
  
    // bool bps = ref.watch(appSettingsRepositoryProvider).liveBonusPoints;
    return ListView(
      children: <Widget>[
        // SizedBox(
        //   width: 100,
        //   height: 500,
        //   child: TabBarTest()),
        // buyaCoffeebutton(context),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: fixtures.length,
          itemBuilder: (BuildContext context, int index) {
            Fixture _fixture = fixtures![index];
            DraftTeam homeTeam = ref.read(headToHeadScreenControllerProvider.notifier).getTeam(_fixture.homeTeamId!);  
            DraftTeam awayTeam =  ref.read(headToHeadScreenControllerProvider.notifier).getTeam(_fixture.awayTeamId!);
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
                                  fixture: _fixture,
                                )));
                  },
                  child: HeadToHeadSummary(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                  ),
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
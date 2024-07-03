import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen_controller.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_summary/head_to_head_summary.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_screen.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabBarTest extends ConsumerWidget {
  const TabBarTest({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context,  WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
                child: TabBar(
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.3),
                    indicatorColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                    tabs: [
                      Tab(
                        child: Text("The Baguley"),
                      ),
                      Tab(
                        child: Text("The Chumpionship"),
                      ),
                    ]),
                preferredSize: Size.fromHeight(30.0)),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                child: Center(
                  child: HeadToHeadScreen(),
                ),
              ),
              Container(
                child: Center(
                  child: HeadToHeadScreen(),
                ),
              ),
            ],
          )),
    );
  }

  
}
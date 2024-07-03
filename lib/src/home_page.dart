import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/league_standings_screen.dart';
import 'package:draft_futbol/src/features/live_data/application/live_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/premier_league_matches/presentation/premier_league_matches_screen.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/classic_league_standings.dart';
import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:draft_futbol/src/common_widgets/draft_bottom_bar.dart';
import 'package:draft_futbol/src/common_widgets/draft_placeholder.dart';
import 'package:draft_futbol/src/common_widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/live_data/domain/draft_domains/draft_leagues.dart';
import 'features/live_data/domain/draft_domains/draft_team.dart';
import 'common_widgets/more.dart';

const int maxFailedLoadAttempts = 3;

class HomePage extends ConsumerStatefulWidget {
  final List squads = [];

  HomePage({Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final Future _draft_data;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int navBarIndex = 0;
  bool showBottomNav = true;
  int? activeLeague;

  // ignore: prefer_final_fields
  List<Widget> h2hOptions = <Widget>[
    const HeadToHeadScreen(),
    const LeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  List<Widget> classicOptions = <Widget>[
    const ClassicLeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  @override
  Widget build(BuildContext context) {
    final liveDataRepository = ref.watch(liveServiceProvider);
     final draftRepository = ref.watch(draftRepositoryProvider);
    return FutureBuilder<void>(
        future: _draft_data,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            activeLeague = ref.watch(appSettingsRepositoryProvider).activeLeagueId;
            DraftLeague leagueData = draftRepository.leagues[activeLeague]!;
            if (leagueData.scoring == 'c' && navBarIndex > 2) {
              updateIndex(2);
            }
            gameweek = liveDataRepository.liveDataRepository.gameweek;
            String draftStatus = leagueData.draftStatus;
            if (draftStatus == "pre" || gameweek!.currentGameweek == 0) {
              showBottomNav = false;
            } else {
              showBottomNav = true;
              if (leagueData.scoring == "h") {
                fixtures = draftRepository.head2HeadFixtures[activeLeague]![gameweek!.currentGameweek];
              }
            }
            // teams = draftRepository.teams![activeLeague];
            return Scaffold(
                key: _scaffoldKey,
                appBar: DraftAppBarV1(
                  settings: true,
                ),
                // drawer: const DraftDrawer(),
                bottomNavigationBar: showBottomNav
                    ? DraftBottomBar(
                        updateIndex: updateIndex,
                        leagueType: leagueData.scoring,
                        currentIndex: navBarIndex,
                      )
                    : const SizedBox(),
                body: SafeArea(
                    child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.center,
                  child: Container(
                    // color: Theme.of(context).scaffoldBackgroundColor,
                    // margin:
                    //     const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    // alignment: FractionalOffset.center,
                    child: draftStatus == "pre" ||
                            gameweek!.currentGameweek == 0
                        ? DraftPlaceholder(
                            leagueData: leagueData,
                          )
                        : RefreshIndicator(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: leagueData.scoring == 'h'
                                ? h2hOptions[navBarIndex]
                                : classicOptions[navBarIndex],
                            onRefresh: () async {
                              // var updatedData = await ref
                              //     .refresh(getFplData(widget.leagueIds).future);
                            },
                          ),
                  ),
                )));
          }
        }
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final liveDataRepository = ref.read(liveServiceProvider);
    // TODO Check if default league ID is set, move to settings service
    final appSettingsRep = ref.read(appSettingsRepositoryProvider);
    if(appSettingsRep.activeLeagueId == null) {
      // appSettingsRep.setActiveLeagueId(145);
    }
    final List<int> leagueIds = ref.read(dataStoreProvider).getLeagues().map((league) => league.id).toList();
    _draft_data = liveDataRepository.getDraftData(leagueIds);
  }

  updateIndex(int index) {
    setState(() {
      navBarIndex = index;
    });
  }
}

import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/non_head_to_head_placeholder.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/league_standings_screen.dart';
import 'package:draft_futbol/src/features/live_data/application/live_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
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

  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late final Future _draft_data;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, DraftLeague> leagues = {};
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int navBarIndex = 0;
  bool showBottomNav = true;
  int? activeLeague;

  // ignore: prefer_final_fields
  List<Widget> getLeagueWidgets() {
    return <Widget>[
      TabBarView(
        controller: _tabController,
        children: getH2hWidgets(),
      ),
      TabBarView(
        controller: _tabController,
        children: getLeagueStandingsWidgets(),
      ),
      const PlMatchesScreen(),
      const More()
    ];
  }

  List<Widget> getH2hWidgets() {
    return <Widget>[
      for (DraftLeague league in leagues.values)
        if(league.scoring == 'h')
          HeadToHeadScreen(leagueId: league.leagueId)
        else
          const HeadToHeadPlaceholderScreen()
    ];
  }

  List<LeagueStandings> getLeagueStandingsWidgets() {
    return <LeagueStandings>[
      for (DraftLeague league in leagues.values)
        LeagueStandings(leagueId: league.leagueId)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final liveDataRepository = ref.watch(liveServiceProvider);
    final draftRepository = ref.watch(draftRepositoryProvider);
    leagues = draftRepository.leagues;
    return FutureBuilder<void>(
        future: _draft_data,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            activeLeague =
                ref.read(appSettingsRepositoryProvider).activeLeagueId;
            DraftLeague leagueData = draftRepository.leagues[activeLeague]!;
            // if (leagueData.scoring == 'c' && navBarIndex > 2) {
            //   updateIndex(2);
            // }
            gameweek = liveDataRepository.liveDataRepository.gameweek;
            String draftStatus = leagueData.draftStatus;
            if (draftStatus == "pre" || gameweek!.currentGameweek == 0) {
              showBottomNav = false;
            } else {
              showBottomNav = true;
              if (leagueData.scoring == "h") {
                fixtures = draftRepository.head2HeadFixtures[activeLeague]![
                    gameweek!.currentGameweek];
              }
            }
            // teams = draftRepository.teams![activeLeague];
            return Scaffold(
                key: _scaffoldKey,
                appBar: DraftAppBarV1(
                  settings: true,
                  tabController: _tabController,
                  bottomIndex: navBarIndex,
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
                    child:
                        draftStatus == "pre" || gameweek!.currentGameweek == 0
                            ? DraftPlaceholder(
                                leagueData: leagueData,
                              )
                            : RefreshIndicator(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                child: getLeagueWidgets()[navBarIndex],
                                onRefresh: () async {
                                  // var updatedData = await ref
                                  //     .refresh(getFplData(widget.leagueIds).future);
                                },
                              ),
                  ),
                )));
          }
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TabController getTabController(int tabLength) {
    return TabController(length: navBarIndex != 2 ? tabLength : 1, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    
    final liveDataRepository = ref.read(liveServiceProvider);
    // TODO Check if default league ID is set, move to settings service
    final appSettingsRep = ref.read(appSettingsRepositoryProvider);
    
    if (appSettingsRep.activeLeagueId == null) {
      // appSettingsRep.setActiveLeagueId(145);
    }
    final List<int> leagueIds = ref
        .read(dataStoreProvider)
        .getLeagues()
        .map((league) => league.id)
        .toList();
    _tabController = getTabController(leagueIds.length);
    _draft_data = liveDataRepository.getDraftData(leagueIds);
  }

  updateIndex(int index) {
    setState(() {
      navBarIndex = index;
    });
  }
}

import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_widget.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/non_head_to_head_placeholder.dart';
import 'package:draft_futbol/src/features/live_data/data/gameweek_repository.dart/gameweek_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/league_standings_screen.dart';
import 'package:draft_futbol/src/features/live_data/application/live_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/premier_league_matches/presentation/premier_league_matches_screen.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/league_standings/presentation/classic_league_standings.dart';
// import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:draft_futbol/src/common_widgets/draft_bottom_bar.dart';
import 'package:draft_futbol/src/common_widgets/draft_placeholder.dart';
import 'package:draft_futbol/src/common_widgets/loading.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../domain/draft_domains/draft_leagues.dart';
import '../domain/draft_domains/draft_team.dart';
import '../../../common_widgets/more.dart';

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
  late TabController _cupTabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, DraftLeague> leagues = {};
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int navBarIndex = 0;
  bool showBottomNav = true;
  int? activeLeague;
  bool loading = false;
  bool cupGameweek = false;

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
      if (cupGameweek) getCups(),
      RefreshIndicator(
        child: PlMatchesScreen(),
        onRefresh: () async {
          await refreshData();
        },
      ),
      const More()
    ];
  }

  Widget getCups() {
    return TabBarView(controller: _cupTabController, children: [
      for (Cup cup in ref
          .read(cupDataControllerProvider.notifier)
          .getCupsForCurrentGameweek())
        RefreshIndicator(
          child: CupWidget(
            cup: cup,
          ),
          onRefresh: () async {
            await refreshData();
          },
        )
    ]);
  }

  List<Widget> getH2hWidgets() {
    return <Widget>[
      for (DraftLeague league in leagues.values)
        if (league.scoring == 'h')
          RefreshIndicator(
            child: HeadToHeadScreen(leagueId: league.leagueId),
            onRefresh: () async {
              await refreshData();
            },
          )
        else
          const HeadToHeadPlaceholderScreen()
    ];
  }

  List<Widget> getLeagueStandingsWidgets() {
    return <Widget>[
      for (DraftLeague league in leagues.values)
        if (league.scoring == 'c')
          RefreshIndicator(
            child: ClassicLeagueStandings(leagueId: league.leagueId),
            onRefresh: () async {
              await refreshData();
            },
          )
        else
          RefreshIndicator(
            child: LeagueStandings(leagueId: league.leagueId),
            onRefresh: () async {
              await refreshData();
            },
          )
    ];
  }

  Future<void> refreshData() async {
    setState(() {
      loading = true;
    });
    final liveDataRepository = ref.read(liveServiceProvider);
    final List<int> leagueIds = ref
        .read(dataStoreProvider)
        .getLeagues()
        .map((league) => league.id)
        .toList();
    await liveDataRepository.getDraftData(leagueIds);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen<AsyncValue<void>>(
    //   premierLeagueControllerProvider.state,
    //   (_, state) => state.showAlertDialogOnError(context),
    // );
    final liveDataRepository = ref.watch(liveDataControllerProvider);
    final draftRepository = ref.watch(draftDataControllerProvider);
    final cupController = ref.read(cupDataControllerProvider.notifier);
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
            gameweek = liveDataRepository.gameweek;
            String draftStatus = leagueData.draftStatus;
            if (draftStatus == "pre" || gameweek!.currentGameweek == 0) {
              showBottomNav = false;
              _cupTabController = getCupTabController(1);
            } else {
              showBottomNav = true;
              cupGameweek = cupController.isCupGameweek();
              if (cupGameweek) {
                int cups = ref
                    .read(cupDataControllerProvider.notifier)
                    .getCupsForCurrentGameweek()
                    .length;
                _cupTabController = getCupTabController(cups);
              } else {
                _cupTabController = getCupTabController(1);
              }

              if (leagueData.scoring == "h") {
                fixtures = draftRepository.head2HeadFixtures[activeLeague]![
                    gameweek!.currentGameweek];
              }
            }
            return Scaffold(
                key: _scaffoldKey,
                appBar: DraftAppBarV1(
                  settings: true,
                  tabController: _tabController,
                  bottomIndex: navBarIndex,
                  cupGameweek: cupGameweek,
                  cupTabController: _cupTabController,
                ),
                // drawer: const DraftDrawer(),
                bottomNavigationBar: showBottomNav
                    ? DraftBottomBar(
                        updateIndex: updateIndex,
                        currentIndex: navBarIndex,
                        cupGameweek: cupGameweek,
                      )
                    : const SizedBox(),
                body: SafeArea(
                    child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.center,
                  child: Container(
                    child: loading
                        ? const Loading()
                        : leagueData.draftStatus == "pre" ||
                                gameweek!.currentGameweek == 0
                            ? DraftPlaceholder(
                                leagueData: leagueData,
                              )
                            : getLeagueWidgets()[navBarIndex],

                    // RefreshIndicator(
                    //     color: Theme.of(context)
                    //         .colorScheme
                    //         .secondaryContainer,
                    //     child: getLeagueWidgets()[navBarIndex],
                    //     onRefresh: () async {
                    // final List<int> leagueIds = ref
                    //   .read(dataStoreProvider)
                    //   .getLeagues()
                    //   .map((league) => league.id)
                    //   .toList();
                    // await liveDataRepository.getDraftData(leagueIds);
                    //     },
                  ),
                  // ),
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
    return TabController(length: tabLength, vsync: this);
  }

  TabController getCupTabController(int length) {
    return TabController(length: length, vsync: this);
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

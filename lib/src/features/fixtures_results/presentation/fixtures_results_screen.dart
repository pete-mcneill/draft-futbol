import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/fixtures_results/presentation/fixtures_app_bar.dart';
import 'package:draft_futbol/src/features/fixtures_results/presentation/fixtures_bottom_bar.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
// import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftFixturesResults extends ConsumerStatefulWidget {
  DraftFixturesResults({Key? key}) : super(key: key);

    @override
  _DraftFixturesResultsState createState() => _DraftFixturesResultsState();
}

class _DraftFixturesResultsState extends ConsumerState<DraftFixturesResults> with TickerProviderStateMixin {
  Map<int, DraftTeam>? teams;
  Map<int, DraftLeague> leagues = {};
  int navBarIndex = 0;
  late TabController _tabController;

  TabController getTabController(int tabLength) {
    return TabController(length: tabLength, vsync: this);
  }
  @override
  void initState() {
    super.initState();
    final List<LocalLeagueMetadata> leagues = ref
        .read(dataStoreProvider)
        .getLeagues();
    List h2hLeagues = leagues.where((element) => element.scoring == "h").toList(); 
    _tabController = getTabController(h2hLeagues.length);
    int currentGameweek = ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
    if (currentGameweek == 38) {
      setState(() {
        navBarIndex = 1;
      });
    }
  }

  List<Widget> buildFixturesResults() {
    return <Widget>[
      TabBarView(
        controller: _tabController,
        children: getFixtures(),
      ),
      TabBarView(
        controller: _tabController,
        children: getResults(),
      ),
    ];
  }

  List<ListView> getFixtures(){
    List<ListView> widgets = [];
    for(DraftLeague league in leagues.values){
      if(league.scoring == "h"){
      Map<int, List<Fixture>>? matches;
      Map<int, List<Fixture>>? fixtures;
      teams = ref.read(draftDataControllerProvider).teams;
      matches = ref.read(draftDataControllerProvider).head2HeadFixtures[league.leagueId]!;
      int currentGW = ref.watch(liveDataControllerProvider).gameweek!.currentGameweek;
      fixtures = {
        for (final key in matches!.keys)
          if (key > currentGW) key: matches![key]!
      };
      widgets.add(ListView.builder(
                          shrinkWrap: true,
                          itemCount: fixtures!.length,
                          itemBuilder: (BuildContext context, int index) {
                            int gameweek = fixtures!.keys.elementAt(index);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text("Gameweek " + gameweek.toString()),
                                const Divider(
                                  thickness: 2,
                                ),
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: fixtures![gameweek]!.length,
                                  itemBuilder: (context, i) {
                                    Fixture _fixture = fixtures![gameweek]![i];
                                    DraftTeam homeTeam =
                                        teams![_fixture.homeTeamId]!;
                                    DraftTeam awayTeam =
                                        teams![_fixture.awayTeamId]!;
                                    return ListTile(
                                        title: IntrinsicHeight(
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        homeTeam.teamName!,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        homeTeam.managerName!,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          const Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                      child: VerticalDivider(
                                                    thickness: 1,
                                                  )),
                                                  Expanded(
                                                      child: VerticalDivider(
                                                    thickness: 1,
                                                  )),
                                                ]),
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        awayTeam.teamName!,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        awayTeam.managerName!,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ));
                                  },
                                  separatorBuilder: (context, index) {
                                    return const Divider(
                                      thickness: 2,
                                    );
                                  },
                                ),
                                // Divider(thickness: 2,),
                                const SizedBox(
                                  height: 15,
                                )
                              ],
                            );
                          })); 
    }
    }
    return widgets;
  }

  List<ListView> getResults(){
    List<ListView> widgets = [];
    for(DraftLeague league in leagues.values){
      if(league.scoring == 'h'){
         Map<int, List<Fixture>>? matches;
        Map<int, List<Fixture>>? results;
        teams = ref.read(draftDataControllerProvider).teams;
      matches = ref.read(draftDataControllerProvider).head2HeadFixtures[league.leagueId]!;
      int currentGW = ref.watch(liveDataControllerProvider).gameweek!.currentGameweek;
      results = {
        for (final key in matches!.keys)
          if (key <= currentGW) key: matches![key]!
      };
      widgets.add(ListView.builder(
                          shrinkWrap: true,
                          itemCount: results!.length,
                          itemBuilder: (BuildContext context, int index) {
                            int reversedIndex = results!.length - 1 - index;
                            int gameweek =
                                results!.keys.elementAt(reversedIndex);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text("Gameweek " + gameweek.toString()),
                                const Divider(
                                  thickness: 2,
                                ),
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: results![gameweek]!.length,
                                  itemBuilder: (context, i) {
                                    Fixture _fixture = results![gameweek]![i];
                                    DraftTeam homeTeam =
                                        teams![_fixture.homeTeamId]!;
                                    DraftTeam awayTeam =
                                        teams![_fixture.awayTeamId]!;
                                    return ListTile(
                                        title: IntrinsicHeight(
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              flex: 5,
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        homeTeam.teamName!,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        homeTeam.managerName!,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                _fixture.homeStaticPoints
                                                    .toString(),
                                              )),
                                          const Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                      child: VerticalDivider(
                                                    thickness: 1,
                                                  )),
                                                  Expanded(
                                                      child: VerticalDivider(
                                                    thickness: 1,
                                                  )),
                                                ]),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(_fixture
                                                  .awayStaticPoints
                                                  .toString())),
                                          Expanded(
                                              flex: 5,
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        awayTeam.teamName!,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        awayTeam.managerName!,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        minFontSize: 10,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    )

                                        //  Center(child: Text(homeTeam.teamName! + " " + _fixture.homeStaticPoints.toString() + " - " + _fixture.awayStaticPoints.toString() + " "+ awayTeam.teamName!)),
                                        );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const Divider(
                                      thickness: 2,
                                    );
                                  },
                                ),
                                // Divider(thickness: 2,),
                                const SizedBox(
                                  height: 15,
                                )
                              ],
                            );
                          }));
      } 
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    leagues = ref.read(draftDataControllerProvider).leagues;
    List<DropdownMenuItem<String>> menuOptions = [];
    

    int dropdownValue;
    List<LocalLeagueMetadata> leaguesMetadata = ref.read(dataStoreProvider).getLeagues();
    for(LocalLeagueMetadata league in leaguesMetadata) {
      menuOptions.add(DropdownMenuItem(
          value: league.id.toString(),
          child: Center(
            child: Text(
              league.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    }
    dropdownValue = ref.watch(appSettingsRepositoryProvider.select((value) => value.activeLeagueId));

    updateIndex(int index) {
    setState(() {
      navBarIndex = index;
    });
  }

    return Scaffold(
      appBar: FixturesAppBar(
        leading: true,
        settings: false,
        tabController: _tabController,
      ),
      bottomNavigationBar: FixturesBottomBar(
        currentIndex: navBarIndex,
        updateIndex: updateIndex,
      ),
      body:buildFixturesResults()[navBarIndex],

      // Show next GW Fixtures
      // Option to navigate between each GW
    );
  }
}

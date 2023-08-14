import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/DraftTeam.dart';
import '../../models/draft_leagues.dart';
import '../../models/draft_team.dart';
import '../../models/fixture.dart';
import '../widgets/app_bar/draft_app_bar.dart';

class DraftFixturesResults extends ConsumerWidget {
  DraftFixturesResults({Key? key}) : super(key: key);

  Map<int, DraftTeam>? teams;
  Map<int, List<Fixture>>? matches;
  Map<int, List<Fixture>>? results;
  Map<int, List<Fixture>>? fixtures;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownMenuItem<String>> menuOptions = [];
    int currentGW = ref.watch(fplGwDataProvider).gameweek!.currentGameweek;

    int dropdownValue;
    // Provider.of<UtilsProvider>(context, listen: true).appTheme;
    Map<int, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds.forEach((key, value) {
      menuOptions.add(DropdownMenuItem(
          value: key.toString(),
          child: Center(
            child: Text(
              value['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    });
    dropdownValue = ref.watch(
        utilsProvider.select((connection) => connection.activeLeagueId!));
    DraftLeague activeLeague =
        ref.read(fplGwDataProvider).leagues![dropdownValue]!;
    if (activeLeague.scoring == "h") {
      teams = ref.read(fplGwDataProvider).teams![dropdownValue];
      matches = ref.read(fplGwDataProvider).h2hFixtures![dropdownValue]!;
      // ref.read(fixturesProvider).fixtures[dropdownValue]!;
      results = {
        for (final key in matches!.keys)
          if (key <= currentGW) key: matches![key]!
      };
      fixtures = {
        for (final key in matches!.keys)
          if (key > currentGW) key: matches![key]!
      };
    }

    return Scaffold(
      appBar: DraftAppBar(
        leading: true,
        settings: false,
      ),
      body: DefaultTabController(
          length: 2, // length of tabs
          initialIndex: 0,
          child: activeLeague.scoring == "h"
              ? Column(children: <Widget>[
                  Container(
                    child: const TabBar(
                      tabs: [
                        Tab(text: 'Fixtures'),
                        Tab(text: 'Results'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(children: <Widget>[
                      ListView.builder(
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
                          }),
                      ListView.builder(
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
                          }),
                    ]),
                  )
                ])
              : const Center(
                  child:
                      Text("Classic Scoring League, no fixtures available"))),

      // Show next GW Fixtures
      // Option to navigate between each GW
    );
  }
}

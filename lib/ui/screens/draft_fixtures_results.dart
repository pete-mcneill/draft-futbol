import 'package:auto_size_text/auto_size_text.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/manage_league_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/DraftTeam.dart';
import '../../models/draft_leagues.dart';
import '../../models/fixture.dart';
import '../widgets/app_bar/draft_app_bar.dart';

class DraftFixturesResults extends ConsumerWidget {
  

  DraftFixturesResults({Key? key}) : super(key: key);

  Map<int, DraftTeam>? teams;
  Map<String, List<Fixture>>? matches;
  Map<String, List<Fixture>>? results;
  Map<String, List<Fixture>>? fixtures;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownMenuItem<String>> menuOptions = [];
    List<DropdownMenuItem<String>> gwOptions = [];
    String currentGW = ref.watch(gameweekProvider)!.currentGameweek;
    String selectedGw = currentGW.toString();
    for (var i = 1; i <= int.parse(currentGW); i++) {
      gwOptions.add(DropdownMenuItem(
          value: i.toString(),
          child: Center(
            child: Text(
              i.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    }

    String dropdownValue;
    bool isLightTheme = ref.watch(utilsProvider).isLightTheme!;
    // Provider.of<UtilsProvider>(context, listen: true).appTheme;
    Map<String, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds.forEach((key, value) {
      menuOptions.add(DropdownMenuItem(
          value: key,
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
    DraftLeague activeLeague =  ref.read(draftLeaguesProvider).leagues[dropdownValue]!;
    if(activeLeague.scoring == "h"){
      teams =
        ref.read(draftTeamsProvider).teams![dropdownValue]!;
     matches =
        ref.read(fixturesProvider).fixtures[dropdownValue]!;
      results = {
      for (final key in matches!.keys)
        if (int.parse(key) <= int.parse(currentGW)) key: matches![key]!
      };
      fixtures = {
        for (final key in matches!.keys)
          if (int.parse(key) > int.parse(currentGW)) key: matches![key]!
      };
    }
    
    return Scaffold(
      appBar: DraftAppBar(),
      body: DefaultTabController(
          length: 2, // length of tabs
          initialIndex: 0,
          child: activeLeague.scoring == "h" ?
          Column(children: <Widget>[
            Container(
              child: TabBar(
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
                      String gameweek = fixtures!.keys.elementAt(index);
                      int test = fixtures![gameweek]!.length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("Gameweek " + gameweek),
                          Divider(
                            thickness: 2,
                          ),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: fixtures![gameweek]!.length,
                            itemBuilder: (context, i) {
                              Fixture _fixture = fixtures![gameweek]![i];
                              DraftTeam homeTeam = teams![_fixture.homeTeamId]!;
                              DraftTeam awayTeam = teams![_fixture.awayTeamId]!;
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
                                                  style:
                                                      const TextStyle(fontSize: 15),
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
                                                  style:
                                                      const TextStyle(fontSize: 12),
                                                  minFontSize: 10,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: const <Widget>[
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
                                                  style:
                                                      const TextStyle(fontSize: 15),
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
                                                  style:
                                                      const TextStyle(fontSize: 12),
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
                              return Divider(
                                thickness: 2,
                              );
                            },
                          ),
                          // Divider(thickness: 2,),
                          SizedBox(
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
                      String gameweek = results!.keys.elementAt(reversedIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("Gameweek " + gameweek),
                          Divider(
                            thickness: 2,
                          ),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: results![gameweek]!.length,
                            itemBuilder: (context, i) {
                              Fixture _fixture = results![gameweek]![i];
                              DraftTeam homeTeam = teams![_fixture.homeTeamId]!;
                              DraftTeam awayTeam = teams![_fixture.awayTeamId]!;
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
                                                  style:
                                                      const TextStyle(fontSize: 15),
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
                                                  style:
                                                      const TextStyle(fontSize: 12),
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
                                          _fixture.homeStaticPoints.toString(),
                                        )),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: const <Widget>[
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
                                        child: Text(_fixture.awayStaticPoints
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
                                                  style:
                                                      const TextStyle(fontSize: 15),
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
                                                  style:
                                                      const TextStyle(fontSize: 12),
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
                              return Divider(
                                thickness: 2,
                              );
                            },
                          ),
                          // Divider(thickness: 2,),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      );
                    }),
              ]),
            )
          ]):Center(child: const Text("Classic Scoring League, no fixtures available"))),

      // Show next GW Fixtures
      // Option to navigate between each GW
    );
  }
}

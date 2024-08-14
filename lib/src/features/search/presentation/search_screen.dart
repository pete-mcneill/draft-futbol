import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_screen.dart';
import 'package:draft_futbol/src/features/onboarding/presentation/on_boarding_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchProvidersState createState() => SearchProvidersState();
}

class SearchProvidersState extends ConsumerState<SearchScreen> {
  final roundNameController = TextEditingController();

  List searchResults = [];

  void getSearchResults(String value) {
    Map<int, DraftPlayer> players =
        ref.read(premierLeagueControllerProvider).players;
    Iterable draftPlayerResults = players.values.where((player) =>
        player.playerName!.toLowerCase().contains(value.toLowerCase()));
    searchResults = searchResults + draftPlayerResults.toList();
    setState(() {
      searchResults = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: roundNameController,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.search),
              hintText: "Search",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              suffixIcon: Container(
                margin: EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(50, 25),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text("Search"),
                  onPressed: () async {
                    setState(() {
                      searchResults = [];
                    });
                    getSearchResults(roundNameController.text);
                  },
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final currentResult = searchResults[index];
                    if (currentResult is DraftTeam) {
                      return ListTile(
                        title: Text(currentResult.teamName!),
                        // subtitle: Text(result['teamId']),
                      );
                    } else if (currentResult is DraftPlayer) {
                      List<Widget> owners = [];
                      int gwScore = 0;
                      int gwBonusScore = 0;
                      Gameweek gameweek =
                          ref.read(liveDataControllerProvider).gameweek!;
                      if (currentResult.matches?.isNotEmpty ?? false) {
                        int gw = gameweek.currentGameweek;
                        for (PlMatchStats match
                            in currentResult.matches![gw]!) {
                          if (match.stats!.isNotEmpty) {
                            for (Stat stat in match.stats!) {
                              if (stat.statName == "Live Bonus Points") {
                                gwBonusScore += stat.fantasyPoints!;
                              } else {
                                gwBonusScore += stat.fantasyPoints!;
                                gwScore += stat.fantasyPoints!;
                              }
                            }
                          }
                        }
                      }
                      Row _gwScores = Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Chip(
                                label: Text(
                              'GW Score: ' + gwScore.toString(),
                              style: TextStyle(fontWeight: FontWeight.w300),
                            )),
                          ),
                          if (!gameweek.gameweekFinished)
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Chip(
                                  label: Text(
                                'Bonus Score: ' + gwBonusScore.toString(),
                                style: TextStyle(fontWeight: FontWeight.w300),
                              )),
                            ),
                        ],
                      );
                      owners.add(_gwScores);
                      owners.add(Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("League",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                              child: Text("Team",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)))
                        ],
                      ));
                      for (DraftLeague league in ref
                          .read(draftDataControllerProvider)
                          .leagues
                          .values) {
                        if (currentResult.draftTeamId!
                            .containsKey(league.leagueId)) {
                          final teamId =
                              currentResult.draftTeamId![league.leagueId];
                          final team = ref
                              .read(draftDataControllerProvider)
                              .teams
                              .values
                              .firstWhere((team) => team.entryId == teamId);
                          owners.add(Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(league.leagueName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w300)),
                              ),
                              Expanded(
                                  child: Text(team.teamName!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300)))
                            ],
                          ));
                        } else {
                          owners.add(Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(league.leagueName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w300)),
                              ),
                              Expanded(
                                  child: Text("Free Agent",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300)))
                            ],
                          ));
                        }
                      }
                      return Card(
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 40,
                                child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: ClipOval(
                                      child: Image.network(
                                        "https://resources.premierleague.com/premierleague/photos/players/110x140/p${currentResult.playerCode}.png",
                                      ),
                                    ))),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                    currentResult.playerName!,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' - ' + currentResult.position!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w100),
                                  ),
                                ]),
                                ...owners,
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ]),
                      );
                    } else if (currentResult is PlTeam) {
                      return ListTile(
                        title: Text(currentResult.name!),
                        // subtitle: Text(result['teamId']),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }
}

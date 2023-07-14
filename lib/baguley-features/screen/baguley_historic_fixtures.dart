import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:draft_futbol/baguley-features/models/baguley_draft_player.dart';
import 'package:draft_futbol/baguley-features/models/baguley_draft_team.dart';
import 'package:draft_futbol/baguley-features/models/fixture.dart';
import 'package:draft_futbol/baguley-features/screen/pitch/baguley_pitch.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:flutter/material.dart';
import 'package:draft_futbol/models/players/match.dart';
import '../../ui/widgets/app_bar/draft_app_bar.dart';
import '../widgets/season_overview.dart';

class BaguleyResults extends StatefulWidget {
  String seasonId;

  BaguleyResults({Key? key, required this.seasonId}) : super(key: key);

  @override
  State<BaguleyResults> createState() => _BaguleyResultsState();
}

class _BaguleyResultsState extends State<BaguleyResults> {
  var homeTeamIds;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
  }

  Future<Map<String, dynamic>?> getTeamUuid(String fpl_id) async {
    try {
      final teamIds = await FirebaseFirestore.instance
          .collection("draft_teams")
          .where("uuid", isEqualTo: fpl_id)
          .get();
      return teamIds.docs[0].data();
    } catch (error) {
      final teamIds = await FirebaseFirestore.instance
          .collectionGroup("team_ids")
          .where("fpl_id", isEqualTo: fpl_id)
          .get();
      String? homeTeamDoc;
      for (var doc in teamIds.docs) {
        homeTeamDoc = doc.reference.parent.parent!.id;
      }
      var uuidSnapshot = await FirebaseFirestore.instance
          .collection("draft_teams")
          .doc(homeTeamDoc)
          .get();
      var uuidData = uuidSnapshot.data();
      return uuidData;
    }
  }

  Future<List<Object?>> getResults() async {
    final _collectionRef = FirebaseFirestore.instance
        .collection('results')
        .doc("season" + widget.seasonId)
        .collection("results")
        .orderBy('gameweek');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    final reversedList = allData.reversed.toList();

    return reversedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DraftAppBar(settings: false),
        body: FutureBuilder<List<Object?>>(
          future: getResults(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Object?>> snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            }

            if (snapshot.hasData) {
              List<BaguleyFixture> results = snapshot.data!
                  .map(
                      (e) => BaguleyFixture.fromJson(e as Map<String, dynamic>))
                  .toList();
              var newMap =
                  groupBy(results, (BaguleyFixture obj) => obj!.gameweek!);
              try {
                return Scaffold(
                    body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: newMap.length,
                          itemBuilder: (context, index) {
                            print(newMap.length);
                            String key = (newMap.length - index).toString();
                            List<BaguleyFixture> _fixtures = newMap[key]!;
                            String gameweek = _fixtures[0].gameweek!;
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
                                  itemCount: _fixtures.length,
                                  itemBuilder: (context, i) {
                                    try {
                                      BaguleyFixture _fixture = _fixtures[i];
                                      return GestureDetector(
                                        onTap: () async {
                                          try {
                                            Map<String, dynamic>? homeUuid =
                                                await getTeamUuid(_fixture
                                                    .homeFplId
                                                    .toString());
                                            Map<String, dynamic>? awayUuid =
                                                await getTeamUuid(_fixture
                                                    .awayFplId
                                                    .toString());
                                            print("IDS");
                                            List<BaguleyDraftPlayer> homeSquad =
                                                await getSquad(
                                                    homeUuid!, gameweek);
                                            List<BaguleyDraftPlayer> awaySquad =
                                                await getSquad(
                                                    awayUuid!, gameweek);
                                            if (homeSquad.length == 0 &&
                                                awaySquad.length == 0) {
                                              throw Error();
                                            }
                                            BaguleyDraftTeam homeTeam =
                                                BaguleyDraftTeam.fromJson({
                                              "entry_id":
                                                  int.parse(homeUuid['uuid']),
                                              "player_first_name":
                                                  homeUuid['first_name'],
                                              "player_last_name":
                                                  homeUuid['last_name'],
                                              "id": int.parse(homeUuid['uuid']),
                                              "entry_name": _fixture.homeTeam,
                                              "squad": homeSquad,
                                              "points": _fixture.homePoints
                                            });
                                            BaguleyDraftTeam awayTeam =
                                                BaguleyDraftTeam.fromJson({
                                              "entry_id":
                                                  int.parse(awayUuid!['uuid']),
                                              "player_first_name":
                                                  awayUuid['first_name'],
                                              "player_last_name":
                                                  awayUuid['last_name'],
                                              "id": int.parse(awayUuid['uuid']),
                                              "entry_name": _fixture.awayTeam,
                                              "squad": awaySquad,
                                              "points": _fixture.awayPoints
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        new Baguleypitch(
                                                          homeTeam: homeTeam,
                                                          awayTeam: awayTeam,
                                                        )));
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Squad data not availble for this fixture")));
                                          }
                                        },
                                        child: ListTile(
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
                                                            _fixture.homeTeam!,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                            minFontSize: 10,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: SizedBox(
                                                          height: 20,
                                                          child: AutoSizeText(
                                                            _fixture.homePoints
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: const <Widget>[
                                                      Expanded(
                                                          child:
                                                              VerticalDivider(
                                                        thickness: 1,
                                                      )),
                                                      Expanded(
                                                          child:
                                                              VerticalDivider(
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
                                                            _fixture.awayTeam!,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                            minFontSize: 10,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: SizedBox(
                                                          height: 20,
                                                          child: AutoSizeText(
                                                            _fixture.awayPoints
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
                                                            minFontSize: 10,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        )),
                                      );
                                    } catch (error) {
                                      print(error);
                                      return ListTile(
                                        title: Text("Error"),
                                      );
                                    }
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      thickness: 2,
                                    );
                                  },
                                ),
                              ],
                            );
                          }),
                    )
                  ],
                ));
              } catch (error) {
                return Text("Error");
              }
            }

            if (snapshot.connectionState == ConnectionState.done) {
              print("Hello");
              return Text("Hello");
            }

            return Text("loading");
          },
        ));
  }

  Future<List<BaguleyDraftPlayer>> getSquad(
      Map<String, dynamic> uuid, String gameweek) async {
    var squadTest = await FirebaseFirestore.instance
        .collection('squads')
        .doc(uuid['uuid'])
        .collection("seasons")
        .doc(widget.seasonId)
        .collection("gameweeks")
        .doc(gameweek)
        .collection("players")
        .get();
    final allData = squadTest.docs.map((doc) => doc.data()).toList();
    List<BaguleyDraftPlayer> squad = [];
    final matches = await FirebaseFirestore.instance
        .collectionGroup("matches")
        .where("team_id", isEqualTo: uuid['uuid'])
        .where("season_id", isEqualTo: widget.seasonId)
        .where("gameweek", isEqualTo: gameweek)
        .get();
    for (var player in allData) {
      var json = {
        "element_type": player['type'],
        "id": player['fpl_id'],
        "web_name": player["name"],
        "code": "na",
        "team": player["kit_id"],
        "positionId": player["position"]
      };
      BaguleyDraftPlayer _player = BaguleyDraftPlayer.fromJson(json);
      List<Match> _matches = [];
      for (var match in matches.docs) {
        var requiredPath =
            'squads/${uuid['uuid']}/seasons/${widget.seasonId}/gameweeks/$gameweek/players/${_player.playerId}/matches';
        if (match.reference.path.contains(requiredPath)) {
          Match _match = Match.fromFirestoreData(match.data());
          _matches.add(_match);
        }
      }
      _player.updateMatches(_matches);
      squad.add(_player);
    }
    return squad;
  }
}

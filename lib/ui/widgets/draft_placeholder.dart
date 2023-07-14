import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/draft_leagues.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:draft_futbol/ui/widgets/squad_view/squad_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/draft_player.dart';
import '../../models/draft_squad.dart';

class DraftPlaceholder extends ConsumerWidget {
  DraftLeague leagueData;

  DraftPlaceholder({Key? key, required this.leagueData}) : super(key: key);

  List<DraftPlayer> getSquad(int teamId, Map<int, DraftPlayer> players) {
    var testing = players.values
        .where((DraftPlayer player) =>
            player.draftTeamId!.containsKey(leagueData.leagueId))
        .toList();
    var teamSquad = testing
        .where((DraftPlayer player) =>
            player.draftTeamId![leagueData.leagueId] == teamId.toString())
        .toList();
    return teamSquad;
  }

  Widget generatePlaceholder(bool noAdverts, BuildContext context,
      WidgetRef ref, Map<int, DraftPlayer> players, bool draftComplete) {
    return Column(
      children: [
        const Center(
          child: AutoSizeText(
            "Teams:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: leagueData.teams.length,
          itemBuilder: (context, index) {
            var team = leagueData.teams[index];
            return Column(
              children: [
                draftComplete
                    ? GestureDetector(
                        onTap: () async {
                          List<DraftPlayer> squad =
                              getSquad(team['id'], players);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SquadView(
                                        teamName: team['name'],
                                        players: squad,
                                      )));
                        },
                        child: Container(
                            height: 50,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0)),
                                margin: EdgeInsets.all(0),
                                elevation: 10,
                                child: Center(child: Text(team['name'])))),
                      )
                    : Container(
                        height: 50,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0)),
                            margin: EdgeInsets.all(0),
                            elevation: 10,
                            child: Center(child: Text(team['name'])))),
                const SizedBox(
                  height: 5,
                )
              ],
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<int, DraftPlayer> players = ref.read(draftPlayersProvider).players;
    bool noAdverts = ref.watch(purchasesProvider).noAdverts!;
    String leagueStatus = leagueData.draftStatus;
    if (leagueStatus == "pre") {
      return SingleChildScrollView(
        child: Column(children: [
          !ref.watch(purchasesProvider).noAdverts!
              ? SizedBox(
                  height: 120,
                  child: FutureBuilder<Widget>(
                    future: getBannerWidget(
                        context: context,
                        adSize: AdSize.banner,
                        noAdverts: ref.watch(purchasesProvider).noAdverts!),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: snapshot.data,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                )
              : SizedBox(
                  height: 5,
                ),
          const Center(
            child: AutoSizeText(
              'Draft has not been completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: generatePlaceholder(noAdverts, context, ref, players, false),
          )
        ]),
      );
    } else {
      return SingleChildScrollView(
        child: Column(children: [
          !ref.watch(purchasesProvider).noAdverts!
              ? SizedBox(
                  height: 120,
                  child: FutureBuilder<Widget>(
                    future: getBannerWidget(
                        context: context,
                        adSize: AdSize.banner,
                        noAdverts: ref.watch(purchasesProvider).noAdverts!),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: snapshot.data,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                )
              : SizedBox(
                  height: 5,
                ),
          Center(
            child: AutoSizeText(
              leagueData.draftStatus == 'pre'
                  ? 'Draft has not been completed'
                  : 'Season has not started yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          Center(
            child: AutoSizeText(
              'Tap to view squads below',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ref.watch(allSquads).when(
              loading: () => const Text(
                    "Getting Drafted Squads...",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
              error: (err, stack) =>
                  Text('Error getting league details, sorry!'),
              data: (config) {
                Map<int, DraftPlayer> players =
                    ref.read(draftPlayersProvider).players;
                // var trueEntries = players.entries.where(
                //     (MapEntry<int, DraftPlayer> _players) =>
                //         _players.key == leagueData.leagueId &&
                //         _players.valuedraftTeamId!);
                // print(trueEntries.length);
                // var teamSquad = testing
                // Map<String, Map<int, DraftSquad>> test =
                //     ref.read(squadsProvider).squads;
                // Map<int, DraftSquad> squads =
                //     ref.read(squadsProvider).squads[leagueData.leagueId]!;
                return Container(
                  child: generatePlaceholder(
                      noAdverts, context, ref, players, true),
                );
              })
        ]),
      );
    }
  }
}

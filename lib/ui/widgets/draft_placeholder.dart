import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/draft_leagues.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/app_store_links.dart';
import 'package:draft_futbol/ui/widgets/coffee.dart';
import 'package:draft_futbol/ui/widgets/squad_view/squad_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/draft_player.dart';

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
            player.draftTeamId![leagueData.leagueId] == teamId)
        .toList();
    return teamSquad;
  }

  Widget generatePlaceholder(BuildContext context, WidgetRef ref,
      Map<int, DraftPlayer> players, bool draftComplete) {
    return Column(
      children: [
        const Center(
          child: AutoSizeText(
            "Teams:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
        ),
        const SizedBox(
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
                              getSquad(team['entry_id'], players);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SquadView(
                                        teamName: team['name'],
                                        players: squad,
                                      )));
                        },
                        child: SizedBox(
                            height: 50,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0)),
                                margin: const EdgeInsets.all(0),
                                elevation: 10,
                                child: Center(child: Text(team['name'])))),
                      )
                    : SizedBox(
                        height: 50,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0)),
                            margin: const EdgeInsets.all(0),
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
    Map<int, DraftPlayer> players =
        ref.read(fplGwDataProvider.select((value) => value.players!));
    String leagueStatus = leagueData.draftStatus;
    if (leagueStatus == "pre") {
      return SingleChildScrollView(
        child: Column(children: [
          ...appStoreLinks(),
          buyaCoffeebutton(context),
          const Center(
            child: AutoSizeText(
              'Draft has not been completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            child: generatePlaceholder(context, ref, players, false),
          )
        ]),
      );
    } else {
      Map<int, DraftPlayer> players =
          ref.read(fplGwDataProvider.select((value) => value.players!));
      return SingleChildScrollView(
        child: Column(children: [
          ...appStoreLinks(),
          buyaCoffeebutton(context),
          Center(
            child: AutoSizeText(
              leagueData.draftStatus == 'pre'
                  ? 'Draft has not been completed'
                  : 'Season has not started yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          const Center(
            child: AutoSizeText(
              'Tap to view squads below',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          generatePlaceholder(context, ref, players, true)
        ]),
      );
    }
  }
}

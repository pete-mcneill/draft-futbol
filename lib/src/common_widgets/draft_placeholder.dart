import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/common_widgets/app_store_links.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_view.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/live_data/domain/draft_domains/draft_player.dart';

class DraftPlaceholder extends ConsumerStatefulWidget {
  DraftLeague leagueData;
  DraftPlaceholder({Key? key, required DraftLeague this.leagueData})
      : super(key: key);

  @override
  _DraftPlaceholderState createState() => _DraftPlaceholderState();
}

class _DraftPlaceholderState extends ConsumerState<DraftPlaceholder> {
  @override
  void initState() {
    super.initState();
  }

  late final Future<Map<int, List<DraftPlayer>>> futureSquads = getSquads();
  Map<int, DraftPlayer> players = {};

  Future<Map<int, List<DraftPlayer>>> getSquads() async {
    Map<int, List<DraftPlayer>> squads = {};
    Map<int, DraftTeam>? teams = ref.read(draftDataControllerProvider).teams;
    for (var league in teams.entries) {
      var leaguePlayers = players.values
          .where((DraftPlayer player) =>
              player.draftTeamId!.containsKey(league.key))
          .toList();
      // for (var teamEntry in league.value.entries) {
      //   DraftTeam team = teamEntry.value;
      //   var teamSquad = leaguePlayers
      //       .where((DraftPlayer player) =>
      //           player.draftTeamId![league.key] == team.entryId)
      //       .toList();
      //   squads[team.entryId!] = teamSquad;
      // }
    }
    return squads;
  }

  List<Widget> getPlayers(Map<int, DraftPlayer> players) {
    List<Widget> playerWidgets = [];
    for (var team in widget.leagueData.teams) {
      List<DraftPlayer> teamPlayers = [];
      for (DraftPlayer player in players.values) {
        if (player.draftTeamId!.containsKey(widget.leagueData.leagueId)) {
          if (player.draftTeamId![widget.leagueData.leagueId] ==
              team['entry_id']) {
            teamPlayers.add(player);
          }
        }
      }
      playerWidgets.add(expansionItem(
          index: team['entry_id'],
          teamName: team['name'],
          players: teamPlayers));
    }
    return playerWidgets;
  }

  @override
  Widget build(BuildContext context) {
    Map<int, DraftPlayer> players =
        ref.read(premierLeagueControllerProvider).players;
    String leagueStatus = widget.leagueData.draftStatus;
    return SingleChildScrollView(
      child: Column(children: [
        if (kIsWeb) ...appStoreLinks(),
        // buyaCoffeebutton(context),
        const Center(
          child: AutoSizeText(
            'Season has not started yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Center(
          child: AutoSizeText(
            'Once the season starts on the 16th August, \n live scores will appear and you will be able to add additonal leagues and cups',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 5,
          ),
        ),
        Container(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  ...getPlayers(players),
                  const SizedBox(
                    height: 5,
                  )
                ],
              ),
            ],
          ),
        )

            // generatePlaceholder(
            //     context, ref, players, false, widget.leagueData),
            )
      ]),
    );
  }

  void _scrollToSelectedContent({GlobalKey? expansionTileKey}) {
    final keyContext = expansionTileKey!.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  Widget expansionItem(
      {int? index, String? teamName, List<DraftPlayer>? players}) {
    final GlobalKey expansionTileKey = GlobalKey();
    return Material(
      elevation: 4,
      child: Container(
        color: Theme.of(context).cardColor,
        child: ExpansionTile(
          key: expansionTileKey,
          onExpansionChanged: (value) {
            if (value) {
              _scrollToSelectedContent(expansionTileKey: expansionTileKey);
            }
          },
          title: Text(teamName!),
          children: <Widget>[
            SquadView(
              players: players!,
              teamName: teamName,
            )
          ],
        ),
      ),
    );
  }

  Widget generatePlaceholder(BuildContext context, WidgetRef ref,
      Map<int, DraftPlayer> players, bool draftComplete, DraftLeague league) {
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
          itemCount: league.teams.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> team = league.teams[index];

            return ListTile(
              title: Center(child: Text(team['name'])),
            );
          },
        ),
        // FutureBuilder<Map<int, List<DraftPlayer>>>(
        //   future: futureSquads,
        //   builder: (BuildContext context,
        //       AsyncSnapshot<Map<int, List<DraftPlayer>>> snapshot) {
        //     if (snapshot.hasError) {
        //       return const Text("Error");
        //     }

        //     if (snapshot.hasData) {
        //       try {
        //         return SingleChildScrollView(
        //           physics: const AlwaysScrollableScrollPhysics(),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.stretch,
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               const SizedBox(
        //                 height: 10,
        //               ),
        //               for (dynamic team in widget.leagueData.teams)
        //                 Column(
        //                   children: [
        //                     expansionItem(
        //                         index: team['entry_id'],
        //                         teamName: team['name'],
        //                         players: snapshot.data![team['entry_id']]!),
        //                     const SizedBox(
        //                       height: 5,
        //                     )
        //                   ],
        //                 ),
        //             ],
        //           ),
        //         );
        //       } catch (error) {
        //         return const Text("Error");
        //       }
        //     } else {
        //       return const Text("loading");
        //     }
        //   },
        // )
      ],
    );
  }
}

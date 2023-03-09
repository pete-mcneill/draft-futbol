import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:draft_futbol/ui/widgets/player_pool/player_pool.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/DraftTeam.dart';
import '../../models/Gameweek.dart';
import '../../models/draft_player.dart';
import '../../models/fixture.dart';
import '../../models/transactions.dart';
import '../widgets/loading.dart';
import '../widgets/waivers/player_waiver.dart';

class PlayerPoolScreen extends ConsumerStatefulWidget {
  const PlayerPoolScreen({Key? key}) : super(key: key);

  @override
  _PlayerPoolScreenState createState() => _PlayerPoolScreenState();
}

class _PlayerPoolScreenState extends ConsumerState<PlayerPoolScreen> {
  List<DropdownMenuItem<String>> menuOptions = [];
  Map<String, dynamic>? leagueIds;
  String? currentGW;
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds!.forEach((key, value) {
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
    Map<int, DraftTeam> teams =
        ref.read(draftTeamsProvider).teams![dropdownValue]!;

    final _draftTeamFilters = teams.entries
        .map((key) => MultiSelectItem(key.key, key.value.teamName!))
        .toList();

    AsyncValue config = ref.watch(allTransactions);
    return config.when(
        loading: () => const Loading(),
        error: (err, stack) => Text('Error: $err'),
        data: (config) {
          Map<String, Map<String, List<Transaction>>> transactions =
              ref.read(transactionsProvider).transactions;
          var activeLeague = ref.watch(
              utilsProvider.select((connection) => connection.activeLeagueId!));

          Map<int, DraftPlayer> players =
              ref.read(draftPlayersProvider).players;
          Gameweek gameweek = ref.watch(gameweekProvider)!;
          String currentGameweek = gameweek.waiversProcessed
              ? (int.parse(gameweek.currentGameweek) + 1).toString()
              : gameweek.currentGameweek;
          return Scaffold(
            appBar: DraftAppBar(),
            body: playerPoolTab(players, activeLeague, teams)

            // Show next GW Fixtures
            // Option to navigate between each GW
          );
        });
  }

  SingleChildScrollView playerPoolTab(Map<int, DraftPlayer> players, String activeLeague, Map<int, DraftTeam> teams) {
    return SingleChildScrollView(
                            child: Column(children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Center(
                                    child: Text("Player",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ),
                              const Expanded(
                                child: Center(
                                    child: Text("PL Team",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ),
                              const Expanded(
                                  child: Center(
                                      child: Text("Draft Team",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))))
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: players.length,
                            separatorBuilder: (context, index) {
                              return const Divider(
                                thickness: 2,
                              );
                            },
                            itemBuilder: (context, i) {
                              int key = players.keys.elementAt(i);
                              DraftTeam? _team;
                              DraftPlayer player = players[key]!;
                              if (player.playerStatus![activeLeague] == "o") {
                                _team = teams[int.parse(
                                    player.draftTeamId![activeLeague]!)];
                              }
                              return PlayerPool(
                                player: player,
                                team: _team,
                              );
                            },
                          ),
                        ]));
  }

}

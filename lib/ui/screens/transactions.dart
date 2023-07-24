import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:draft_futbol/ui/widgets/custom_error.dart';
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

class Transactions extends ConsumerStatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<Transactions> {
  List<Transaction> visibleWaivers = [];
  List<Transaction> visiableTrades = [];
  List<Transaction> visibleFreeAgents = [];
  List<DropdownMenuItem<String>> menuOptions = [];
  List<DropdownMenuItem<String>> gwOptions = [];
  List<Object?> _draftTeams = [];
  List<Object?> _waiverResults = [];
  Map<String, dynamic>? leagueIds;
  bool waiversFiltered = false;
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

  void setPossibleGameweeks() {
    for (var i = 1; i <= int.parse(currentGW!); i++) {
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
  }

  var waiverResults = [
    MultiSelectItem("a", "Accepted"),
    MultiSelectItem("r", "Rejected")
  ];

  @override
  Widget build(BuildContext context) {
    leagueIds = ref.watch(utilsProvider).leagueIds!;
    currentGW = ref.watch(gameweekProvider)!.currentGameweek;
    setPossibleGameweeks();
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

    try {
      return config.when(
          loading: () => const Loading(),
          error: (err, stack) => Text('Error: $err'),
          data: (config) {
            Map<String, Map<String, List<Transaction>>> transactions =
                ref.read(transactionsProvider).transactions;
            var activeLeague = ref.watch(utilsProvider
                .select((connection) => connection.activeLeagueId!));

            Map<int, DraftPlayer> players =
                ref.read(draftPlayersProvider).players;
            Gameweek gameweek = ref.watch(gameweekProvider)!;
            String currentGameweek = gameweek.waiversProcessed
                ? (int.parse(gameweek.currentGameweek) + 1).toString()
                : gameweek.currentGameweek;

            if (!waiversFiltered) {
              _draftTeams = teams.keys.toList();
              visibleWaivers = [];
              visibleFreeAgents = [];

              if (transactions[activeLeague]![currentGameweek] != null) {
                for (Transaction transaction
                    in transactions[activeLeague]![currentGameweek]!) {
                  if (transaction.type == "w") {
                    visibleWaivers.add(transaction);
                  } else if (transaction.type == "f") {
                    visibleFreeAgents.add(transaction);
                  }
                }
              }
            }

            visibleWaivers.sort((a, b) =>
                int.parse(a.priority).compareTo(int.parse(b.priority)));

            return Scaffold(
              appBar: DraftAppBar(
                leading: true,
                settings: false,
              ),
              body: DefaultTabController(
                  length: 2, // length of tabsDraft not complete
                  initialIndex: 0,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: const TabBar(
                            tabs: [
                              Tab(text: 'Waivers'),
                              Tab(text: 'Free Agents'),
                              // Tab(text: 'Trades')
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(children: <Widget>[
                            RefreshIndicator(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              onRefresh: () async {
                                ref.refresh(allTransactions);
                              },
                              child: waiversTab(
                                  _draftTeamFilters,
                                  transactions,
                                  activeLeague,
                                  currentGameweek,
                                  teams,
                                  players),
                            ),
                            RefreshIndicator(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              onRefresh: () async {
                                ref.refresh(allTransactions);
                              },
                              child: freeAgentsTab(
                                _draftTeamFilters,
                                players,
                                teams,
                                transactions,
                                activeLeague,
                                currentGameweek,
                              ),
                            ),
                            // const Center(child: Text("Coming soon..."))
                          ]),
                        )
                      ])),

              // Show next GW Fixtures
              // Option to navigate between each GW
            );
          });
    } catch (e) {
      return CustomError();
    }
  }

  SingleChildScrollView freeAgentsTab(
    List<MultiSelectItem<int>> _draftTeamFilters,
    Map<int, DraftPlayer> players,
    Map<int, DraftTeam> teams,
    Map<String, Map<String, List<Transaction>>> transactions,
    String activeLeague,
    String currentGameweek,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          if (visibleFreeAgents.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                      child: Text("Player In",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  child: Center(
                      child: Text("Player Out",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                Text("Draft Teams",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // MultiSelectBottomSheetField(
                //   initialChildSize: 0.5,
                //   title: const Text("Draft Teams"),
                //   buttonText: const Text("Draft Teams"),
                //   chipDisplay:
                //       MultiSelectChipDisplay.none(),
                //   items: _draftTeamFilters,
                //   listType: MultiSelectListType.LIST,
                //   onConfirm: (values) {
                //     // _selectedAnimals = values;
                //   },
                // ),
                // Expanded(
                //   child: Center(child: Text("Team", style: TextStyle(fontWeight: FontWeight.bold))),
                // ),
                Expanded(
                  child: Center(
                      child: Text("Result",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                )
              ],
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: visibleFreeAgents.length,
              itemBuilder: (context, i) {
                Transaction _transaction = visibleFreeAgents[i];
                DraftPlayer playerIn =
                    players[int.parse(_transaction.playerInId)]!;
                DraftPlayer playerOut =
                    players[int.parse(_transaction.playerOutId)]!;
                DraftTeam? _team;
                for (DraftTeam team in teams.values) {
                  if (team.entryId.toString() ==
                      _transaction.teamId.toString()) {
                    _team = team;
                  }
                }
                if (_transaction.type == "f") {
                  return Column(
                    children: [
                      const Divider(
                        thickness: 2,
                      ),
                      Waiver(
                        transaction: _transaction,
                        playerIn: playerIn,
                        playerOut: playerOut,
                        team: _team,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ] else ...[
            const SizedBox(
              height: 10,
            ),
            Center(child: const Text("No Free Agents this week"))
          ]
        ],
      ),
    );
  }

  SingleChildScrollView waiversTab(
      List<MultiSelectItem<int>> _draftTeamFilters,
      Map<String, Map<String, List<Transaction>>> transactions,
      String activeLeague,
      String currentGameweek,
      Map<int, DraftTeam> teams,
      Map<int, DraftPlayer> players) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          if (visibleWaivers.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Text("Player In",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Text("Player Out",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                      child: Text("Draft Teams",
                          style: TextStyle(fontWeight: FontWeight.bold))

                      // MultiSelectBottomSheetField(
                      //   initialChildSize: 0.5,
                      //   title: const Text("Draft Teams"),
                      //   buttonText: const Text("Draft Teams",
                      //       style: TextStyle(
                      //           fontWeight: FontWeight.bold)),
                      //   searchable: true,
                      //   chipDisplay:
                      //       MultiSelectChipDisplay.none(),
                      //   items: _draftTeamFilters,
                      //   initialValue: _draftTeams,
                      //   listType: MultiSelectListType.CHIP,
                      //   onConfirm: (values) {
                      //     filterWaiversAndFreeAgents(
                      //         values,
                      //         transactions,
                      //         activeLeague,
                      //         currentGameweek,
                      //         teams);
                      //   },
                      // ),
                      ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                      child: Text("Result",
                          style: TextStyle(fontWeight: FontWeight.bold))
                      // MultiSelectBottomSheetField(
                      //   initialChildSize: 0.5,
                      //   title: const Text("Result"),
                      //   buttonText: const Text("Result"),
                      //   chipDisplay:
                      //       MultiSelectChipDisplay.none(),
                      //   items: waiverResults,
                      //   initialValue: _waiverResults,
                      //   listType: MultiSelectListType.CHIP,
                      //   onConfirm: (values) {
                      //     print(values);

                      //     if ((values.contains("a") && values.contains("r")) || values.isEmpty) {
                      //       for (Transaction _transaction
                      //           in transactions[
                      //                   activeLeague]![
                      //               currentGameweek]!) {
                      //         _transaction.visible = true;
                      //       }
                      //     } else if (values.contains("a")) {
                      //       for (Transaction _transaction
                      //           in transactions[
                      //                   activeLeague]![
                      //               currentGameweek]!) {
                      //         if (_transaction.result ==
                      //             "a") {
                      //           _transaction.visible = true;
                      //         } else {
                      //           _transaction.visible = false;
                      //         }
                      //       }
                      //     } else if (values.contains("r")) {
                      //       for (Transaction _transaction
                      //           in transactions[
                      //                   activeLeague]![
                      //               currentGameweek]!) {
                      //         if (_transaction.result !=
                      //             "a") {
                      //           _transaction.visible = true;
                      //         } else {
                      //           _transaction.visible = false;
                      //         }
                      //       }
                      //     }
                      //     setState(() {

                      //     });
                      //   },
                      // ),
                      ),
                ),
              ],
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: visibleWaivers.length,
              itemBuilder: (context, i) {
                List<Transaction> _transactions = [];
                Transaction _transaction = visibleWaivers[i];
                DraftPlayer playerIn =
                    players[int.parse(_transaction.playerInId)]!;
                DraftPlayer playerOut =
                    players[int.parse(_transaction.playerOutId)]!;
                DraftTeam? _team;
                for (DraftTeam team in teams.values) {
                  if (team.entryId.toString() ==
                      _transaction.teamId.toString()) {
                    _team = team;
                  }
                }
                if (_transaction.visible && _transaction.type == "w") {
                  _transactions.add(_transaction);
                }

                return Column(
                  children: [
                    const Divider(
                      thickness: 2,
                    ),
                    Waiver(
                      transaction: _transaction,
                      playerIn: playerIn,
                      playerOut: playerOut,
                      team: _team,
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text("No Waivers this GW"),
            )
          ]
        ],
      ),
    );
  }

  void filterWaiversAndFreeAgents(
      List<Object?> values,
      Map<String, Map<String, List<Transaction>>> transactions,
      String activeLeague,
      String currentGameweek,
      Map<int, DraftTeam> teams) {
    List<Object?> _teams = values;
    List<Transaction> _visibleWaivers = [];
    List<Transaction> _visibleFreeAgents = [];
    for (Transaction _transaction
        in transactions[activeLeague]![currentGameweek]!) {
      if (values.isEmpty && _transaction.type == "w") {
        _visibleWaivers.add(_transaction);
        _transaction.visible = true;
        _teams = teams.keys.toList();
      } else if (values.contains(int.parse(_transaction.teamId)) &&
          _transaction.type == "w") {
        _visibleWaivers.add(_transaction);
        _transaction.visible = true;
      } else if (values.contains(int.parse(_transaction.teamId)) &&
          _transaction.type == "f") {
        _visibleFreeAgents.add(_transaction);
        _transaction.visible = true;
      } else {
        _transaction.visible = false;
      }
    }

    setState(() {
      visibleWaivers = _visibleWaivers;
      visibleFreeAgents = _visibleFreeAgents;
      waiversFiltered = true;
      _draftTeams = _teams;
    });
  }
}

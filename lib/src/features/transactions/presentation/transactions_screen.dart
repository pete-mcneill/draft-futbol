import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/transactions/application/transaction_service.dart';
import 'package:draft_futbol/src/features/transactions/application/transactions_controller.dart';
import 'package:draft_futbol/src/features/transactions/domain/trades.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
// import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:draft_futbol/src/exceptions/custom_error.dart';
import 'package:draft_futbol/src/common_widgets/loading.dart';
import 'package:draft_futbol/src/features/transactions/presentation/transactions_bottom_bar.dart';
import 'package:draft_futbol/src/features/transactions/presentation/waivers/player_waiver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// TODO: Fetcher for Transactions doesn't Work yet

class Transactions extends ConsumerStatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<Transactions>
    with TickerProviderStateMixin {
  late final Future transactions_data;
  late TabController _tabController;
  Map<int, DraftTeam> teams = {};
  Map<int, DraftPlayer> players = {};
  List<Transaction> waivers = [];
  List<Transaction> freeAgents = [];
  List<dynamic> teamsFiltered = [];
  List<dynamic> transactionsFiltered = [];
  Map<int, List<DraftTeam>> selectedTeamIds = {};
  List<int> selectedGameweeks = [];
  List<int> possibleGameweeks = [];
  List<String> possibleWaiverResults = ["a", "r"];
  List<String> selectedWaiverResults = [];
  int navBarIndex = 0;

  List<DropdownMenuItem<String>> menuOptions = [];
  List<DropdownMenuItem<String>> gwOptions = [];
  final List<String?> transactionFilters = ["a", "r"];
  bool waiverFiltersActive = false;
  bool faFiltersActive = false;
  Gameweek? currentGW;
  int? currentGameweek;

  var transactionResult = [
    MultiSelectItem("a", "Accepted"),
    MultiSelectItem("r", "Rejected")
  ];

  TabController getTabController(int tabLength) {
    return TabController(length: tabLength, vsync: this);
  }

  List<Widget> buildWaiversFreeAgentsTrades() {
    return <Widget>[
      // Waivers
      TabBarView(
        controller: _tabController,
        children: getWaivers(),
      ),
      // Free Agents
      TabBarView(
        controller: _tabController,
        children: getFreeAgents(),
      ),
      // Trades
      TabBarView(
        controller: _tabController,
        children: getTrades(),
      ),
    ];
  }

  Padding filterTransactions(int leagueId) {
    List<DraftTeam> _teams = ref
        .read(draftDataControllerProvider)
        .teams
        .values
        .where((team) => team.leagueId == leagueId)
        .toList();
    _teams.sort((a, b) => a.teamName!.compareTo(b.teamName!));
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          margin: const EdgeInsets.all(0),
          elevation: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Gameweek(s)",
              ),
              CustomDropdown<int>.multiSelect(
                headerListBuilder: (context, selectedItem, enabled) {
                  return Text(
                    selectedItem.map((e) => e.toString()).join(", "),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
                listItemBuilder: (context, item, isSelected, onItemSelect) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      CupertinoCheckbox(
                        value: isSelected,
                        onChanged: (_) => onItemSelect(),
                      ),
                    ],
                  );
                },
                decoration: CustomDropdownDecoration(
                  closedFillColor: Theme.of(context)
                      .dropdownMenuTheme
                      .inputDecorationTheme!
                      .fillColor!,
                  expandedFillColor: Theme.of(context)
                      .dropdownMenuTheme
                      .inputDecorationTheme!
                      .fillColor!,
                  listItemDecoration: ListItemDecoration(
                      selectedColor: Theme.of(context)
                          .dropdownMenuTheme
                          .inputDecorationTheme!
                          .fillColor),
                  closedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  expandedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey,
                  ),
                ),
                items: possibleGameweeks,
                initialItems: selectedGameweeks,
                onListChanged: (value) {
                  setState(() {
                    selectedGameweeks = value;
                  });
                },
              ),
              Text(
                "Select Teams",
              ),
              CustomDropdown<DraftTeam>.multiSelect(
                headerListBuilder: (context, selectedItem, enabled) {
                  print(selectedItem);
                  String header = 'Teams';
                  int leagueSize = ref
                      .read(draftDataControllerProvider)
                      .leagues[leagueId]!
                      .teams
                      .length;
                  if (selectedItem.length == leagueSize) {
                    header = 'All Teams';
                  } else if (selectedItem.length < leagueSize &&
                      selectedItem.length > 1) {
                    header = 'Multiple Teams';
                  } else if (selectedItem.length == 1) {
                    header = selectedItem[0].teamName!;
                  }
                  return Text(
                    header,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
                listItemBuilder: (context, item, isSelected, onItemSelect) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.teamName!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      CupertinoCheckbox(
                        value: isSelected,
                        onChanged: (_) => onItemSelect(),
                      ),
                    ],
                  );
                },
                decoration: CustomDropdownDecoration(
                  closedFillColor: Theme.of(context)
                      .dropdownMenuTheme
                      .inputDecorationTheme!
                      .fillColor!,
                  expandedFillColor: Theme.of(context)
                      .dropdownMenuTheme
                      .inputDecorationTheme!
                      .fillColor!,
                  listItemDecoration: ListItemDecoration(
                      selectedColor: Theme.of(context)
                          .dropdownMenuTheme
                          .inputDecorationTheme!
                          .fillColor),
                  closedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  expandedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey,
                  ),
                ),
                items: _teams,
                initialItems: selectedTeamIds[leagueId],
                onListChanged: (value) {
                  setState(() {
                    selectedTeamIds[leagueId] = value;
                  });
                  print("Rebuild");
                },
              ),
              if (navBarIndex == 0)
                Text(
                  "Result",
                ),
              if (navBarIndex == 0)
                CustomDropdown<String>.multiSelect(
                  headerListBuilder: (context, selectedItem, enabled) {
                    String text = 'All';
                    if (selectedItem.length == 1) {
                      if (selectedItem[0] == 'a') {
                        text = 'Accepted';
                      } else if (selectedItem[0] == 'r') {
                        text = 'Rejected';
                      }
                    }
                    return Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    String text;
                    if (item == 'a') {
                      text = 'Accepted';
                    } else if (item == 'r') {
                      text = 'Rejected';
                    } else {
                      text = '';
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        CupertinoCheckbox(
                          value: isSelected,
                          onChanged: (_) => onItemSelect(),
                        ),
                      ],
                    );
                  },
                  decoration: CustomDropdownDecoration(
                    closedFillColor: Theme.of(context)
                        .dropdownMenuTheme
                        .inputDecorationTheme!
                        .fillColor!,
                    expandedFillColor: Theme.of(context)
                        .dropdownMenuTheme
                        .inputDecorationTheme!
                        .fillColor!,
                    listItemDecoration: ListItemDecoration(
                        selectedColor: Theme.of(context)
                            .dropdownMenuTheme
                            .inputDecorationTheme!
                            .fillColor),
                    closedSuffixIcon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    expandedSuffixIcon: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey,
                    ),
                  ),
                  items: possibleWaiverResults,
                  initialItems: selectedWaiverResults,
                  onListChanged: (value) {
                    setState(() {
                      selectedWaiverResults = value;
                    });
                  },
                ),
              Center(
                child: ElevatedButton(
                  child: Text("Reset Filters"),
                  onPressed: () {
                    Map<int, List<DraftTeam>> _selectedTeamIds = {};
                    for (DraftLeague league in ref
                        .read(draftDataControllerProvider)
                        .leagues
                        .values) {
                      _selectedTeamIds[league.leagueId] = [];
                      List<DraftTeam> _teams = ref
                          .read(draftDataControllerProvider)
                          .teams
                          .values
                          .where((team) => team.leagueId == league.leagueId)
                          .toList();
                      for (DraftTeam team in _teams) {
                        _selectedTeamIds[league.leagueId]!.add(team);
                      }
                      setState(() {
                        selectedGameweeks = [
                          ref
                              .read(liveDataControllerProvider)
                              .gameweek!
                              .currentGameweek
                        ];
                        selectedTeamIds = _selectedTeamIds;
                        selectedWaiverResults = ["a", "r"];
                      });
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  List<Widget> getWaivers() {
    Map<int, DraftLeague> leagues =
        ref.read(draftDataControllerProvider).leagues;
    Map<int, List<Transaction>> waivers =
        ref.read(transactionsControllerProvider).waivers;
    return <Widget>[
      for (DraftLeague league in leagues.values)
        SingleChildScrollView(
            child: Column(
          children: [
            filterTransactions(league.leagueId),
            const SizedBox(height: 20),
            waiversFreeAgentsHeader(),
            if (waivers[league.leagueId]?.isNotEmpty ?? false)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: waivers[league.leagueId]!
                    .where((element) =>
                        selectedGameweeks.contains(element.gameweek))
                    .length,
                itemBuilder: (context, i) {
                  List<Transaction> transactions = waivers[league.leagueId]!
                      .where((element) =>
                          selectedGameweeks.contains(element.gameweek))
                      .toList();
                  transactions.sort((a, b) =>
                      int.parse(a.priority).compareTo(int.parse(b.priority)));
                  Transaction _transaction = transactions[i];
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
                  String waiverResult = _transaction.result;
                  if (['di', 'do'].contains(waiverResult)) {
                    waiverResult = 'r';
                  }
                  if (selectedTeamIds[league.leagueId]!.contains(_team) &&
                      selectedWaiverResults.contains(waiverResult)) {
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
                  } else {
                    return const SizedBox();
                  }
                },
              )
            else
              Text("No Waivers made for this League yet")
          ],
        ))
    ];
  }

  List<Widget> getFreeAgents() {
    Map<int, DraftLeague> leagues =
        ref.read(draftDataControllerProvider).leagues;
    Map<int, List<Transaction>> freeAgents =
        ref.read(transactionsControllerProvider).freeAgents;
    return <Widget>[
      for (DraftLeague league in leagues.values)
        SingleChildScrollView(
            child: Column(
          children: [
            filterTransactions(league.leagueId),
            const SizedBox(height: 20),
            waiversFreeAgentsHeader(),
            if (freeAgents[league.leagueId]?.isNotEmpty ?? false)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: freeAgents[league.leagueId]!
                    .where((element) =>
                        selectedGameweeks.contains(element.gameweek))
                    .length,
                itemBuilder: (context, i) {
                  List<Transaction> transactions = freeAgents[league.leagueId]!
                      .where((element) =>
                          selectedGameweeks.contains(element.gameweek))
                      .toList();
                  Transaction _transaction = transactions[i];
                  DraftPlayer playerIn =
                      players[int.parse(_transaction.playerInId)]!;
                  DraftPlayer playerOut =
                      players[int.parse(_transaction.playerOutId)]!;
                  DraftTeam? _team;
                  for (DraftTeam team in teams.values) {
                    if (team.entryId.toString() ==
                            _transaction.teamId.toString() &&
                        selectedTeamIds[league.leagueId]!.contains(team)) {
                      _team = team;
                    }
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
              )
            else
              Text("No Free Agents for this league yet")
          ],
        ))
    ];
  }

  List<Widget> getTrades() {
    Map<int, DraftLeague> leagues =
        ref.read(draftDataControllerProvider).leagues;
    Map<int, List<Trade>> trades =
        ref.read(transactionsControllerProvider).trades;
    return <Widget>[
      for (DraftLeague league in leagues.values)
        SingleChildScrollView(
            child: Column(
          children: [
            filterTransactions(league.leagueId),
            const SizedBox(height: 20),
            waiversFreeAgentsHeader(),
            if (trades[league.leagueId]?.isNotEmpty ?? false)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: trades[league.leagueId]!
                    .where((element) =>
                        selectedGameweeks.contains(element.gameweek))
                    .length,
                itemBuilder: (context, i) {
                  List<Trade> _trades = trades[league.leagueId]!
                      .where((element) =>
                          selectedGameweeks.contains(element.gameweek))
                      .toList();
                  if (_trades.isEmpty) {
                    return const Text("No Trades for the selected filter");
                  }
                  Trade _trade = _trades[i];
                  DraftTeam offeringTeam = teams.entries
                      .firstWhere(
                          (team) => team.value.entryId == _trade.offeringTeam)
                      .value;
                  DraftTeam receivingTeam = teams.entries
                      .firstWhere(
                          (team) => team.value.entryId == _trade.receivingTeam)
                      .value;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    margin: const EdgeInsets.all(0),
                    elevation: 10,
                    child: Column(
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: Text("${offeringTeam.teamName}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                              child: Column(
                                children: [
                                  Text('GW${_trade.gameweek.toString()}'),
                                  IconButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                                      icon: const FaIcon(
                                          FontAwesomeIcons.rightLeft),
                                      onPressed: () {
                                        print("Pressed");
                                      }),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Text("${receivingTeam.teamName}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)))
                          ],
                        ),
                        for (var set in _trade.players) getPlayers(set),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  );
                },
              )
            else
              Text("No Trades for this league yet")
          ],
        ))
    ];
  }

  Row getPlayers(TradePlayers tradeSet) {
    Map<int, DraftPlayer> _players =
        ref.read(premierLeagueControllerProvider).players;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 3,
            child: Text(
              _players![tradeSet.playerIn]!.playerName!,
              textAlign: TextAlign.center,
            )),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 70,
            height: 70,
            child: ClipOval(
              child: Image.network(
                "https://resources.premierleague.com/premierleague/photos/players/110x140/p${_players![tradeSet.playerIn]!.playerCode}.png",
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 70,
            height: 70,
            child: ClipOval(
              child: Image.network(
                "https://resources.premierleague.com/premierleague/photos/players/110x140/p${_players![tradeSet.playerOut]!.playerCode}.png",
              ),
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Text(_players![tradeSet.playerOut]!.playerName!,
                textAlign: TextAlign.center))
      ],
    );
  }

  Widget waiversFreeAgentsHeader() {
    return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Expanded(
        flex: 2,
        child: Center(
            child: Text("Player In",
                style: TextStyle(fontWeight: FontWeight.bold))),
      ),
      const Expanded(
        flex: 2,
        child: Center(
            child: Text("Player Out",
                style: TextStyle(fontWeight: FontWeight.bold))),
      ),
      const Expanded(
        flex: 2,
        child: Center(
            child: Text("Team", style: TextStyle(fontWeight: FontWeight.bold))),
      ),
      const Expanded(
        flex: 2,
        child: Center(
            child:
                Text("Result", style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    currentGW = ref.read(liveDataControllerProvider).gameweek!;
    currentGameweek = (currentGW!.waiversProcessed
        ? (currentGW!.currentGameweek + 1)
        : currentGW!.currentGameweek);
    players = ref.read(premierLeagueControllerProvider).players;
    teams = ref.read(draftDataControllerProvider).teams;
    return FutureBuilder<void>(
        future: transactions_data,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              appBar: DraftAppBarV1(
                leading: true,
                settings: false,
                tabController: _tabController,
              ),
              bottomNavigationBar: TransactionsBottomBar(
                updateIndex: (index) {
                  setState(() {
                    navBarIndex = index;
                  });
                },
                currentIndex: navBarIndex,
              ),
              body: buildWaiversFreeAgentsTrades()[navBarIndex],
            );
          }
        });
  }

  // config.when(
  //     loading: () => const Loading(),
  //     error: (err, stack) => Text('Error: $err'),

  //       if(!waiverFiltersActive){
  //         _draftTeams =  teams.entries.map((team) => team.value.entryId).toList();
  //         filterTransactions("w", _draftTeams, teams, transactionFilters);
  //       }

  //       if(!faFiltersActive){
  //         _draftTeams =  teams.entries.map((team) => team.value.entryId).toList();
  //         filterTransactions("f", _draftTeams, teams, transactionFilters);
  //       }

  //       if(waivers.isEmpty && freeAgents.isEmpty) {
  //         return Scaffold(
  //           appBar: DraftAppBar(
  //             leading: true,
  //             settings: false,
  //           ),
  //           body: const Center(child: Text("No Transactions made this GW")));
  //       }

  //       return Scaffold(
  //         appBar: DraftAppBar(
  //           leading: true,
  //           settings: false,
  //         ),
  //         body: DefaultTabController(

  //             length: 2, // length of tabsDraft not complete
  //             initialIndex: 0,
  //             child: Builder(
  //               builder: (context) {
  //                 final TabController controller = DefaultTabController.of(context);
  //                 controller.addListener(() {
  //                   if (!controller.indexIsChanging) {
  //                     if(controller.index == 0){
  //                       filterTransactions(
  //                         "w",
  //                         teams.entries.map((team) => team.value.entryId).toList(),
  //                         teams,
  //                          ["a", "r"]);
  //                     }
  //                     if(controller.index == 1){
  //                       filterTransactions("f",
  //                       teams.entries.map((team) => team.value.entryId).toList(),
  //                       teams,
  //                        ["a", "r"]);
  //                     }
  //                     print("Make Change here");
  //                   }
  //                 });
  //                 return Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       Container(
  //                         child: const TabBar(
  //                           tabs: [
  //                             Tab(text: 'Waivers'),
  //                             Tab(text: 'Free Agents'),
  //                             // Tab(text: 'Trades')
  //                           ],
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: TabBarView(children: <Widget>[
  //                           RefreshIndicator(
  //                             color: Theme.of(context)
  //                                 .colorScheme
  //                                 .secondaryContainer,
  //                             onRefresh: () async {
  //                               ref.refresh(allTransactions);
  //                             },
  //                             child: getTab(teamsDropdownItems, waivers, "w"),
  //                           ),
  //                           RefreshIndicator(
  //                             color: Theme.of(context)
  //                                 .colorScheme
  //                                 .secondaryContainer,
  //                             onRefresh: () async {
  //                               ref.refresh(allTransactions);
  //                             },
  //                             child: getTab(teamsDropdownItems, freeAgents, "f"),
  //                           ),
  //                           // const Center(child: Text("Coming soon..."))
  //                         ]),
  //                       )
  //                     ]);
  //               }
  //             )),

  //         // Show next GW Fixtures
  //         // Option to navigate between each GW
  //       );
  //     });
  // // return Text("Transactions");

  @override
  void dispose() {
    super.dispose();
  }

  List<Transaction> getTransactionByType(
      String transactionType, List<Transaction> transactions) {
    List<Transaction> _transactions = [];
    for (Transaction transaction in transactions) {
      if (transaction.type == transactionType) {
        _transactions.add(transaction);
      }
    }
    return _transactions;
  }

  // List<Transaction> filterTransactions(
  //     String transactionType,
  //     List<dynamic> teamsFilter,
  //     Map<int, DraftTeam> teams,
  //     List<dynamic> transactionFilter) {
  //   // Map<int, Map<int, List<Transaction>>> allTransactions = ref.read(transactionsProvider).transactions;
  //   int activeLeague = ref.read(appSettingsRepositoryProvider).activeLeagueId;
  //   // List<Transaction> transactions = getTransactionByType(transactionType, allTransactions[activeLeague]![currentGameweek]!);
  //   List<Transaction> filteredTransactions = [];
  //   List<String> _transactionsTransform = [];
  //   if (transactionFilter.contains("a")) {
  //     _transactionsTransform.add("a");
  //   }
  //   if (transactionFilter.contains("r")) {
  //     _transactionsTransform.add("do");
  //     _transactionsTransform.add("di");
  //   }
  //   // for(Transaction _transaction in transactions) {
  //   //   if(teamsFilter.any((item) => item == int.parse(_transaction.teamId)) && _transactionsTransform.any((item) => item == _transaction.result)){
  //   //     filteredTransactions.add(_transaction);
  //   //   }
  //   // }
  //   if (transactionType == "w") {
  //     filteredTransactions.sort(
  //         (a, b) => int.parse(a.priority).compareTo(int.parse(b.priority)));
  //   }
  //   if (transactionType == "w") {
  //     setState(() {
  //       waivers = filteredTransactions;
  //       teamsFiltered = teamsFilter;
  //       transactionsFiltered = transactionFilter;
  //       waiverFiltersActive = true;
  //     });
  //   }
  //   if (transactionType == "f") {
  //     setState(() {
  //       freeAgents = filteredTransactions;
  //       teamsFiltered = teamsFilter;
  //       transactionsFiltered = transactionFilter;
  //       faFiltersActive = true;
  //     });
  //   }
  //   return filteredTransactions;
  // }

  // SingleChildScrollView getTab(List<MultiSelectItem<int>> teamDropdownItems,
  //     List<Transaction> transactions, String transactionType) {
  //   return SingleChildScrollView(
  //     child: Column(children: [
  //       const SizedBox(
  //         height: 15,
  //       ),
  //       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //         const Expanded(
  //           flex: 2,
  //           child: Center(
  //               child: Text("Player In",
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //         ),
  //         const Expanded(
  //           flex: 2,
  //           child: Center(
  //               child: Text("Player Out",
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //         ),
  //         Expanded(
  //           flex: 3,
  //           child: Center(
  //             child: MultiSelectBottomSheetField(
  //               selectedColor: Theme.of(context).colorScheme.secondaryContainer,
  //               selectedItemsTextStyle: const TextStyle(color: Colors.white),
  //               itemsTextStyle: const TextStyle(color: Colors.white),
  //               initialChildSize: 0.5,
  //               title: Center(child: Text("Teams")),
  //               buttonText: Text(
  //                 "Team",
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //                 textAlign: TextAlign.center,
  //               ),
  //               searchable: true,
  //               chipDisplay: MultiSelectChipDisplay.none(),
  //               items: teamDropdownItems,
  //               initialValue: _draftTeams,
  //               listType: MultiSelectListType.LIST,
  //               onConfirm: (values) {
  //                 filterTransactions(
  //                     transactionType, values, teams, transactionsFiltered);
  //               },
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 2,
  //           child: Center(
  //             child:
  //                 // Text("Result",
  //                 //     style: TextStyle(fontWeight: FontWeight.bold))
  //                 MultiSelectBottomSheetField(
  //               selectedColor: Theme.of(context).colorScheme.secondaryContainer,
  //               selectedItemsTextStyle: const TextStyle(color: Colors.white),
  //               itemsTextStyle: const TextStyle(color: Colors.white),
  //               initialChildSize: 0.5,
  //               title: const Text("Result"),
  //               buttonText: const Text("Result"),
  //               chipDisplay: MultiSelectChipDisplay.none(),
  //               items: transactionResult,
  //               initialValue: transactionFilters,
  //               listType: MultiSelectListType.LIST,
  //               onConfirm: (values) {
  //                 filterTransactions(
  //                     transactionType, teamsFiltered, teams, values);
  //               },
  //             ),
  //           ),
  //         ),
  //       ]),
  //       ListView.builder(
  //         physics: const NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: transactions.length,
  //         itemBuilder: (context, i) {
  //           Transaction _transaction = transactions[i];
  //           DraftPlayer playerIn = players[int.parse(_transaction.playerInId)]!;
  //           DraftPlayer playerOut =
  //               players[int.parse(_transaction.playerOutId)]!;
  //           DraftTeam? _team;
  //           for (DraftTeam team in teams.values) {
  //             if (team.entryId.toString() == _transaction.teamId.toString()) {
  //               _team = team;
  //             }
  //           }
  //           return Column(
  //             children: [
  //               const Divider(
  //                 thickness: 2,
  //               ),
  //               Waiver(
  //                 transaction: _transaction,
  //                 playerIn: playerIn,
  //                 playerOut: playerOut,
  //                 team: _team,
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ]),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    final List<DraftLeague> leagues =
        ref.read(draftDataControllerProvider).leagues.values.toList();
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    _tabController = getTabController(leagues.length);
    final transactionService = ref.read(transactionsServiceProvider);
    transactions_data = transactionService.getTransactions();
    selectedGameweeks.add(gameweek.currentGameweek);
    for (var i = gameweek.currentGameweek; i > 0; i--) {
      possibleGameweeks.add(i);
    }
    if (gameweek.gameweekFinished) {
      possibleGameweeks.add(gameweek.currentGameweek + 1);
    }
    for (DraftLeague league in leagues) {
      selectedTeamIds[league.leagueId] = [];
      List<DraftTeam> _teams = ref
          .read(draftDataControllerProvider)
          .teams
          .values
          .where((team) => team.leagueId == league.leagueId)
          .toList();
      for (DraftTeam team in _teams) {
        selectedTeamIds[league.leagueId]!.add(team);
      }
    }
    selectedWaiverResults = ["a", "r"];
  }

  // void setPossibleGameweeks() {
  //   for (var i = 1; i <= currentGW!; i++) {
  //     gwOptions.add(DropdownMenuItem(
  //         value: i.toString(),
  //         child: Center(
  //           child: Text(
  //             i.toString(),
  //             style: const TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //           ),
  //         )));
  //   }
  // }
}

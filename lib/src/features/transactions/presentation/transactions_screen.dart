import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/transactions/domain/transactions.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:draft_futbol/src/exceptions/custom_error.dart';
import 'package:draft_futbol/src/common_widgets/loading.dart';
import 'package:draft_futbol/src/features/transactions/presentation/waivers/player_waiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// TODO: Fetcher for Transactions doesn't Work yet

class Transactions extends ConsumerStatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<Transactions> {
  Map<int, DraftTeam> teams = {};
  Map<int, DraftPlayer> players = {};
  List<Transaction> waivers = [];
  List<Transaction> freeAgents = [];
  List<dynamic> teamsFiltered = [];
  List<dynamic> transactionsFiltered = [];


  List<DropdownMenuItem<String>> menuOptions = [];
  List<DropdownMenuItem<String>> gwOptions = [];
  final List<String?> transactionFilters = ["a", "r"];
   List<int?> _draftTeams = [];
  bool waiverFiltersActive = false;
  bool faFiltersActive = false;
  Gameweek? currentGW;
  int? currentGameweek;
  int? dropdownValue;

  var transactionResult = [
    MultiSelectItem("a", "Accepted"),
    MultiSelectItem("r", "Rejected")
  ];

  @override
  Widget build(BuildContext context) {
    currentGW = ref.watch(liveDataRepositoryProvider).gameweek!;
    currentGameweek = (currentGW!.waiversProcessed
                ? (currentGW!.currentGameweek + 1)
                : currentGW!.currentGameweek);
    players = ref.read(premierLeagueDataRepositoryProvider).players;
    dropdownValue = ref.watch(appSettingsRepositoryProvider).activeLeagueId;
    teams = ref.read(draftRepositoryProvider).teams;
    final teamsDropdownItems = teams.entries
        .map((key) => MultiSelectItem(key.value.entryId!, key.value.teamName!))
        .toList();
    // TODO get Transactions
    // AsyncValue config = ref.watch();

    try {
      // return config.when(
      //     loading: () => const Loading(),
      //     error: (err, stack) => Text('Error: $err'),
      //     data: (config) {
            
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
      return Text("Transactions");
    } catch (e) {
      return CustomError();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Transaction> getTransactionByType(String transactionType, List<Transaction> transactions) {
    List<Transaction> _transactions = [];
    for (Transaction transaction in transactions) {
      if (transaction.type == transactionType) {
        _transactions.add(transaction);
      }
    }
    return _transactions;
  }

  List<Transaction> filterTransactions(
      String transactionType,
      List<dynamic> teamsFilter,
      Map<int, DraftTeam> teams,
      List<dynamic> transactionFilter) {
    
      // Map<int, Map<int, List<Transaction>>> allTransactions = ref.read(transactionsProvider).transactions;
      int activeLeague = ref.read(appSettingsRepositoryProvider).activeLeagueId;
      // List<Transaction> transactions = getTransactionByType(transactionType, allTransactions[activeLeague]![currentGameweek]!);
      List<Transaction> filteredTransactions = [];
      List<String> _transactionsTransform = [];
      if(transactionFilter.contains("a")){
        _transactionsTransform.add("a");
      }
      if(transactionFilter.contains("r")){
        _transactionsTransform.add("do");
        _transactionsTransform.add("di");
      }
      // for(Transaction _transaction in transactions) {
      //   if(teamsFilter.any((item) => item == int.parse(_transaction.teamId)) && _transactionsTransform.any((item) => item == _transaction.result)){
      //     filteredTransactions.add(_transaction);
      //   }
      // }
      if(transactionType == "w"){
        filteredTransactions.sort((a, b) =>
          int.parse(a.priority).compareTo(int.parse(b.priority)));
      }
      if(transactionType == "w"){
        setState(() {
          waivers = filteredTransactions;
          teamsFiltered = teamsFilter;
          transactionsFiltered = transactionFilter;
          waiverFiltersActive = true;
        });
      }
      if(transactionType == "f"){
        setState(() {
          freeAgents = filteredTransactions;
          teamsFiltered = teamsFilter;
          transactionsFiltered = transactionFilter;
          faFiltersActive = true;
        });
      }
      return filteredTransactions;
  }

  SingleChildScrollView getTab(List<MultiSelectItem<int>> teamDropdownItems, List<Transaction> transactions, String transactionType) {
    return SingleChildScrollView(
      child: Column(children:
      [
          const SizedBox(
            height: 15,
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Expanded(
                flex: 3,
                child: Center(
                  child: MultiSelectBottomSheetField(
                    selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                    selectedItemsTextStyle: const TextStyle(color: Colors.white),
                    itemsTextStyle: const TextStyle(color: Colors.white),
                    initialChildSize: 0.5,
                    title: Center(child: Text("Teams")),
                    buttonText: Text("Team",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                        ),
                        
                    searchable: true,
                    chipDisplay:
                        MultiSelectChipDisplay.none(),
                    items: teamDropdownItems,
                    initialValue: _draftTeams,
                    listType: MultiSelectListType.LIST,
                    onConfirm: (values) {
                      filterTransactions(transactionType, values, teams, transactionsFiltered);
                    },
                  ),
                ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                      child: 
                      // Text("Result",
                      //     style: TextStyle(fontWeight: FontWeight.bold))
                      MultiSelectBottomSheetField(
                        selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                        selectedItemsTextStyle: const TextStyle(color: Colors.white),
                        itemsTextStyle: const TextStyle(color: Colors.white),
                        initialChildSize: 0.5,
                        title: const Text("Result"),
                        buttonText: const Text("Result"),
                        chipDisplay:
                            MultiSelectChipDisplay.none(),
                        items: transactionResult,
                        initialValue: transactionFilters,
                        listType: MultiSelectListType.LIST,
                        onConfirm: (values) {
                          filterTransactions(transactionType, teamsFiltered,  teams, values);
                        },
                      ),
                      ),
                ),
            ]
           ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, i) {
              Transaction _transaction = transactions[i];
              DraftPlayer playerIn =
                  players[int.parse(_transaction.playerInId)]!;
              DraftPlayer playerOut =
                  players[int.parse(_transaction.playerOutId)]!;
              DraftTeam? _team;
              for (DraftTeam team in teams.values) {
                if (team.entryId.toString() == _transaction.teamId.toString()) {
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
          ),
      ]
    ),
    );
  }

  @override
  void initState() {
    super.initState();
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

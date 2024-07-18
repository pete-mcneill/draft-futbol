import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:draft_futbol/src/common_widgets/loading.dart';
import 'package:draft_futbol/src/features/squads/presentation/squad_view/squad_view.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SquadsScreen extends ConsumerStatefulWidget {
  const SquadsScreen({Key? key}) : super(key: key);

  @override
  _SquadsScreenState createState() => _SquadsScreenState();
}

class _SquadsScreenState extends ConsumerState<SquadsScreen> with TickerProviderStateMixin {
  Map<int, DraftTeam>? teams;
  Map<int, DraftPlayer>? players;
  int? activeLeague;
  bool isLoading = false;
  int? selectedGameweek = null;
  late TabController _tabController;
  late final Future<Map<int, List<DraftPlayer>>> futureSquads =
      getSquads(selectedGameweek);

      
  List<DraftPlayer> getSquad(int teamId) {
    var testing = players!.values
        .where((DraftPlayer player) =>
            player.draftTeamId!.containsKey(activeLeague))
        .toList();
    var teamSquad = testing
        .where(
            (DraftPlayer player) => player.draftTeamId![activeLeague] == teamId)
        .toList();
    return teamSquad;
  }

    TabController getTabController(int tabLength) {
    return TabController(length: tabLength, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    final List<int> leagueIds = ref
        .read(dataStoreProvider)
        .getLeagues()
        .map((league) => league.id)
        .toList();
    _tabController = getTabController(leagueIds.length);
  }

    @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> getPlayersFixtures(int teamId, List premierLeagueFixtures) {
    List<String> fixtures = [];
    Map<int, PlTeam>? premierLeagueTeams =
        ref.read(premierLeagueControllerProvider).teams;
    for (var fixture in premierLeagueFixtures) {
      if (fixture['team_a'] == teamId || fixture['team_h'] == teamId) {
        PlTeam oppositionTeam;
        if (fixture['team_a'] == teamId) {
          oppositionTeam = premierLeagueTeams![fixture['team_h']]!;
        } else {
          oppositionTeam = premierLeagueTeams![fixture['team_a']]!;
        }
        fixtures.add(
            "${oppositionTeam.shortName} ${fixture['team_h'] == teamId ? "\(H\)" : '\(A\)'}");
      }
    }
    return fixtures;
  }

  Future<Map<int, List<DraftPlayer>>> getSquads(int? gameweek) async {
    try {
    if (gameweek == null) {
      if (ref.read(liveDataControllerProvider).gameweek!.gameweekFinished) {
        gameweek = ref.read(liveDataControllerProvider).gameweek!
                .currentGameweek +
            1;
      } else {
        gameweek = ref.read(liveDataControllerProvider).gameweek!
            .currentGameweek;
      }
    }

    Map<int, List<DraftPlayer>> squads = {};
    Map<int, DraftPlayer> players = ref.read(premierLeagueControllerProvider).players;
    var premierLeagueFixtures = await Api().getPremierLeagueFixtures(gameweek);
     Map<int, DraftTeam>? teams = ref.read(draftDataControllerProvider).teams;
    for (MapEntry<int, DraftTeam> team in teams.entries) {
      var squad = players.values
          .where((DraftPlayer player) =>
              player.draftTeamId!.containsValue(team.value.entryId))
          .toList();
      print("GOT LEAGUE PLAYERS");
      // for (DraftTeam teamEntry in league.value) {
      //   DraftTeam team = teamEntry.value;
      //   var teamSquad = leaguePlayers
      //       .where((DraftPlayer player) =>
      //           player.draftTeamId![league.key] == team.entryId)
      //       .toList();
        for (var player in squad) {
          player.gameweekFixtures =
              getPlayersFixtures(player.teamId!, premierLeagueFixtures!);
        }
        squads[team.value.entryId!] = squad;
      // }
    }
     return squads;
    } catch (error) {
      throw Error();
    }
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
        // color: Theme.of(context).cardColor,
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

  Widget getLeagueView(AsyncSnapshot<Map<int, List<DraftPlayer>>> snapshot, List<DraftTeam> leagueTeams, List<DropdownMenuItem<String>> menuOptions) {
      return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Center(child: Text("Squad Fixtures for:")),
                              Center(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    // iconEnabledColor: Theme.of(context).secondaryHeaderColor,
                                    isExpanded: false,
                                    items: menuOptions,
                                    onChanged: (value) async {
                                      await getSquads(
                                          int.parse(value.toString()));
                                      setState(() {
                                        selectedGameweek =
                                            int.parse(value.toString());
                                      });
                                    },
                                    value: selectedGameweek.toString(),
                                    // dropdownDecoration: BoxDecoration(
                                    //     color: Theme.of(context).appBarTheme.backgroundColor),
                                  ),
                                ),
                              ),
                              for (DraftTeam team in leagueTeams)
                                Column(
                                  children: [
                                    expansionItem(
                                        index: team.entryId,
                                        teamName: team.teamName,
                                        players: snapshot.data![team.entryId]!),
                                    const SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                            ],
                          ),
                        );
    }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: DraftAppBarV1(
            leading: true,
            settings: false,
            tabController: _tabController,
          ),
          body: const Loading());
    } else {
      List<DropdownMenuItem<String>> menuOptions = [];
      activeLeague = ref.watch(
          appSettingsRepositoryProvider.select((connection) => connection.activeLeagueId));
      teams = ref.read(draftDataControllerProvider).teams;
      List<DraftTeam> filteredTeams = teams!.values.where((DraftTeam team) => team.leagueId == activeLeague).toList();
      Gameweek currentGameweek =
          ref.read(liveDataControllerProvider.select((value) => value.gameweek))!;
      int currentGameweekInt = currentGameweek.currentGameweek;
      if (currentGameweek.gameweekFinished && currentGameweekInt < 38) {
        currentGameweekInt++;
      }
      selectedGameweek ??= currentGameweekInt;
      for (var i = currentGameweekInt; i <= 38; i++) {
        menuOptions.add(DropdownMenuItem(
            value: i.toString(),
            child: Center(
              child: Text(
                "GW $i",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )));
      };

    List<DraftLeague> leagues = ref.read(draftDataControllerProvider).leagues.values.toList();
    



    return Scaffold(
        appBar: DraftAppBarV1(
          leading: true,
          settings: false,
          tabController: _tabController,
        ),
        body: SafeArea(
          child: RefreshIndicator(
              color: Theme.of(context).colorScheme.secondaryContainer,
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                // await ref.refresh(fplGwDataProvider.notifier).refreshData(ref);
                setState(() {
                  isLoading = false;
                });
              },
              child: FutureBuilder<Map<int, List<DraftPlayer>>>(
                future: futureSquads,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<int, List<DraftPlayer>>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error");
                  }

                  if (snapshot.hasData) {
                    List<Widget> leagueViews = [];
                    for(DraftLeague league in leagues){
                      leagueViews.add(RefreshIndicator(
                        child: getLeagueView(snapshot, teams!.values.where((DraftTeam team) => team.leagueId == league.leagueId).toList(), menuOptions),
                        onRefresh: () async {
                          // await refreshData();
                        },
                      ));
                    }
                    try {
                      return Scaffold(
                        body: TabBarView(
                          controller: _tabController,
                          children: leagueViews,
                        ),
                      );
                    } catch (error) {
                      return const Text("Error");
                    }
                  } else {
                    return const Text("loading");
                  }
                },
              )),
        ));
    }
  }
}

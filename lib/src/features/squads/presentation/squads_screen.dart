import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
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

class _SquadsScreenState extends ConsumerState<SquadsScreen> {
  Map<int, DraftTeam>? teams;
  Map<int, DraftPlayer>? players;
  int? activeLeague;
  bool isLoading = false;
  int? selectedGameweek = null;
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

  @override
  void initState() {
    super.initState();
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
    if (gameweek == null) {
      if (ref.read(liveDataRepositoryProvider).gameweek!.gameweekFinished) {
        gameweek = ref.read(liveDataRepositoryProvider).gameweek!
                .currentGameweek +
            1;
      } else {
        gameweek = ref.read(liveDataRepositoryProvider).gameweek!
            .currentGameweek;
      }
    }

    Map<int, List<DraftPlayer>> squads = {};
    Map<int, DraftPlayer> players = ref.read(premierLeagueControllerProvider).players;
    var premierLeagueFixtures = await Api().getPremierLeagueFixtures(gameweek);
     Map<int, DraftTeam>? teams = ref.read(draftDataControllerProvider).teams;
    for (var league in teams!.entries) {
      var leaguePlayers = players.values
          .where((DraftPlayer player) =>
              player.draftTeamId!.containsKey(league.key))
          .toList();
      // for (var teamEntry in league.value) {
      //   DraftTeam team = teamEntry.value;
      //   var teamSquad = leaguePlayers
      //       .where((DraftPlayer player) =>
      //           player.draftTeamId![league.key] == team.entryId)
      //       .toList();
      //   for (var player in teamSquad) {
      //     player.gameweekFixtures =
      //         getPlayersFixtures(player.teamId!, premierLeagueFixtures!);
      //   }
      //   squads[team.entryId!] = teamSquad;
      // }
    }
    return squads;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: DraftAppBar(
            leading: true,
            settings: false,
          ),
          body: const Loading());
    } else {
      List<DropdownMenuItem<String>> menuOptions = [];
      activeLeague = ref.watch(
          appSettingsRepositoryProvider.select((connection) => connection.activeLeagueId));
      teams = ref.read(draftDataControllerProvider).teams;
      Gameweek currentGameweek =
          ref.read(liveDataRepositoryProvider.select((value) => value.gameweek))!;
      int currentGameweekInt = currentGameweek.currentGameweek;
      if (currentGameweek.gameweekFinished) {
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



    return Scaffold(
        appBar: DraftAppBarV1(
          leading: true,
          settings: false,
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
                    try {
                      return Scaffold(
                        body: SingleChildScrollView(
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
                              for (DraftTeam team in teams!.values)
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

import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/api_service.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/draft_player.dart';
import '../../models/draft_team.dart';
import '../widgets/app_bar/draft_app_bar.dart';
import '../widgets/squad_view/squad_view.dart';

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
        ref.read(fplGwDataProvider.select((value) => value.plTeams))!;
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
      if (ref
          .read(fplGwDataProvider.select((value) => value.gameweek))!
          .gameweekFinished) {
        gameweek = ref
                .read(fplGwDataProvider.select((value) => value.gameweek))!
                .currentGameweek +
            1;
      } else {
        gameweek = ref
            .read(fplGwDataProvider.select((value) => value.gameweek))!
            .currentGameweek;
      }
    }

    Map<int, List<DraftPlayer>> squads = {};
    Map<int, DraftPlayer> players =
        ref.read(fplGwDataProvider.select((value) => value.players))!;
    var premierLeagueFixtures = await Api().getPremierLeagueFixtures(gameweek);
    Map<int, Map<int, DraftTeam>>? teams = ref.read(fplGwDataProvider).teams;
    for (var league in teams!.entries) {
      var leaguePlayers = players.values
          .where((DraftPlayer player) =>
              player.draftTeamId!.containsKey(league.key))
          .toList();
      for (var teamEntry in league.value.entries) {
        DraftTeam team = teamEntry.value;
        var teamSquad = leaguePlayers
            .where((DraftPlayer player) =>
                player.draftTeamId![league.key] == team.entryId)
            .toList();
        for (var player in teamSquad) {
          player.gameweekFixtures =
              getPlayersFixtures(player.teamId!, premierLeagueFixtures!);
        }
        squads[team.entryId!] = teamSquad;
      }
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
          utilsProvider.select((connection) => connection.activeLeagueId!));
      teams = ref.read(fplGwDataProvider).teams![activeLeague];
      Gameweek currentGameweek =
          ref.read(fplGwDataProvider.select((value) => value.gameweek))!;
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
        appBar: DraftAppBar(
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
                await ref.refresh(fplGwDataProvider.notifier).refreshData(ref);
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

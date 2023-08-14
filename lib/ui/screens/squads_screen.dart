import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
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
  Map<int, DraftPlayer>? players;
  int? activeLeague;
  bool isLoading = false;

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

  @override
  void dispose() {
    super.dispose();
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
    }

    activeLeague = ref.watch(utilsProvider).activeLeagueId!;
    Map<int, DraftTeam> leagueTeams =
        ref.read(fplGwDataProvider).teams![activeLeague]!;
    players = ref.read(fplGwDataProvider).players;

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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  for (DraftTeam team in leagueTeams.values)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            List<DraftPlayer> _players =
                                getSquad(team.entryId!);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SquadView(
                                          teamName: team.teamName!,
                                          players: _players,
                                        )));
                          },
                          child: SizedBox(
                              height: 50,
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0)),
                                  margin: const EdgeInsets.all(0),
                                  elevation: 10,
                                  child: Center(child: Text(team.teamName!)))),
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}

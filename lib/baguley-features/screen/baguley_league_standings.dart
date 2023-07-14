import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draft_futbol/baguley-features/widgets/baguley_league.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../ui/widgets/app_bar/draft_app_bar.dart';
import '../services/league_service.dart';

class BaguleyLeagueStandings extends ConsumerStatefulWidget {
  String seasonId;
  BaguleyLeagueStandings({Key? key, required this.seasonId}) : super(key: key);

  @override
  _BaguleyLeagueStandingsState createState() => _BaguleyLeagueStandingsState();
}

class _BaguleyLeagueStandingsState
    extends ConsumerState<BaguleyLeagueStandings> {
  Map<int, DraftTeam> teams = {};
  List<Fixture> fixtures = [];
  var leagueData;
  late String currentGameweek;

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
    return Scaffold(
        appBar: DraftAppBar(settings: false),
        body: FutureBuilder<List<LeagueStanding?>>(
          future: getStandings("38", widget.seasonId),
          builder: (BuildContext context,
              AsyncSnapshot<List<LeagueStanding?>> snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            }

            if (snapshot.hasData && snapshot.data != null) {
              return BaguleyLeague(
                  seasonId: widget.seasonId, initialStandings: snapshot.data);
            }

            if (snapshot.connectionState == ConnectionState.done) {
              print("Hello");
              return Text("Hello");
            }

            return Text("loading");
          },
        ));
  }
}

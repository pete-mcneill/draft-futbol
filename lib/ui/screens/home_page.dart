import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/classic_league_standings.dart';
import 'package:draft_futbol/ui/screens/league_standings.dart';
import 'package:draft_futbol/ui/screens/pl_matches_screen.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:draft_futbol/ui/widgets/draft_bottom_bar.dart';
import 'package:draft_futbol/ui/widgets/draft_drawer.dart';
import 'package:draft_futbol/ui/widgets/draft_placeholder.dart';
import 'package:draft_futbol/ui/widgets/h2h/h2h_draft_matches.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/draft_leagues.dart';
import '../../models/draft_team.dart';
import '../widgets/more.dart';

const int maxFailedLoadAttempts = 3;

class HomePage extends ConsumerStatefulWidget {
  final List squads = [];
  final List<int> leagueIds;
  final String leagueType;

  HomePage({Key? key, required this.leagueType, required this.leagueIds})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int navBarIndex = 0;
  bool showBottomNav = true;
  int? activeLeague;

  // ignore: prefer_final_fields
  List<Widget> h2hOptions = <Widget>[
    const H2hDraftMatches(),
    const LeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  List<Widget> classicOptions = <Widget>[
    const ClassicLeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  @override
  Widget build(BuildContext context) {
    return ref.watch(getFplData(widget.leagueIds)).when(
          loading: () => const Loading(),
          error: (err, stack) => Text('Error: $err'),
          data: (config) {
            print(config);
            activeLeague = ref.watch(utilsProvider
                .select((connection) => connection.activeLeagueId!));
            DraftLeague leagueData = config.leagues![activeLeague]!;
            if (leagueData.scoring == 'c' && navBarIndex > 2) {
              updateIndex(2);
            }
            gameweek = config.gameweek;
            String draftStatus = leagueData.draftStatus;
            if (draftStatus == "pre" || gameweek!.currentGameweek == 0) {
              showBottomNav = false;
            } else {
              showBottomNav = true;
              if (leagueData.scoring == "h") {
                fixtures = config
                    .h2hFixtures![activeLeague]![gameweek!.currentGameweek];
              }
            }
            teams = config.teams![activeLeague];
            return Scaffold(
                key: _scaffoldKey,
                appBar: DraftAppBar(
                  settings: true,
                ),
                drawer: const DraftDrawer(),
                bottomNavigationBar: showBottomNav
                    ? DraftBottomBar(
                        updateIndex: updateIndex,
                        leagueType: leagueData.scoring,
                        currentIndex: navBarIndex,
                      )
                    : const SizedBox(),
                body: SafeArea(
                    child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.center,
                  child: Container(
                    // color: Theme.of(context).scaffoldBackgroundColor,
                    // margin:
                    //     const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    // alignment: FractionalOffset.center,
                    child: draftStatus == "pre" ||
                            gameweek!.currentGameweek == 0
                        ? DraftPlaceholder(
                            leagueData: leagueData,
                          )
                        : RefreshIndicator(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: leagueData.scoring == 'h'
                                ? h2hOptions[navBarIndex]
                                : classicOptions[navBarIndex],
                            onRefresh: () async {
                              var updatedData = await ref
                                  .refresh(getFplData(widget.leagueIds).future);
                            },
                          ),
                  ),
                )));
          },
        );
  }

  @override
  void dispose() {
    // if (!ref.read(purchasesProvider).noAdverts!) {
    //   _interstitialAd?.dispose();
    // }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // if (!ref.read(purchasesProvider).noAdverts!) {
    //   _createInterstitialAd();
    // }
  }

  updateIndex(int index) {
    setState(() {
      navBarIndex = index;
    });
  }
}

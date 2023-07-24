import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/classic_league_standings.dart';
import 'package:draft_futbol/ui/screens/h2h_draft_matches_screen.dart';
import 'package:draft_futbol/ui/screens/league_standings.dart';
import 'package:draft_futbol/ui/screens/pl_matches_screen.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:draft_futbol/ui/widgets/app_bar/draft_app_bar.dart';
import 'package:draft_futbol/ui/widgets/draft_bottom_bar.dart';
import 'package:draft_futbol/ui/widgets/draft_drawer.dart';
import 'package:draft_futbol/ui/widgets/draft_placeholder.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import '../widgets/more.dart';

class HomePage extends ConsumerStatefulWidget {
  final List squads = [];
  final String leagueType;

  HomePage({Key? key, required this.leagueType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

const int maxFailedLoadAttempts = 3;

class _HomePageState extends ConsumerState<HomePage> {
  Box? advertsBox;
  static const AdRequest request = AdRequest();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  int navBarIndex = 0;
  bool showBottomNav = true;
  String activeLeague = "";
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void initState() {
    advertsBox = Hive.box('adverts');
    super.initState();
    if (!ref.read(purchasesProvider).noAdverts!) {
      _createInterstitialAd();
    }
  }

  @override
  void dispose() {
    if (!ref.read(purchasesProvider).noAdverts!) {
      _interstitialAd?.dispose();
    }
    super.dispose();
  }

  void _createInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: getInterstitialAdUnitIds(),
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            // print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ignore: prefer_final_fields
  List<Widget> h2hOptions = <Widget>[
    const H2hDraftMatchesScreen(),
    const LeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  List<Widget> classicOptions = <Widget>[
    const ClassicLeagueStandings(),
    const PlMatchesScreen(),
    const More()
  ];

  updateIndex(int index) {
    setState(() {
      navBarIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(futureLiveDataProvider).when(
          loading: () => const Loading(),
          error: (err, stack) => Text('Error: $err'),
          data: (config) {
            int advertRefresh = advertsBox!.get("adCounter");
            activeLeague = ref.watch(utilsProvider
                .select((connection) => connection.activeLeagueId!));
            var leagueData =
                ref.watch(draftLeaguesProvider).leagues[activeLeague]!;
            if (leagueData.scoring == 'c' && navBarIndex > 2) {
              updateIndex(2);
            }
            gameweek = ref.watch(gameweekProvider);
            String draftStatus = leagueData.draftStatus;
            if (draftStatus == "pre" || gameweek!.currentGameweek == "null") {
              showBottomNav = false;
            } else {
              showBottomNav = true;
              if (leagueData.scoring == "h") {
                fixtures = ref
                    .read(fixturesProvider)
                    .fixtures[activeLeague]![gameweek!.currentGameweek];
              }
            }
            teams = ref.read(draftTeamsProvider).teams![activeLeague];

            bool noAdverts = ref.watch(purchasesProvider
                .select((connection) => connection.noAdverts!));
            if (advertRefresh >= 9 && !noAdverts) {
              _showInterstitialAd();
              advertsBox!.put('adCounter', 0);
            }
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
                  style: Theme.of(context).textTheme.headline2!,
                  textAlign: TextAlign.center,
                  child: Container(
                    // color: Theme.of(context).scaffoldBackgroundColor,
                    // margin:
                    //     const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    // alignment: FractionalOffset.center,
                    child: draftStatus == "pre" ||
                            gameweek!.currentGameweek == "null"
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
                              ref.refresh(refreshFutureLiveDataProvider);
                              await ref
                                  .read(refreshFutureLiveDataProvider.future);
                            },
                          ),
                  ),
                )));
          },
        );
  }
}

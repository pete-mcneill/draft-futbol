import 'package:draft_futbol/models/draft_leagues.dart';
import 'package:draft_futbol/models/gameweek.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/web/web_h2h.dart';
import 'package:draft_futbol/ui/widgets/app_bar/web_app_bar.dart';
import 'package:draft_futbol/ui/widgets/draft_placeholder.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/classic_league_standings.dart';
import '../screens/league_standings.dart';
import '../screens/pl_matches_screen.dart';
import '../widgets/h2h/h2h_draft_matches.dart';
import '../widgets/more.dart';

class WebHome extends ConsumerStatefulWidget {
  final List<int> leagueIds;
  const WebHome({Key? key, required this.leagueIds}) : super(key: key);

  @override
  WebHomeProvidersState createState() => WebHomeProvidersState();
}

class WebHomeProvidersState extends ConsumerState<WebHome> {
  late String leagueType;
  late Future<void> future;
  late Map<dynamic, dynamic> leagueIds;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width > 1000
        ? 1000
        : MediaQuery.of(context).size.width;
    // ref.read(leagueIdsProvider(widget.leagueIds));
    // var leagueData = ref.watch(asyncHabitTrackingProvider(widget.leagueIds));
    ThemeMode theme = ThemeMode.dark;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Draft Futbol',
        darkTheme: FlexThemeData.dark(
          colors: const FlexSchemeColor(
            primary: Color(0xffb1cff5),
            primaryContainer: Color(0xff3873ba),
            secondary: Color(0xfff57859),
            secondaryContainer: Color(0xfff57859),
            tertiary: Color(0xfff57859),
            tertiaryContainer: Color(0xff994600),
            appBarColor: Color(0xfff57859),
            error: Color(0xffb00020),
          ),
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
          subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              chipRadius: 9.0,
              textButtonSchemeColor: SchemeColor.onPrimary,
              elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
              navigationBarSelectedLabelSchemeColor: SchemeColor.secondary,
              navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
              navigationBarIndicatorOpacity: 1.00,
              navigationBarElevation: 10.0,
              tabBarItemSchemeColor: SchemeColor.secondaryContainer,
              tabBarIndicatorSchemeColor: SchemeColor.secondaryContainer),
          useMaterial3ErrorColors: true,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          // To use the Playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        themeMode: theme,
        home: ref.watch(getFplData(widget.leagueIds)).when(
            loading: () => const Loading(),
            error: (err, stack) => Text('Error: $err'),
            data: (config) {
              int activeLeague = ref.watch(utilsProvider).activeLeagueId!;
              DraftLeague league = config.leagues![activeLeague]!;
              Gameweek gameweek = config.gameweek!;
              if (league.draftStatus == "pre" ||
                  gameweek.currentGameweek == 0) {
                return DefaultTabController(
                    length: 4,
                    child: Scaffold(
                        appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(100.0),
                          child: WebAppBar(
                            leading: false,
                            settings: false,
                            leagueType: league.scoring,
                            hideTabs: true,
                          ),
                        ),
                        body: Center(
                            child: ClipRect(
                                child: SizedBox(
                                    width: screenWidth,
                                    child: DraftPlaceholder(
                                        leagueData: league))))));
              } else if (league.scoring == 'h') {
                return DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100.0),
                      child: WebAppBar(
                        leading: false,
                        settings: false,
                        leagueType: league.scoring,
                      ),
                    ),
                    body: Center(
                        child: ClipRect(
                            child: SizedBox(
                      width: screenWidth,
                      child: TabBarView(
                        children: [
                          H2hDraftMatches(),
                          LeagueStandings(),
                          PlMatchesScreen(),
                          More()
                        ],
                      ),
                    ))),
                  ),
                );
              } else {
                return DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100.0),
                      child: WebAppBar(
                        leading: false,
                        settings: false,
                        leagueType: league.scoring,
                      ),
                    ),
                    body: Center(
                        child: ClipRect(
                            child: SizedBox(
                      width: screenWidth,
                      child: TabBarView(
                        children: [
                          const ClassicLeagueStandings(),
                          const PlMatchesScreen(),
                          const More()
                        ],
                      ),
                    ))),
                  ),
                );
              }
            }));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

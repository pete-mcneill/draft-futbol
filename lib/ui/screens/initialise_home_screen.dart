import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/utils_service.dart';
import 'package:draft_futbol/ui/screens/home_page.dart';
import 'package:draft_futbol/ui/screens/on_boarding_screen.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:draft_futbol/utils/utilities.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

class InitialiseHomeScreen extends ConsumerStatefulWidget {
  const InitialiseHomeScreen({Key? key}) : super(key: key);

  @override
  InitializeProvidersState createState() => InitializeProvidersState();
}

class InitializeProvidersState extends ConsumerState<InitialiseHomeScreen> {
  late String leagueType;
  late Future<void> future;
  late Map<dynamic, dynamic> leagueIds;

  @override
  Widget build(BuildContext context) {
    ThemeMode theme = ThemeMode.dark;
    bool isLightTheme = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Draft Futbol',
      // Theme config for FlexColorScheme version 7.1.x. Make sure you use
// same or higher package version, but still same major version. If you
// use a lower package version, some properties may not be supported.
// In that case remove them after copying this theme to your app.
      theme: FlexThemeData.light(
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
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          chipRadius: 9.0,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff385564),
          primaryContainer: Color(0xff2a9d8f),
          secondary: Color(0xfff57859),
          secondaryContainer: Color(0xfff57859),
          tertiary: Color(0xffed7f29),
          tertiaryContainer: Color(0xff994600),
          appBarColor: Color(0xfff57859),
          error: Color(0xffcf6679),
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
          tabBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,

// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,

// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,

// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,

      // If you do not have a themeMode switch, uncomment this line
      // to let the device system mode control the theme mode:
      // themeMode: ThemeMode.system,

      // theme: widget.themeProvider.themeData(),
      themeMode: theme,
      home: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Loading();
            case ConnectionState.active:
              return const Loading();
            case ConnectionState.waiting:
              return const Loading();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text("Error," + snapshot.error.toString());
              } else {
                // return Loading();
                return checkLeagueIdsSet();
              }
          }
        },
      ),
    );
  }

  Widget checkLeagueIdsSet() {
    Utilities utils = ref.read(utilsProvider);
    if (utils.leagueIds!.isEmpty || !checkLeagueIdsValid(utils.leagueIds!)) {
      return const OnBoardingScreen();
    } else {
      Map<int, dynamic> leagueIds = ref.read(utilsProvider).leagueIds!;
      List<int> ids = leagueIds.keys.toList();
      return HomePage(leagueType: "h", leagueIds: ids);
    }
  }

  bool checkLeagueIdsValid(Map<int, dynamic> leagueIds) {
    for (var league in leagueIds.values) {
      if (league['season'] == null) {
        clearLeagueIds();
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<int, dynamic>> getLeagueIds() async {
    try {
      Map<int, dynamic> _leagueIds = await setLeagueIds();
      ref.read(utilsProvider.notifier).setLeagueIds(_leagueIds);
      ref.read(utilsProvider.notifier).setDefaultActiveLeague();
      return _leagueIds;
    } catch (e) {
      print(e);
      print("Failed to get entitlements");
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    future = _asyncmethodCall();
  }

  Future<Map<int, dynamic>> _asyncmethodCall() async {
    try {
      final settings = await Hive.openBox('settings');
      bool isLightTheme = settings.get('isLightTheme') ?? false;
      isLightTheme
          ? ref.read(utilsProvider.notifier).updateIsLightTheme(true)
          : ref.read(utilsProvider.notifier).updateIsLightTheme(false);
      bool remainingPlayersView = settings.get("remainingPlayersView");
      bool iconsSummaryView = settings.get("iconSummaryView");
      ref
          .read(utilsProvider.notifier)
          .setRemainingPlayersView(remainingPlayersView);
      ref.read(utilsProvider.notifier).setIconSummaryView(iconsSummaryView);
    } catch (e) {
      print(e);
    }

    try {
      return await getLeagueIds();
    } catch (e) {
      print(e);
      return {};
    }
  }
}

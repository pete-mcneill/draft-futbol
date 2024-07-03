import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/home_page.dart';
import 'package:draft_futbol/src/features/onboarding/presentation/on_boarding_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    List<LocalLeagueMetadata> leagues = ref.read(dataStoreProvider).getLeagues();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Draft Futbol',
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
          primary: Color.fromARGB(255, 96, 149, 175),
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
      themeMode: theme,
      home: leagues.isEmpty ? const OnBoardingScreen() : 
              HomePage()
      // FutureBuilder(
      //   future: future,
      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     switch (snapshot.connectionState) {
      //       case ConnectionState.none:
      //         return const Loading();
      //       case ConnectionState.active:
      //         return const Loading();
      //       case ConnectionState.waiting:
      //         return const Loading();
      //       case ConnectionState.done:
      //         if (snapshot.hasError) {
      //           return Text("Error," + snapshot.error.toString());
      //         } else {
      //           // return Loading();
      //           return checkLeagueIdsSet();
      //         }
      //     }
      //   },
      // ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
  }
}

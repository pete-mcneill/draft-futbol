import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/utils_service.dart';
import 'package:draft_futbol/ui/screens/home_page.dart';
import 'package:draft_futbol/ui/screens/on_boarding_screen.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:draft_futbol/utils/utilities.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  void initState() {
    super.initState();
    future = _asyncmethodCall();
  }

  Future<void> _asyncmethodCall() async {
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
      await getLeagueIds();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLeagueIds() async {
    try {
      Map<String, dynamic> _leagueIds = await setLeagueIds();
      ref.read(utilsProvider.notifier).setLeagueIds(_leagueIds);
      ref.read(utilsProvider.notifier).setDefaultActiveLeague();
      Package package;
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        package = offerings.current!.availablePackages[0];
        String price = package.product.priceString;
        ref.read(purchasesProvider.notifier).updateSubscriptionPrice(price);
      }
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      if (purchaserInfo.entitlements.all["noAdverts"]!.isActive) {
        print("User has subscription");
        ref.read(purchasesProvider.notifier).updateNoAdvertsStatus(true);
      } else {
        ref.read(purchasesProvider.notifier).updateNoAdvertsStatus(false);
      }
    } catch (e) {
      print(e);
      print("Failed to get entitlements");
      ref.read(purchasesProvider.notifier).updateNoAdvertsStatus(false);
      ref.read(purchasesProvider.notifier).updateSubscriptionPrice("");
    }
  }

  Widget checkLeagueIdsSet() {
    Utilities utils = ref.read(utilsProvider);
    if (utils.leagueIds!.isEmpty) {
      return const OnBoardingScreen();
    } else {
      return HomePage(leagueType: "h");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode theme;
    bool isLightTheme = ref
        .watch(utilsProvider.select((connection) => connection.isLightTheme!));
    if (isLightTheme) {
      theme = ThemeMode.light;
    } else {
      theme = ThemeMode.dark;
    }
    // config = ref.watch(futureLiveDataProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Light Dark Theme',
      theme: FlexThemeData.light(
        scheme: FlexScheme.outerSpace,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 20,
        appBarOpacity: 0.95,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendOnColors: false,
          bottomNavigationBarElevation: 9.5,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.outerSpace,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.background,
        appBarOpacity: 0.90,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
          bottomNavigationBarElevation: 9.5,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
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
                return checkLeagueIdsSet();
              }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

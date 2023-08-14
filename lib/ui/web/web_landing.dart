import 'package:draft_futbol/ui/web/web_home.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WebLanding extends ConsumerStatefulWidget {
  const WebLanding({Key? key}) : super(key: key);

  @override
  _WebLandingState createState() => _WebLandingState();
}

const int maxFailedLoadAttempts = 3;

class _WebLandingState extends ConsumerState<WebLanding> {
  final idsController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    idsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Draft Futbol',
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

        // theme: widget.themeProvider.themeData(),
        home: Scaffold(
            // appBar: DraftAppBar(
            //   settings: true,
            // ),
            // drawer: const DraftDrawer(),
            body: SafeArea(
          child: Container(
              // margin: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              // alignment: FractionalOffset.center,
              child: Column(
            children: [
              Center(
                  child: Image.asset(
                "assets/images/logo2.png",
                // height: 100,
                // width: 100,
              )),
              const Center(
                  child:
                      Text("Welcome!", style: TextStyle(color: Colors.white))),
              const Text("This is a work in progress, so please be patient!",
                  style: TextStyle(color: Colors.white)),
              const Text("Insert League IDs below",
                  style: TextStyle(color: Colors.white)),
              Center(
                child: SizedBox(
                  width: 500,
                  child: TextField(
                    controller: idsController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'League IDs separated by comma',
                      suffixIcon: IconButton(
                        onPressed: () {
                          var ids = idsController.text;
                          List<String> leagueids = [];
                          if (ids.contains(",")) {
                            List<String> splitIds = ids.split(",");
                            leagueids.addAll(splitIds);
                          } else {
                            leagueids.add(ids);
                          }
                          context.go('/?ids=${leagueids.join(",")}');
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ),
                ),
              ),
              const Text("Not sure of your league ID?",
                  style: TextStyle(color: Colors.white))
            ],
          )),
        )));
  }
}

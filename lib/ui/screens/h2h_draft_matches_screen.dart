import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_screen.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:draft_futbol/ui/widgets/filter_ui.dart';
import 'package:draft_futbol/ui/widgets/h2h_match_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

class H2hDraftMatchesScreen extends ConsumerStatefulWidget {
  const H2hDraftMatchesScreen({Key? key}) : super(key: key);

  @override
  _H2hDraftMatchesScreenState createState() => _H2hDraftMatchesScreenState();
}

class _H2hDraftMatchesScreenState extends ConsumerState<H2hDraftMatchesScreen> {
  Gameweek? gameweek;
  List<Fixture>? fixtures;
  Map<int, DraftTeam>? teams;
  String? viewType;
  String activeLeague = "";
  bool liveBonus = false;
  bool remainingPlayersFilter = false;
  bool iconsSummaryFilter = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ChipOptions> getFilterOptions() {
    List<ChipOptions> options = [
      // if (!gameweek!.gameweekFinished)
      ChipOptions(
          label: "Live Bonus Points",
          selected: liveBonus,
          onSelected: (bool selected) {
            ref.read(utilsProvider.notifier).updateLiveBps(selected);
          }),
      // if (!gameweek!.gameweekFinished)
      //   ChipOptions(
      //       label: "Remaining Players",
      //       selected: remainingPlayersFilter,
      //       onSelected: (bool selected) {
      //         ref
      //             .read(utilsProvider.notifier)
      //             .setRemainingPlayersView(selected);
      //       }),
      // ChipOptions(
      //     label: "Icons Summary",
      //     selected: iconsSummaryFilter,
      //     onSelected: (bool selected) {
      //       ref.read(utilsProvider.notifier).setIconSummaryView(selected);
      //     })
    ];
    return options;
  }

  @override
  Widget build(BuildContext context) {
    remainingPlayersFilter = ref.watch(
        utilsProvider.select((connection) => connection.remainingPlayersView!));
    iconsSummaryFilter = ref.watch(
        utilsProvider.select((connection) => connection.iconSummaryView!));
    liveBonus = ref.watch(utilsProvider).liveBps!;
    activeLeague = ref.watch(
        utilsProvider.select((connection) => connection.activeLeagueId!));
    gameweek = ref.read(gameweekProvider);
    fixtures = ref
        .read(fixturesProvider)
        .fixtures[activeLeague]![gameweek!.currentGameweek];
    teams = ref.watch(draftTeamsProvider).teams![activeLeague];

    return ListView(children: <Widget>[
      if (!ref.watch(purchasesProvider).noAdverts!)
        SizedBox(
          height: 120,
          // color: Colors.deepOrange,
          child: FutureBuilder<Widget>(
            future: getBannerWidget(
                context: context,
                adSize: AdSize.banner,
                noAdverts: ref.watch(purchasesProvider).noAdverts!),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: const CircularProgressIndicator());
              } else {
                return Column(
                  children: [
                    Center(
                        child: ValueListenableBuilder<Box>(
                      valueListenable:
                          Hive.box('adverts').listenable(keys: ['adCounter']),
                      builder: (context, box, _) {
                        int adRefresh = box.get('adCounter');
                        adRefresh = 10 - adRefresh;
                        return Text(
                            "Video Advert will appear in $adRefresh refreshes",
                            style: const TextStyle(fontSize: 12));
                      },
                    )),
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: snapshot.data,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      if (!gameweek!.gameweekFinished)
        FilterH2HMatches(options: getFilterOptions()),
      ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: fixtures!.length,
          itemBuilder: (BuildContext context, int index) {
            Fixture _fixture = fixtures![index];
            DraftTeam homeTeam = teams![_fixture.homeTeamId]!;
            DraftTeam awayTeam = teams![_fixture.awayTeamId]!;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    print("Pitch Change");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Pitch(
                                  homeTeam: homeTeam,
                                  awayTeam: awayTeam,
                                  fixture: _fixture,
                                )));
                  },
                  child: H2hMatchPreview(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            );
          }),
    ]);
  }
}

import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/pitch/pitch_screen.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
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
    activeLeague = ref.watch(
        utilsProvider.select((connection) => connection.activeLeagueId!));
    gameweek = ref.read(gameweekProvider);
    fixtures = ref.read(fixturesProvider).fixtures[activeLeague]![gameweek!.currentGameweek];
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
                return const CircularProgressIndicator();
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

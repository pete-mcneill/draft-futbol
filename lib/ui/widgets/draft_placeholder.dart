import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DraftPlaceholder extends ConsumerWidget {
  var leagueData;

  DraftPlaceholder({Key? key, required this.leagueData}) : super(key: key);

  Widget draftNotComplete(bool noAdverts, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (!ref.watch(purchasesProvider).noAdverts!)
          SizedBox(
            height: 120,
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
        const Center(
          child: AutoSizeText(
            'Season or Draft has not started yet.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ),
        const Center(
          child: AutoSizeText(
            "Teams in league:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: leagueData['league_entries'].length,
          itemBuilder: (context, index) {
            var team = leagueData['league_entries'][index];
            return ListTile(
              title: Center(child: Text(team['entry_name'])),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool noAdverts = ref.watch(purchasesProvider).noAdverts!;
    String leagueStatus = leagueData['league']['draft_status'];
    if (leagueStatus == "pre") {
      return Container(
        child: draftNotComplete(noAdverts, context, ref),
      );
    } else {
      return Container(
        child: draftNotComplete(noAdverts, context, ref),
      );
    }
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/baguley-features/screen/baguley_home.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/adverts/adverts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BaguleyDraftDrawerExtension extends ConsumerWidget {

  BaguleyDraftDrawerExtension({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, dynamic>? leagueIds = ref.read(utilsProvider).leagueIds;
    bool baguleyLeague = false;
    List<String> baguleyIds = ["21114","48"];
    for(var leagueInfo in leagueIds!.entries){
      if(baguleyIds.contains(leagueInfo.key)){
        baguleyLeague = true;
      }
    }
    return Column(children: [
      if(baguleyLeague)
      Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "The Baguley",
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
            ),
          ),
      if(baguleyLeague)
      ListTile(
            title: const Center(
              child: Text('Historic Data'),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => new BaguleyHome()));
            },
          ),
    ]);
}
}

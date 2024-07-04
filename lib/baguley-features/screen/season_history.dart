import 'package:draft_futbol/baguley-features/screen/baguley_historic_fixtures.dart';
import 'package:draft_futbol/baguley-features/screen/baguley_league_standings.dart';
import 'package:flutter/material.dart';

import '../../src/common_widgets/draft_app_bar.dart';
import '../widgets/season_overview.dart';

class SeasonHistoryScreen extends StatefulWidget {
  String seasonId;
  Map<String, dynamic> seasonData;
  SeasonHistoryScreen(
      {Key? key, required this.seasonId, required this.seasonData})
      : super(key: key);

  @override
  State<SeasonHistoryScreen> createState() => _SeasonHistoryScreenState();
}

class _SeasonHistoryScreenState extends State<SeasonHistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraftAppBar(settings: false),
      body: Container(
        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        // decoration: BoxDecoration(
        //   // border: Border.all(color: Colors.blueAccent),
        //   borderRadius: const BorderRadius.all(
        //       Radius.circular(8.0) //                 <--- border radius here
        //       ),
        // ),
        child: Column(children: [
          BaguleySeasonOverview(
              season: widget.seasonData['short_name'],
              champion: widget.seasonData['baguley_winner'],
              chairLeg: widget.seasonData['chair_leg']),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaguleyLeagueStandings(
                                seasonId: widget.seasonId)));
                  },
                  child: Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: makeListTile("Standings", Icons.list),
                    ),
                  )),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BaguleyResults(seasonId: widget.seasonId)));
                  },
                  child: Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: makeListTile("Results", Icons.calendar_today),
                    ),
                  )),
            ],
          ),
          // )
        ]),
      ),
    );
  }

  makeListTile(String title, IconData icon) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(width: 1.0, color: Colors.white24))),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      // subtitle: Row(
      //   children: <Widget>[
      //     Icon(Icons.linear_scale, color: Colors.yellowAccent),
      //     Text(" Intermediate", style: TextStyle(color: Colors.white))
      //   ],
      // ),
      trailing:
          const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
}

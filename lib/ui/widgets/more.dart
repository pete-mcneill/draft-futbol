import 'package:draft_futbol/baguley-features/widgets/draft_drawer.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/draft_fixtures_results.dart';
import 'package:draft_futbol/ui/screens/settings_screen.dart';
import 'package:draft_futbol/ui/screens/squads_screen.dart';
import 'package:draft_futbol/ui/screens/transactions.dart';
import 'package:draft_futbol/ui/widgets/waivers/player_trade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../baguley-features/screen/baguley_home.dart';

class More extends ConsumerStatefulWidget {
  const More({Key? key}) : super(key: key);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? leagueIds = ref.read(utilsProvider).leagueIds;
    bool baguleyLeague = false;
    List<String> baguleyIds = ["145", "687"];
    for (var leagueInfo in leagueIds!.entries) {
      if (baguleyIds.contains(leagueInfo.key)) {
        baguleyLeague = true;
      }
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("Draft League",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SquadsScreen()));
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 10, child: Text("Squads")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DraftFixturesResults()));
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 10, child: Text("Fixtures & Results")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new Transactions()));
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 10, child: Text("Waivers & Free Agents")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new Trade()));
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 10, child: Text("Trades")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          if (baguleyLeague) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text("Baguley",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new BaguleyHome()));
                },
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    margin: const EdgeInsets.all(0),
                    elevation: 4,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(flex: 10, child: Text("Historic Data")),
                          Expanded(
                              flex: 2, child: Icon(CupertinoIcons.arrow_right))
                        ],
                      ),
                    )),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("Issues or Queries",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                      // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                      icon: FaIcon(
                        FontAwesomeIcons.squareGithub,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://github.com/PSJMcNeill/draft-futbol/issues"));
                      }),
                  Text("Github",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
              Column(
                children: [
                  IconButton(
                      // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                      icon: FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      ),
                      onPressed: () async {
                        final Uri params = Uri(
                          scheme: 'mailto',
                          path: 'psjmcneill@gmail.com',
                          query:
                              'subject=Draft Futbol', //add subject and body here
                        );
                        if (await canLaunchUrl(params)) {
                          await launchUrl(params);
                        } else {
                          throw 'Could not launch $params';
                        }
                        // launchUrl(params);
                      }),
                  Text("Email",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

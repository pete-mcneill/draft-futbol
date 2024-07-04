import 'package:draft_futbol/src/features/fixtures_results/presentation/fixtures_results_screen.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/squads/presentation/squads_screen.dart';
import 'package:draft_futbol/src/features/transactions/presentation/transactions_screen.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:draft_futbol/src/features/transactions/presentation/waivers/player_trade.dart';
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Draft League",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const ShoppingCartScreen()));
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
                        Expanded(flex: 10, child: Text("TEst")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SquadsScreen()));
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
          const SizedBox(
            height: 5,
          ),
          SizedBox(
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
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Transactions()));
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
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Trade()));
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
          const SizedBox(
            height: 5,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Issues or Queries",
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
                  const Text("Github",
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
                  const Text("Email",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
          buyaCoffeebutton(context)
        ],
      ),
    );
  }
}
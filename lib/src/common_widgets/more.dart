import 'package:draft_futbol/src/common_widgets/manage_league_dialog.dart';
import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_screen.dart';
import 'package:draft_futbol/src/features/cup/presentation/manage_cup/manage_cup_screen.dart';
import 'package:draft_futbol/src/features/cup/presentation/delete_cup_dialog.dart';
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
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../baguley-features/screen/baguley_home.dart';

class More extends ConsumerStatefulWidget {
  const More({Key? key}) : super(key: key);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  bool deleteCupSelected = false;
  bool editCupSelected = false;

  Future<void> _showDeleteCupDialog(Cup cup) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DeleteCupDialog(cup: cup);
      },
    );
  }

  Future<void> _showManageLeagueDialog(String type) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ManageleagueDialog(
          type: type,
        );
      },
    );
  }

  Widget getCupIcon(Cup cup) {
    if (editCupSelected) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ManageCup(
                        cup: cup,
                      )));
          setState(() {
            editCupSelected = false;
          });
        },
        child: Icon(CupertinoIcons.pencil),
      );
    } else if (deleteCupSelected) {
      return GestureDetector(
        onTap: () {
          _showDeleteCupDialog(cup).then(
            (value) => setState(() {
              deleteCupSelected = false;
            }),
          );
        },
        child: Icon(
          CupertinoIcons.delete,
          color: Colors.red,
        ),
      );
    } else {
      return Icon(CupertinoIcons.arrow_right);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cups = Hive.box('cups').values;

    return SingleChildScrollView(
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
                            flex: 10,
                            child: Text("Waivers, Free Agents & Trades")),
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
          const SizedBox(
            height: 5,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Manage Leagues",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                _showManageLeagueDialog("add").then(
                  (value) => setState(() {}),
                );
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
                        Expanded(flex: 10, child: Text("Add League")),
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
                _showManageLeagueDialog("remove").then(
                  (value) => setState(() {}),
                );
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
                        Expanded(flex: 10, child: Text("Remove League")),
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
            child: Text("Cups",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          for (Cup cup in cups)
            SizedBox(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CupScreen(
                                cup: cup,
                              )));
                },
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    margin: const EdgeInsets.all(0),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(flex: 10, child: Text(cup.name)),
                          Expanded(flex: 2, child: getCupIcon(cup))
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManageCup()));
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
                        Expanded(flex: 10, child: Text("Create a Cup")),
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
                setState(() {
                  editCupSelected = !editCupSelected;
                });
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 10,
                            child: Text(
                                editCupSelected ? "Cancel" : "Edit a Cup")),
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
                setState(() {
                  deleteCupSelected = !deleteCupSelected;
                });
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  margin: const EdgeInsets.all(0),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 10,
                            child: Text(
                                deleteCupSelected ? "Cancel" : "Delete a Cup")),
                        Expanded(
                            flex: 2, child: Icon(CupertinoIcons.arrow_right))
                      ],
                    ),
                  )),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Support",
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

import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/draft_fixtures_results.dart';
import 'package:draft_futbol/ui/screens/settings_screen.dart';
import 'package:draft_futbol/ui/screens/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DraftDrawer extends ConsumerStatefulWidget {
  const DraftDrawer({Key? key}) : super(key: key);

  @override
  _DraftDrawerState createState() => _DraftDrawerState();
}

class _DraftDrawerState extends ConsumerState<DraftDrawer> {
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = ref
        .watch(utilsProvider.select((connection) => connection.isLightTheme!));
    return Drawer(
      child: Column(
        // padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(),
            decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                    image: isLightTheme
                        ? const AssetImage("assets/images/app_logo.png")
                        : const AssetImage("assets/images/app_logo_dark.png"),
                    fit: BoxFit.cover)),
          ),
          // Divider(),
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Draft Leagues",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          ListTile(
            title: const Center(
              child: Text('Fixtures & Results'),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DraftFixturesResults()));
            },
          ),
          ListTile(
            title: const Center(
              child: Text('Transactions'),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Transactions()));
            },
          ),
          // ListTile(
          //   title: const Center(
          //     child: Text('Player Pool'),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => PlayerPoolScreen()));
          //   },
          // ),
          // Divider(),
          // Container(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: Align(
          //     alignment: AlignmentDirectional.centerStart,
          //     child: Text(
          //       "Premier League",
          //       style: Theme.of(context).textTheme.caption,
          //       textAlign: TextAlign.start,
          //     ),
          //   ),
          // ),
          // ListTile(
          //   title: const Center(
          //     child: Text('Fixtures & Results'),
          //   ),
          //   onTap: () {
          //     ref.watch(purchasesProvider.notifier).makePurchases();
          //   },
          // ),
          const Divider(),
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Utilities",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          // if (!ref.watch(purchasesProvider).noAdverts!)
          ListTile(
            title: const Center(
              child: Text('Remove Ads'),
            ),
            onTap: () {
              // ref.watch(purchasesProvider.notifier).makePurchases();
            },
          ),
          ListTile(
            title: const Center(
              child: Text('Settings'),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          const Spacer(),
          const Divider(),
          const Text("Issues or queries:"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              IconButton(
                  // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                  icon: FaIcon(
                    FontAwesomeIcons.envelope,
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                  onPressed: () {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'psjmcneill@gmail.com',
                      query: 'subject=Draft Futbol', //add subject and body here
                    );
                    launchUrl(params);
                  }),
              // IconButton(
              //     // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
              //     icon: FaIcon(
              //       FontAwesomeIcons.twitter,
              //       color: Theme.of(context).primaryColor,
              //       size: 50,
              //     ),
              //     onPressed: () {
              //      launchUrl(Uri.parse("https://github.com/PSJMcNeill/draft-futbol/issues"))
              //     }),
            ],
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

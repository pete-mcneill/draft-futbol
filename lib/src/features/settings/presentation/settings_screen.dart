import 'package:draft_futbol/src/common_widgets/manage_league_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({Key? key}) : super(key: key);
  bool darkTheme = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // bool isLightTheme = ref.watch(utilsProvider).isLightTheme!;
    // Provider.of<UtilsProvider>(context, listen: true).appTheme;

    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Column(
          children: [
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
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return const ManageleagueDialog(
                        type: "add",
                      );
                    },
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
                          Expanded(flex: 10, child: Text("Add Draft League")),
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
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return const ManageleagueDialog(
                        type: "remove",
                      );
                    },
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
                          Expanded(
                              flex: 10, child: Text("Remove Draft League")),
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
              child: Text("Support",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  final Uri params = Uri(
                    scheme: 'mailto',
                    path: 'psjmcneill@gmail.com',
                    query: 'subject=Draft Futbol', //add subject and body here
                  );
                  launchUrl(params);
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
                          Expanded(flex: 10, child: Text("Contact")),
                          Expanded(
                              flex: 2, child: Icon(CupertinoIcons.arrow_right))
                        ],
                      ),
                    )),
              ),
            ),
          ],
        )
        //     SettingsSection(
        //       title: const Text('Purchases'),
        //       tiles: [
        //         SettingsTile.navigation(
        //           leading: const Icon(CupertinoIcons.purchased),
        //           title: const Text('Remove Adverts'),
        //           onPressed: (context) {
        //             ref.watch(purchasesProvider.notifier).makePurchases();
        //           },
        //         ),
        //         SettingsTile.navigation(
        //           leading: const Icon(CupertinoIcons.purchased_circle),
        //           title: const Text('Restore Purchases'),
        //           onPressed: (context) {
        //             ref.watch(purchasesProvider.notifier).restorePurchase();
        //           },
        //         ),
        //       ],
        //     ),
        //     SettingsSection(title: const Text('Contact'), tiles: [
        //       SettingsTile.navigation(
        //         title: const Text('Waivers & Free Agents'),
        //         leading: const Icon(CupertinoIcons.arrow_2_circlepath),
        //         description:
        //             const Text('View Waivers & Free Agents for your leagues'),
        //         onPressed: (context) {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => new Transactions()));
        //         },
        //       ),
        //       SettingsTile.navigation(
        //         title: const Text('Trades'),
        //         leading: const Icon(CupertinoIcons.arrow_right_arrow_left),
        //         description: const Text('TBC'),
        //         onPressed: (context) {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => DraftFixturesResults()));
        //         },
        //       ),
        //     ]),
        //   ],
        // ),
        );
  }
}

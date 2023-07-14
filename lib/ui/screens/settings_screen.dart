import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/transactions.dart';
import 'package:draft_futbol/ui/widgets/manage_league_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'draft_fixtures_results.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({Key? key}) : super(key: key);
  bool darkTheme = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String price = ref.watch(utilsProvider).subscriptionPrice!;
    bool isLightTheme = ref.watch(utilsProvider).isLightTheme!;
    // Provider.of<UtilsProvider>(context, listen: true).appTheme;
    if (isLightTheme) {
      darkTheme = false;
    } else {
      darkTheme = true;
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text("Manage Leagues",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Container(
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
            SizedBox(
              height: 5,
            ),
            Container(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text("Support",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  ref.watch(purchasesProvider.notifier).makePurchases();
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
                          Expanded(flex: 10, child: Text("Remove Adverts")),
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
                  ref.watch(purchasesProvider.notifier).restorePurchase();
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
                          Expanded(flex: 10, child: Text("Restore Purchases")),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text("App Information",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return Dialog(
                          // backgroundColor: colorScheme.background,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0.0,
                          // backgroundColor: Colors.transparent,
                          child: Column(children: [
                            Center(
                                child: Text(
                              "Information",
                              // style: textTheme.headline4!
                              //     .apply(color: colorScheme.primary)
                            )),
                            Center(
                                child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    // style: bodyTextStyle.copyWith(
                                    //   color: colorScheme.primary,
                                    // ),
                                    text: "A " +
                                        price +
                                        " for 12 months purchase will be applied to your account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription. For more information, see our",
                                  ),
                                  TextSpan(
                                    // style: bodyTextStyle.copyWith(
                                    //   color: colorScheme.tertiary,
                                    // ),
                                    text: " Terms of Use",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const url =
                                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
                                        if (await canLaunch(url)) {
                                          await launch(
                                            url,
                                            forceSafariVC: false,
                                          );
                                        }
                                      },
                                  ),
                                  TextSpan(
                                      // style: bodyTextStyle.copyWith(
                                      //   color: colorScheme.primary,
                                      // ),
                                      text: " and "),
                                  TextSpan(
                                    // style: bodyTextStyle.copyWith(
                                    //   color: colorScheme.tertiary,
                                    // ),
                                    text: "Privacy Policy",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const url =
                                            'https://sites.google.com/view/draftfutbol/home';
                                        if (await canLaunch(url)) {
                                          await launch(
                                            url,
                                            forceSafariVC: false,
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ))
                          ]));
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
                              flex: 10,
                              child: Text("Subscription Terms of Use")),
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

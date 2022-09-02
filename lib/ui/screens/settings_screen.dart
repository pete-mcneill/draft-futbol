import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/manage_league_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: SettingsList(
        sections: [
          SettingsSection(title: const Text('General'), tiles: [
            SettingsTile.switchTile(
              onToggle: (_) {
                if (isLightTheme) {
                  ref.watch(utilsProvider.notifier).updateIsLightTheme(false);
                  Hive.box('settings').put("isLightTheme", false);
                } else {
                  ref.watch(utilsProvider.notifier).updateIsLightTheme(true);
                  Hive.box('settings').put("isLightTheme", true);
                }
              },
              initialValue: darkTheme,
              leading: const Icon(Icons.notifications_active),
              title: const Text('Toggle Dark Theme'),
            ),
          ]),
          SettingsSection(
            title: const Text('Manage Leagues'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Add Draft League'),
                leading: const Icon(CupertinoIcons.plus),
                description: const Text('Add addtional Draft Leagues'),
                onPressed: (context) {
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
              ),
              SettingsTile.navigation(
                title: const Text('Remove Draft League'),
                leading: const Icon(CupertinoIcons.minus),
                description: const Text('Remove leagues from the app'),
                onPressed: (context) {
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
              )
            ],
          ),
          SettingsSection(
            title: const Text('Purchases'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Subscription Information'),
                leading: const Icon(CupertinoIcons.minus),
                description: const Text(
                    'Price, Terms of Use and Privacy Policy Information'),
                onPressed: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final textTheme = Theme.of(context).textTheme;
                  final bodyTextStyle =
                      textTheme.bodyText1!.apply(color: colorScheme.onPrimary);
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return Dialog(
                          backgroundColor: colorScheme.background,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0.0,
                          // backgroundColor: Colors.transparent,
                          child: Column(children: [
                            Center(
                                child: Text("Information",
                                    style: textTheme.headline4!
                                        .apply(color: colorScheme.primary))),
                            Center(
                                child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: bodyTextStyle.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                    text: "A " +
                                        price +
                                        " for 12 months purchase will be applied to your account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription. For more information, see our",
                                  ),
                                  TextSpan(
                                    style: bodyTextStyle.copyWith(
                                      color: colorScheme.tertiary,
                                    ),
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
                                      style: bodyTextStyle.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                      text: " and "),
                                  TextSpan(
                                    style: bodyTextStyle.copyWith(
                                      color: colorScheme.tertiary,
                                    ),
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
              ),
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.purchased),
                title: const Text('Remove Adverts'),
                onPressed: (context) {
                  ref.watch(purchasesProvider.notifier).makePurchases();
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.purchased_circle),
                title: const Text('Restore Purchases'),
                onPressed: (context) {
                  ref.watch(purchasesProvider.notifier).restorePurchase();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      child: ListView(
        padding: EdgeInsets.zero,
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
          if (!ref.watch(purchasesProvider).noAdverts!)
            ListTile(
              title: const Center(
                child: Text('Remove Ads'),
              ),
              onTap: () {
                ref.watch(purchasesProvider.notifier).makePurchases();
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
        ],
      ),
    );
  }
}

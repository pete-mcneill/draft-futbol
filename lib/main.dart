import 'dart:io';

import 'package:draft_futbol/ui/screens/initialise_home_screen.dart';
import 'package:draft_futbol/ui/web/web_home.dart';
import 'package:draft_futbol/ui/web/web_landing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'models/sub.dart';

void main() async {
  print("main");
  List<String> webLeagueIds = [];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
  } else {
    Directory? appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(SubAdapter());
    await Hive.openBox('gwSubs');
    await Hive.openBox('league');
    await Hive.openBox('discovery');
    if (Hive.box('discovery').get('subDiscoveryInfo') == null) {
      Hive.box('discovery').put("subDiscoveryInfo", false);
    }
    await Hive.openBox('settings');
  }

  if (kIsWeb) {
    final GoRouter webRouter = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) {
            Map<String, String> queryParams = state.queryParameters;
            List<int> ids = [];
            queryParams.forEach((key, value) {
              if (key == "ids") {
                try {
                  List _ids = value.split(",");
                  _ids.forEach((element) {
                    ids.add(int.parse(element));
                  });
                } catch (error) {
                  print(error);
                  ids.add(int.parse(value));
                }
              }
            });
            if (ids.isEmpty) {
              return const WebLanding();
            } else {
              // container.read(utilsProvider.notifier).setLeagueIdsV2(ids);
              return WebHome(
                leagueIds: ids,
              );
            }
          },
        )
      ],
    );
    runApp(ProviderScope(
        child: MaterialApp.router(
            routerConfig: webRouter,
            debugShowCheckedModeBanner: false,
            title: "Draft Futbol"
            // ProviderTest(),
            )));
  } else {
    runApp(const ProviderScope(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Loading(),
      home: InitialiseHomeScreen(),
      // ProviderTest(),
    )));
  }
}

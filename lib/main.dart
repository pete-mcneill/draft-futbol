import 'dart:io';

import 'package:draft_futbol/models/draft_subs.dart';
import 'package:draft_futbol/ui/screens/initialise_home_screen.dart';
import 'package:draft_futbol/ui/web/web_landing.dart';
import 'package:draft_futbol/ui/widgets/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';

void main() async {
  print("main");
  List<String> webLeagueIds = [];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    try {
      String myurl = Uri.base.toString();
      String para1 = Uri.base.queryParameters["ids"]!;
      webLeagueIds = para1.split(",");
    } catch (e) {
      print("Failed to parse web params");
    }
  } else {
    await Purchases.setDebugLogsEnabled(false);
    if (Platform.isAndroid) {
      await Purchases.setup("goog_shJDmehLCfIXQMrhWFmezYoljfM");
    } else if (Platform.isIOS) {
      await Purchases.setup("appl_eFIkCUrKISrIBtCsJjYOgIOfElW");
    }
    Directory? appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    MobileAds.instance.initialize();
    Hive.registerAdapter(DraftSubAdapter());
    Box advertBox = await Hive.openBox('adverts');
    Box subsBox = await Hive.openBox('subs');
    await Hive.openBox('discovery');
    if (Hive.box('discovery').get('subDiscoveryInfo') == null) {
      Hive.box('discovery').put("subDiscoveryInfo", false);
    }
    try {
      var test = Hive.box('discovery').get('subDiscoveryInfo');
      int advertRefresh = advertBox.get("adCounter");
      if (advertRefresh == null) {
        advertBox.put("adCounter", 0);
      }
    } catch (e) {
      advertBox.put("adCounter", 0);
    }
    final settings = await Hive.openBox('settings');
    bool isLightTheme = settings.get('isLightTheme') ?? false;
  }

  if (kIsWeb) {
    runApp(ProviderScope(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebHome(),
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

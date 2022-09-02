import 'dart:io';

import 'package:draft_futbol/ui/screens/initialise_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Purchases.setDebugLogsEnabled(false);
  if (Platform.isAndroid) {
    await Purchases.setup("goog_shJDmehLCfIXQMrhWFmezYoljfM");
  } else if (Platform.isIOS) {
    await Purchases.setup("appl_eFIkCUrKISrIBtCsJjYOgIOfElW");
  }
  Directory? appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  MobileAds.instance.initialize();
  Box advertBox = await Hive.openBox('adverts');
  try {
    int advertRefresh = advertBox.get("adCounter");
    if (advertRefresh == null) {
      advertBox.put("adCounter", 0);
    }
  } catch (e) {
    advertBox.put("adCounter", 0);
  }

  final settings = await Hive.openBox('settings');
  bool isLightTheme = settings.get('isLightTheme') ?? false;

  runApp(const ProviderScope(
      child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InitialiseHomeScreen(),
    // ProviderTest(),
  )));
}

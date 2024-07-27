import 'dart:io';

import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/initialise_home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'src/features/substitutes/domain/sub.dart';

void main() async {
  // List<String> webLeagueIds = [];
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final dataStore = HiveDataStore();
  await dataStore.init();

  if (kIsWeb) {
  } else {
    Directory? appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(SubAdapter());
    await Hive.openBox('subs');
    await Hive.openBox('league');
  }
    runApp(ProviderScope(
      overrides: [
        dataStoreProvider.overrideWithValue(dataStore),
      ],
        child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Loading(),
      home: InitialiseHomeScreen(),
      // ProviderTest(),
    )));
}

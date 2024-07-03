import 'dart:io';

import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveDataStore {
  static const allLeaguesMetadataBox = 'leagueMetadata';
  static const backTasksBoxName = 'backTasks';
  static const tasksStateBoxName = 'tasksState';
  static const flagsBoxName = 'flags';
  static String taskStateKey(String key) => 'tasksState/$key';
  static const frontAppThemeBoxName = 'frontAppTheme';
  static const backAppThemeBoxName = 'backAppTheme';

  static const alwaysShowAddTaskKey = 'alwaysShowAddTask';
  static const didAddFirstTaskKey = 'didAddFirstTask';

  Future<void> init() async {
    Directory? appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    // register adapters
    Hive.registerAdapter<LocalLeagueMetadata>(LocalLeagueMetadataAdapter());
    // open boxes
    // Local League Information
    await Hive.openBox<LocalLeagueMetadata>(allLeaguesMetadataBox);
    // task states
    // await Hive.openBox<TaskState>(tasksStateBoxName);
    // // theming
    // await Hive.openBox<AppThemeSettings>(frontAppThemeBoxName);
    // await Hive.openBox<AppThemeSettings>(backAppThemeBoxName);
    // // flags
    // await Hive.openBox<bool>(flagsBoxName);
  }

  // // App Theme Settings
  // Future<void> setAppThemeSettings(
  //     {required AppThemeSettings settings,
  //     required FrontOrBackSide side}) async {
  //   final themeKey = side == FrontOrBackSide.front
  //       ? frontAppThemeBoxName
  //       : backAppThemeBoxName;
  //   final box = Hive.box<AppThemeSettings>(themeKey);
  //   await box.put(themeKey, settings);
  // }

  // Future<AppThemeSettings> appThemeSettings(
  //     {required FrontOrBackSide side}) async {
  //   final themeKey = side == FrontOrBackSide.front
  //       ? frontAppThemeBoxName
  //       : backAppThemeBoxName;
  //   final box = Hive.box<AppThemeSettings>(themeKey);
  //   final settings = box.get(themeKey);
  //   return settings ?? AppThemeSettings.defaults(side);
  // }

  List<LocalLeagueMetadata> getLeagues() {
    final box = Hive.box<LocalLeagueMetadata>(allLeaguesMetadataBox);
    return box.values.toList();
  }

  // Save and delete leagues
  Future<void> saveLeague(LocalLeagueMetadata league) async {
    final box = Hive.box<LocalLeagueMetadata>(allLeaguesMetadataBox);
    await box.add(league);
  }

  Future<void> deleteLeague(LocalLeagueMetadata league) async {
    final box = Hive.box<LocalLeagueMetadata>(allLeaguesMetadataBox);
    if (box.isNotEmpty) {
      final index = box.values
          .toList()
          .indexWhere((leagueAtIndex) => leagueAtIndex.id == league.id);
      if (index >= 0) {
        await box.deleteAt(index);
      }
    }
  }
}

final dataStoreProvider = Provider<HiveDataStore>((ref) {
  throw UnimplementedError();
});
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<int, dynamic>> setLeagueIds() async {
  Map<String, dynamic> _leagueIds = {};
  Map<int, dynamic> convertedIds = {};
  try {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    // _prefs.clear();
    String? sharedPrefIds = _prefs.getString('league_ids');
    _leagueIds = json.decode(sharedPrefIds!);
    convertedIds = _leagueIds.map<int, dynamic>(
      (k, v) => MapEntry(int.parse(k), v), // parse String back to int
    );
  } catch (e) {
    print("No League ids: ${e}");
  }
  return convertedIds;
}

void clearLeagueIds() async {
  try {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.clear();
  } catch (e) {
    print(e);
  }
}

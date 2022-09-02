import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> setLeagueIds() async {
  Map<String, dynamic> leagueIds = {};
  try {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    // _prefs.clear();
    String? sharedPrefIds = _prefs.getString('league_ids');
    leagueIds = json.decode(sharedPrefIds!);
  } catch (e) {
    print(e);
  }
  return leagueIds;
}

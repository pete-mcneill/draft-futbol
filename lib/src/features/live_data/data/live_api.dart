import 'package:cloud_functions/cloud_functions.dart';
import 'package:draft_futbol/src/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class Api {
  String baseUrl = '';

  Api() {
    // baseUrl = 'https://draft.premierleague.com';
  }

  Future<Map<String, dynamic>> checkLeagueExists(String leagueId) async {
    final response = await http.get(Uri.parse(
        Commons.baseUrl + '/api/league/${leagueId.toString()}/details'));

    if (response.statusCode == 200) {
      var _resp = Commons.returnResponse(response);
      String LeagueName = _resp['league']['name'];
      if (_resp['league']['draft_status'] == 'post') {
        final league = {
          "valid": true,
          "name": LeagueName,
          "type": _resp['league']['scoring']
        };
        return league;
      } else if (_resp['league']['draft_status'] == 'pre') {
        print("Draft not complete");
        return {
          "valid": true,
          "name": LeagueName,
          "type": _resp['league']['scoring'],
          "reason":
              "Draft not complete, come back when you've drafted your teams"
        };
      } else {
        print("Invalid League Type");
        return {
          "valid": false,
          "reason":
              "Sorry, currently only H2H leagues are supported. Update coming soon!"
        };
      }
    } else {
      print("Non 200 repsonse");
      return {"valid": false, "reason": "League not found"};
    }
  }

  Future<Map> get_gw_squad(teamId, gameweek) async {
    if (kIsWeb) {
      return await proxyViaFirebase("/api/entry/$teamId/event/$gameweek");
    } else {
      final response = await http
          .get(Uri.parse('$baseUrl/api/entry/$teamId/event/$gameweek'));
      if (response.statusCode == 200) {
        return Commons.returnResponse(response);
      } else {
        print(response.statusCode);
        print("failed to get response");
        throw Exception('Failed to get response from FPL');
      }
    }
  }

  Future<List<dynamic>> get_live_squads(leagueId, gameweek) async {
    final leagueDetails = await getLeagueDetails(leagueId);
    List draftSquads = [];
    for (var team in leagueDetails['league_entries']) {
      int teamId = team['entry_id'];
      var squad = get_gw_squad(teamId, gameweek);
      var squadDetails = {"id": teamId, "squad": squad};
      draftSquads.add(squadDetails);
    }
    return draftSquads;
  }

  Future<dynamic> getCurrentGameweek() async {
    if (kIsWeb) {
      return await proxyViaFirebase("/api/game");
    } else {
      try {
        final response =
            await http.get((Uri.parse(Commons.baseUrl + "/api/game")));
        if (response.statusCode == 200) {
          return Commons.returnResponse(response);
        } else {
          return null;
        }
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  Future<Map> getLeagueDetails(leagueId) async {
    if (kIsWeb) {
      return await proxyViaFirebase('/api/league/$leagueId/details');
    } else {
      final response =
          await http.get(Uri.parse('$baseUrl/api/league/$leagueId/details'));
      if (response.statusCode == 200) {
        return Commons.returnResponse(response);
      } else {
        print(response.statusCode);
        print("failed to get response");
        throw Exception('Failed to get response from FPL');
      }
    }
  }

  Future<Map?> getLeagueTrades(leagueId) async {
    try {
      if (kIsWeb) {
        return await proxyViaFirebase("/api/draft/league/$leagueId/trades");
      } else {
        final response = await http.get((Uri.parse(
            Commons.baseUrl + "/api/draft/league/$leagueId/trades")));
        if (response.statusCode == 200) {
          return Commons.returnResponse(response);
        } else {
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> getLiveData(int gameweek) async {
    if (kIsWeb) {
      return await proxyViaFirebase(
          "/api/event/" + gameweek.toString() + "/live");
    } else {
      try {
        final liveDetailsResponse = await http.get((Uri.parse(
            Commons.baseUrl + "/api/event/" + gameweek.toString() + "/live")));
        if (liveDetailsResponse.statusCode == 200) {
          var response = Commons.returnResponse(liveDetailsResponse);
          return response;
        }
      } on Exception {
        return null;
      }
    }
  }

  Future<Map?> getPlayerStatus(leagueId) async {
    try {
      if (kIsWeb) {
        return await proxyViaFirebase("/api/league/$leagueId/element-status");
      } else {
        final response = await http.get((Uri.parse(
            Commons.baseUrl + "/api/league/$leagueId/element-status")));
        if (response.statusCode == 200) {
          return Commons.returnResponse(response);
        } else {
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> getSquad(int teamId, int gameweek) async {
    if (kIsWeb) {
      return await proxyViaFirebase(
          "/api/entry/" + teamId.toString() + "/event/" + gameweek.toString());
    } else {
      final response = await http.get((Uri.parse(Commons.baseUrl +
          "/api/entry/" +
          teamId.toString() +
          "/event/" +
          gameweek.toString())));
      if (response.statusCode == 200) {
        return Commons.returnResponse(response);
      } else {
        print(response.statusCode);
        print("failed to get response");
        throw Exception('Failed to get response from FPL');
      }
    }
  }

  Future<dynamic> getStaticData() async {
    if (kIsWeb) {
      return await proxyViaFirebase("/api/bootstrap-static");
    } else {
      try {
        final staticDetailsResponse = await http
            .get((Uri.parse(Commons.baseUrl + "/api/bootstrap-static")));
        if (staticDetailsResponse.statusCode == 200) {
          var response = Commons.returnResponse(staticDetailsResponse);
          return response;
        }
      } on Exception {
        return null;
      }
    }
  }

  Future<Map?> getTransactions(leagueId) async {
    try {
      if (kIsWeb) {
        return await proxyViaFirebase(
            "/api/draft/league/$leagueId/transactions");
      } else {
        final response = await http.get((Uri.parse(
            Commons.baseUrl + "/api/draft/league/$leagueId/transactions")));
        if (response.statusCode == 200) {
          return Commons.returnResponse(response);
        } else {
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List?> getPremierLeagueFixtures(gameweek) async {
    try {
      if (kIsWeb) {
        return await proxyViaFirebase(
            "/api/event/$gameweek/fixtures");
      } else {
        final response = await http.get((Uri.parse(
            Commons.baseUrl + "/api/event/$gameweek/fixtures")));
        if (response.statusCode == 200) {
          return Commons.returnResponse(response);
        } else {
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> proxyViaFirebase(path) async {
    try {
      final result =
          await FirebaseFunctions.instance.httpsCallable('fplProxyv2').call(
        {
          "path": path,
        },
      );
      return result.data;
    } catch (e) {
      print(e);
    }
  }
}

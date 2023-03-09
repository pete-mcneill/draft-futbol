
import 'package:http/http.dart' as http;

import '../models/Gameweek.dart';
import '../utils/commons.dart';

class Api {
  String baseUrl = '';

  Api() {
    baseUrl = 'https://draft.premierleague.com';
  }

Future<Map?> getLeagueTrades(leagueId) async {
    try {
      final response =
          await http.get((Uri.parse(Commons.baseUrl + "/api/draft/league/$leagueId/trades")));
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

Future<Map?> getPlayerStatus(leagueId) async {
    try {
      final response =
          await http.get((Uri.parse(Commons.baseUrl + "/api/league/$leagueId/element-status")));
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

 Future<Map?> getTransactions(leagueId) async {
    try {
      final response =
          await http.get((Uri.parse(Commons.baseUrl + "/api/draft/league/$leagueId/transactions")));
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


  Future<Gameweek?> getCurrentGameweek() async {
    try {
      final response =
          await http.get((Uri.parse(Commons.baseUrl + "/api/game")));
      if (response.statusCode == 200) {
        var gwResponse = Commons.returnResponse(response);
        // Gameweek _gameweek =
        //     Gameweek(gwResponse['current_event'].toString(), false);
        Gameweek _gameweek = Gameweek(gwResponse['current_event'].toString(),
            gwResponse['current_event_finished'], gwResponse['waivers_processed']);
        return _gameweek;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> getLeagueDetails(leagueId) async {
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

  Future<dynamic> getLiveData(String gameweek) async {
    try {
      final liveDetailsResponse = await http.get(
          (Uri.parse(Commons.baseUrl + "/api/event/" + gameweek + "/live")));
      if (liveDetailsResponse.statusCode == 200) {
        var response = Commons.returnResponse(liveDetailsResponse);
        return response;
      }
    } on Exception {
      return null;
    }
  }

  Future<dynamic> getStaticData() async {
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

  Future<Map> get_gw_squad(teamId, gameweek) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/entry/$teamId/event/$gameweek'));
    if (response.statusCode == 200) {
      return Commons.returnResponse(response);
    } else {
      print(response.statusCode);
      print("failed to get response");
      throw Exception('Failed to get response from FPL');
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

  Future<Map<String, dynamic>> checkLeagueExists(String leagueId) async {
    if (leagueId != 'exampleLeague') {
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
    } else {
      return {"valid": true, "name": "Example League"};
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftLeaguesNotifier extends StateNotifier<DraftLeagues> {
  DraftLeaguesNotifier() : super(DraftLeagues());
  void addLeague(DraftLeague league) {
    state = state..leagues.addAll({league.leagueId: league});
  }
}

class DraftLeagues {
  DraftLeagues() : super();

  Map<String, DraftLeague> leagues = {};

  void addLeague(DraftLeague league) {
    leagues[league.leagueId] = league;
  }

  void removeLeague(DraftLeague league) {
    leagues.remove(league.leagueId);
  }
}

class DraftLeague {
  const DraftLeague(
      {required this.leagueId,
      required this.scoring,
      required this.leagueName,
      required this.draftStatus,
      required this.teams});

  final String leagueId;
  final String scoring;
  final String leagueName;
  final String draftStatus;
  final List<dynamic> teams;

  factory DraftLeague.fromJson(var leagueData) {
    List<dynamic> teams = [];
    for (var team in leagueData['league_entries']) {
      teams.add({
        "name": team['entry_name'],
        "manager": "${team['player_first_name']} ${team['player_last_name']}",
        "id": team['entry_id']
      });
    }
    return DraftLeague(
        leagueId: leagueData['league']['id'].toString(),
        scoring: leagueData['league']['scoring'],
        leagueName: leagueData['league']['name'],
        draftStatus: leagueData['league']['draft_status'],
        teams: teams);
  }
}

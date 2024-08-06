class DraftLeague {
  DraftLeague(
      {required this.leagueId,
      required this.scoring,
      required this.leagueName,
      required this.draftStatus,
      required this.teams,
      required this.allH2hFixtures,
      required this.rawStandings,
      this.averageLeague = false});

  final int leagueId;
  final String scoring;
  final String leagueName;
  final String draftStatus;
  final List<dynamic> teams;
  final List<dynamic> allH2hFixtures;
  final dynamic rawStandings;
  bool averageLeague = false;

  factory DraftLeague.fromJson(var leagueData) {
    List<dynamic> teams = [];
    List<dynamic> h2hFixtures = [];
    bool averageLeague = false;
    for (var team in leagueData['league_entries']) {
      if (team['short_name'] == 'AV') {
        averageLeague = true;
      }
      teams.add({
        "name": team['entry_name'] ??= "Average",
        "manager":
            "${team['player_first_name'] ??= ""} ${team['player_last_name'] ??= "Average"}",
        "entry_id": team['entry_id'] ??= 0,
        "id": team["id"] ??= 0
      });
    }
    if (leagueData['league']['scoring'] == 'h') {
      h2hFixtures = leagueData['matches'];
    }
    return DraftLeague(
        leagueId: leagueData['league']['id'],
        scoring: leagueData['league']['scoring'],
        leagueName: leagueData['league']['name'],
        draftStatus: leagueData['league']['draft_status'],
        allH2hFixtures: h2hFixtures,
        teams: teams,
        rawStandings: leagueData['standings'],
        averageLeague: averageLeague);
  }
}

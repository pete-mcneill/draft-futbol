import '../../live_data/domain/draft_domains/draft_team.dart';

class LeagueStanding {
  int? teamId;
  String? teamName;
  int? matchesWon;
  int? matchesDrawn;
  int? matchesLost;
  int? pointsFor;
  int? pointsAgainst;
  int? leaguePoints;
  int? rank;
  int? gwScore;
  int? bpsScore;
  int? lastRank;

  LeagueStanding(
      {this.teamId,
      this.teamName,
      this.matchesWon,
      this.matchesDrawn,
      this.matchesLost,
      this.pointsFor,
      this.pointsAgainst,
      this.leaguePoints,
      this.rank,
      this.gwScore,
      this.bpsScore,
      this.lastRank});

  factory LeagueStanding.fromFirestoreJson(
      var json, Map<String, dynamic>? team) {
    return LeagueStanding(
        teamId: int.parse(json['team_id']),
        teamName: team!['alias'],
        matchesWon: json['wins'] ?? 0,
        matchesDrawn: json['draws'] ?? 0,
        matchesLost: json['losses'] ?? 0,
        pointsFor: json['fpl_points'] ?? 0,
        pointsAgainst: 0,
        leaguePoints: json['points'] ?? 0,
        rank: json['rank'],
        gwScore: json['fpl_points'],
        bpsScore: 0);
  }

  factory LeagueStanding.fromJson(var json, DraftTeam team) {
    return LeagueStanding(
        teamId: json['league_entry'],
        teamName: team.teamName,
        matchesWon: json['matches_won'] ?? 0,
        matchesDrawn: json['matches_drawn'] ?? 0,
        matchesLost: json['matches_lost'] ?? 0,
        pointsFor: json['points_for'] ?? 0,
        pointsAgainst: json['points_against'] ?? 0,
        leaguePoints: json['total'] ?? 0,
        rank: json['rank'] ?? 0,
        gwScore: team.points ?? 0,
        bpsScore: team.bonusPoints ?? 0,
        lastRank: json['last_rank'] ?? 0);
  }
}

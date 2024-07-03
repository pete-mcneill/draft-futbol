class DraftTeam {
  final int leagueId;
  final int? entryId;
  final int? id;
  final String? teamName;
  final String? managerName;
  int? points;
  int? bonusPoints;
  Map<int, int>? squad = {};
  int remainingPlayersMatches;
  int completedPlayersMatches;
  int remainingSubsMatches;
  int completedSubsMatches;
  int livePlayers;
  bool? userSubsActive;

  DraftTeam(
      {required this.leagueId,
      this.entryId,
      this.id,
      this.teamName,
      this.managerName,
      this.points,
      this.bonusPoints,
      required this.remainingPlayersMatches,
      required this.completedPlayersMatches,
      required this.remainingSubsMatches,
      required this.completedSubsMatches,
      required this.livePlayers,
      this.userSubsActive = false});

  factory DraftTeam.fromJson(Map<String, dynamic> json, int leagueId) {
    return DraftTeam(
        leagueId: leagueId,
        entryId: json["entry_id"] ?? 0,
        id: json["id"],
        teamName: json["name"] ?? "Average",
        managerName: json["manager"] ?? "",
        points: 0,
        bonusPoints: 0,
        remainingPlayersMatches: 0,
        completedPlayersMatches: 0,
        remainingSubsMatches: 0,
        completedSubsMatches: 0,
        livePlayers: 0);
  }
}

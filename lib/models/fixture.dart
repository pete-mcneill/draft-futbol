
class Fixture {
  int? homeTeamId;
  int? awayTeamId;
  int? homeStaticPoints;
  int? awayStaticPoints;

  Fixture(
      {this.homeTeamId,
      this.awayTeamId,
      this.homeStaticPoints,
      this.awayStaticPoints});

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
        homeTeamId: json['league_entry_1'],
        awayTeamId: json['league_entry_2'],
        homeStaticPoints: json['league_entry_1_points'],
        awayStaticPoints: json['league_entry_2_points']);
  }
}

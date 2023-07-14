import 'package:flutter_riverpod/flutter_riverpod.dart';

class FixturesNotifier extends StateNotifier<Fixtures> {
  FixturesNotifier() : super(Fixtures());

  void getAllFixtures(List<dynamic> league_fixtures, String leagueId) async {
    try {
      state.fixtures[leagueId] = {};
      for (var match in league_fixtures) {
        Fixture _fixture = Fixture.fromJson(match);
        if (state.fixtures[leagueId]![match['event'].toString()] != null) {
          state.fixtures[leagueId]![match['event'].toString()]!.add(_fixture);
        } else {
          state.fixtures[leagueId]![match['event'].toString()] = [_fixture];
        }
      }
    } catch (error) {
      print(error);
    }
  }
}

class Fixtures {
  Map<String, Map<String, List<Fixture>>> fixtures = {};

  Fixtures() : super();
}

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

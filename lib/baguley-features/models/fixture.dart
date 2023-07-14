import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FixturesNotifier extends StateNotifier<Fixtures> {
//   FixturesNotifier() : super(Fixtures());

//   void getAllFixtures(
//   List<dynamic> league_fixtures, String leagueId
// ) async {
//     try {
//       state.fixtures[leagueId] = {};
//       for (var match in league_fixtures) {
//           Fixture _fixture = Fixture.fromJson(match);
//           if(state.fixtures[leagueId]![match['event'].toString()] != null){
//             state.fixtures[leagueId]![match['event'].toString()]!.add(_fixture);
//           } else {
//             state.fixtures[leagueId]![match['event'].toString()] = [_fixture];
//           }
//       }
//     } catch (error) {
//       print(error);
//     }
// }
// }



// class Fixtures {
//   Map<String, Map<String, List<Fixture>>> fixtures = {};

//   Fixtures() : super();
// }

class BaguleyFixture {
  String? gameweek;
  String? homeTeam;
  String? awayTeam;
  int? homePoints;
  int? awayPoints;
  String? homeFplId;
  String? awayFplId;

  BaguleyFixture(
      {
      this.gameweek,
      this.homeTeam,
      this.awayTeam,
      this.homePoints,
      this.awayPoints,
      this.homeFplId,
      this.awayFplId});

  factory BaguleyFixture.fromJson(Map<String, dynamic> json) {
    try{
          return BaguleyFixture(
        gameweek: json['gameweek'].toString(),
        homeTeam: json['home_team'],
        awayTeam: json['away_team'],
        homePoints: json['home_points'],
        awayPoints: json['away_points'],
        homeFplId: json['home_fpl_id'].toString(),
        awayFplId: json['away_fpl_id'].toString());
    } catch(error){
      print(error);
      return BaguleyFixture(
        homeTeam: json['home_team'],
        awayTeam: json['away_team'],
        homePoints: json['home_points'],
        awayPoints: json['away_points']);
    }

  }
}

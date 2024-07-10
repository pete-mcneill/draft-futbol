// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../src/features/league_standings/domain/league_standing.dart';

// Future<List<LeagueStanding>> getStandings(
//     int? gameweek, String seasonId) async {
//   final _collectionRef = await FirebaseFirestore.instance
//       .collection('standings')
//       .doc("seasons")
//       .collection(seasonId)
//       .doc('gw$gameweek')
//       .get();

//   return await orchestrateStandings(_collectionRef.data()!['standings']);
// }

// Future<List<LeagueStanding>> orchestrateStandings(var standings) async {
//   List<LeagueStanding> _standings = [];
//   for (var i = 0; i < standings.length; i++) {
//     var standing = standings[i];
//     standing['rank'] = i + 1;
//     Map<String, dynamic>? teamUuid = await getTeamUuid(standing['team_id']);
//     LeagueStanding _standing =
//         LeagueStanding.fromFirestoreJson(standing, teamUuid);
//     _standings.add(_standing);
//   }
//   return _standings;
// }

// Future<Map<String, dynamic>?> getTeamUuid(String id) async {
//   final teamIds = await FirebaseFirestore.instance
//       .collection("draft_teams")
//       .where("uuid", isEqualTo: id)
//       .get();
//   var uuidData = teamIds.docs[0].data();
//   return uuidData;
// }

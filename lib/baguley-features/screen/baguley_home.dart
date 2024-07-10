// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:draft_futbol/baguley-features/screen/season_history.dart';
// import 'package:draft_futbol/baguley-features/widgets/season_overview.dart';
// import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
// import 'package:flutter/material.dart';

// class BaguleyHome extends StatefulWidget {
//   const BaguleyHome({Key? key}) : super(key: key);

//   @override
//   State<BaguleyHome> createState() => _BaguleyHomeState();
// }

// class _BaguleyHomeState extends State<BaguleyHome> {
//   final CollectionReference _collectionRef =
//       FirebaseFirestore.instance.collection('seasons');
//   @override
//   void initState() {
//     // TODO: implement initState
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     super.initState();
//   }

//   Future<List<Object?>> setSeasonsData() async {
//     // Get docs from collection reference
//     QuerySnapshot querySnapshot = await _collectionRef.get();

//     // Get data from docs and convert map to List
//     final allData = querySnapshot.docs
//         .map((doc) => doc.data() as Map<String, dynamic>)
//         .toList();
//     allData.sort((a, b) => a['uuid'].compareTo(b['uuid']));
//     // allData.sort((a, b) => a!['uuid'].compareTo(b!['uuid']));
//     return allData;
//   }

//   List<Widget> getSeasonOverviews(var seasonOverviewData) {
//     List<Widget> seasonWidgets = [];
//     for (var season in seasonOverviewData) {
//       seasonWidgets.add(
//         GestureDetector(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => SeasonHistoryScreen(
//                             seasonId: season['uuid'],
//                             seasonData: season,
//                           )));
//             },
//             child: BaguleySeasonOverview(
//                 season: season['short_name'],
//                 champion: season['baguley_winner'],
//                 chairLeg: season['chair_leg'])),
//       );
//       seasonWidgets.add(const SizedBox(
//         height: 10,
//       ));
//     }
//     return seasonWidgets;
//   }

//   @override
//   Widget build(BuildContext context) {
//     //  CollectionReference fixtures = FirebaseFirestore.instance.collection('results').doc("season1").collection("results");
//     return Scaffold(
//         appBar: DraftAppBar(settings: false, title: "Historic Data"),
//         body: FutureBuilder<List<Object?>>(
//           future: setSeasonsData(),
//           builder:
//               (BuildContext context, AsyncSnapshot<List<Object?>> snapshot) {
//             if (snapshot.hasError) {
//               return const Text("Error");
//             }

//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasData) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         "assets/images/baguleyLogo.png",
//                         height: 75,
//                       ),
//                       // HallOfFameQuickView(),
//                       // ShameCorridor(),
//                       ...getSeasonOverviews(snapshot.data),
//                     ],
//                   ),
//                 );
//               }
//             }

//             return const Text("loading");
//           },
//         ));
//   }
// }

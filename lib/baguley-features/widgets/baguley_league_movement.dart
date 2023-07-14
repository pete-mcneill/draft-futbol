// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collection/collection.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:fl_animated_linechart/chart/line_chart.dart';
// import 'package:flutter/material.dart';

// import '../../models/league_standing.dart';
// import '../services/league_service.dart';

// class BaguleyLeagueMovement extends StatefulWidget {
//   String seasonId;
//   List<LeagueStanding?>? initialStandings;
//   BaguleyLeagueMovement({Key? key, required this.seasonId, required this.initialStandings}) : super(key: key);

//   @override
//   State<BaguleyLeagueMovement> createState() => _BaguleyLeagueMovementState();
// }

// class _BaguleyLeagueMovementState extends State<BaguleyLeagueMovement> {

//   List<DropdownMenuItem<String>> menuOptions = [];
//   String? dropdownValue = "38";
//   List<LeagueStanding?> standings = [];
//   int teamsInLeague = 0;
    
//   @override
//   void initState() {
//     standings = widget.initialStandings!;
//     super.initState();
//   }


//   void setGwsForDropdown() {
//     menuOptions = [];
//     for (var i = 0; i < 38; i++) {
//       String key = (i+1).toString();
//       menuOptions.add(DropdownMenuItem(
//           value: key,
//           child: Center(
//             child: Text(
//               "GW${key}",
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           )));
//     };
//     menuOptions = menuOptions.reversed.toList();
//   }

//   Widget getLeagueStanding(LeagueStanding standing) {
//     Color rowColor = Theme.of(context).cardColor;
//     if (standing.rank == 1) {
//       rowColor = Colors.green;
//     }
//     if (standing.rank == teamsInLeague) {
//       rowColor = Colors.red;
//     }

//     return Container(
//       height: 50,
//       color: rowColor,
//       child: Row(
//         children: [
//           Expanded(
//               flex: 1,
//               child: Text(
//                 standing.rank.toString(),
//                 style: standing.rank == 1
//                     ? const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)
//                     : const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.left,
//               )),
//           Expanded(
//               flex: 4,
//               child: Text(
//                 standing.teamName!,
//                 style: standing.rank == 1
//                     ? const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)
//                     : const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.left,
//               )),
//           Expanded(
//               flex: 2,
//               child: Text(
//                 standing.pointsFor.toString(),
//                 style: standing.rank == 1
//                     ? const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)
//                     : const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.center,
//               )),
//           Expanded(
//               flex: 2,
//               child: Text(
//                 standing.leaguePoints.toString(),
//                 style: standing.rank == 1
//                     ? const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)
//                     : const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.center,
//               ))
//         ],
//       ),
//     );
//   }


//   @override
//   Widget build(BuildContext context) {
//     setGwsForDropdown();

//     LineChart chart = LineChart.
//     return SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     DropdownButtonHideUnderline(
//                     child: DropdownButton2(
//                       iconEnabledColor: Theme.of(context).secondaryHeaderColor,
//                       isExpanded: false,
//                       items: menuOptions,
//                       onChanged: (value) async {
//                         List<LeagueStanding> updatedStandings = await getStandings(value.toString(), widget.seasonId);
//                         setState(() {
//                           standings = updatedStandings;
//                           dropdownValue = value.toString();
//                         });
//                       },
//                       value: dropdownValue,
//                       dropdownDecoration:
//                           BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
//                     ),
//                   ),
//                     Container(
//                       color: Theme.of(context).cardColor,
//                       child: Row(
//                         children: const [
//                           Expanded(
//                             flex: 1,
//                             child: Text(
//                               "",
//                               style: TextStyle(fontSize: 14),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 4,
//                             child: Text(
//                               "Team",
//                               style: TextStyle(fontSize: 14),
//                               textAlign: TextAlign.left,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               "+",
//                               style: TextStyle(fontSize: 14),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               "Pts",
//                               style: TextStyle(fontSize: 14),
//                               textAlign: TextAlign.center,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     for (LeagueStanding? standing in standings)
//                       getLeagueStanding(standing!)
//                   ],
//                 ),
//               );
//   }
// }

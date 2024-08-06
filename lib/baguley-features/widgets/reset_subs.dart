// import 'package:draft_futbol/models/draft_player.dart';
// import 'package:draft_futbol/providers/providers.dart';
// import 'package:draft_futbol/services/subs_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/DraftTeam.dart';
// import '../../models/draft_team.dart';
// import '../../models/sub.dart';

// class ResetSubsPopUp {
//   static showAlertDialog(BuildContext context, Map<int, Sub> Subs,
//       Map<int, DraftPlayer> players, DraftTeam team) async {
//     bool _isLoading = false;
//     Map<int, Sub> activeSubs = Subs;
//     Map<int, bool> subSelected = {};
//     Map<int, Sub> subsToRemove = {};
//     bool subsRemainingForTeam = true;

//     Widget resetAll = ElevatedButton(
//       child: const Text("Reset All"),
//       onPressed: () {
//         print("REset All");
//       },
//     );

//     Widget resetSelected(WidgetRef ref, setState) {
//       return ElevatedButton(
//         child: const Text("Reset Selected"),
//         onPressed: () async {
//           try {
//             setState(() {
//               _isLoading = true;
//             });
//             print("Reset Selected");

//             ref
//                 .read(fplGwDataProvider.notifier)
//                 .resetSelectedSubs(subsToRemove, team);
//             Map<int, Sub> subs =
//                 await SubsService().removeSelectedSubs(subsToRemove, team.id!);
//             // String gameweek = ref.read(gameweekProvider)!.currentGameweek;
//             // await ref.read(draftTeamsProvider.notifier).refreshSquadAfterSubs(team.id!, gameweek, subs);
//             // ref.read(draftTeamsProvider.notifier).updateLiveTeamScores(players);
//             // ref.refresh(refreshFutureLiveDataProvider);
//             // await ref.read(refreshFutureLiveDataProvider.future);
//             // ref.read(utilsProvider.notifier).setSubsReset(true);
//             setState(() {
//               activeSubs = subs;
//               subsToRemove = {};
//             });
//             if (subs.isEmpty) {
//               Navigator.of(context, rootNavigator: true).pop('dialog');
//             } else {
//               setState({_isLoading = false});
//             }
//           } catch (error) {
//             print(error);
//           }
//         },
//       );
//     }

//     List<Widget> generateSubs(setState, Map<int, bool> subSelected) {
//       List<Widget> subs = [];
//       for (var subEntry in activeSubs.entries) {
//         Sub sub = subEntry.value;
//         DraftPlayer playerIn = players[sub.subInId]!;
//         DraftPlayer playerOut = players[sub.subOutId]!;
//         // subSelected[playerIn.playerId!+playerOut.playerId!] = false;
//         subs.add(Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                     // backgroundColor: bonusColour,
//                     radius: 22.5,
//                     child: SizedBox(
//                         width: 55,
//                         height: 55,
//                         child: ClipOval(
//                           child: Image.network(
//                             "https://resources.premierleague.com/premierleague/photos/players/110x140/p${playerIn.playerCode}.png",
//                           ),
//                         ))),
//                 Text(playerIn.playerName!)
//               ],
//             ),
//             const Icon(
//               Icons.swap_horiz,
//               color: Colors.pink,
//               size: 50.0,
//               semanticLabel: 'Text to announce in accessibility modes',
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 CircleAvatar(
//                     // backgroundColor: bonusColour,
//                     radius: 22.5,
//                     child: SizedBox(
//                         width: 55,
//                         height: 55,
//                         child: ClipOval(
//                           child: Image.network(
//                             "https://resources.premierleague.com/premierleague/photos/players/110x140/p${playerOut.playerCode}.png",
//                           ),
//                         ))),
//                 Text(playerOut.playerName!)
//               ],
//             ),
//             Checkbox(
//               checkColor: Colors.white,
//               // fillColor: MaterialStateProperty.resolveWith(Colors.green!),
//               value: subSelected[playerIn.playerId! + playerOut.playerId!] ??
//                   false,
//               onChanged: (bool? value) {
//                 setState(() {
//                   subSelected[playerIn.playerId! + playerOut.playerId!] =
//                       value!;
//                 });
//                 if (value!) {
//                   subsToRemove[subEntry.key] = sub;
//                 } else {
//                   subsToRemove.remove(subEntry.key);
//                 }
//               },
//             )
//           ],
//         ));
//       }
//       return subs;
//     }

//     StatefulBuilder alert = StatefulBuilder(builder: (context, setState) {
//       return Consumer(
//         builder: (BuildContext context, WidgetRef ref, Widget? child) {
//           return AlertDialog(
//             title: Text(
//               team.teamName!,
//               textAlign: TextAlign.center,
//             ),
//             content: Wrap(children: [
//               Column(children: [
//                 _isLoading
//                     ? Center(
//                         child: SizedBox(
//                             height: MediaQuery.of(context).size.height,
//                             child: const Column(
//                               children: [
//                                 Text("Saving Changes"),
//                                 CircularProgressIndicator(),
//                               ],
//                             )),
//                       )
//                     : const Text(
//                         "Sub In - Sub Out",
//                         textAlign: TextAlign.center,
//                       ),
//                 if (!_isLoading) ...generateSubs(setState, subSelected)
//               ]),
//             ]),
//             actions: [
//               if (!_isLoading) resetSelected(ref, setState),
//               // resetAll,
//             ],
//           );
//         },
//       );
//     });

//     // show the dialog
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }

import 'dart:convert';

import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/api_service.dart';
import 'package:draft_futbol/ui/screens/on_boarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageleagueDialog extends ConsumerStatefulWidget {
  final String? type;
  const ManageleagueDialog({Key? key, this.type}) : super(key: key);

  @override
  _ManageleagueDialogState createState() => _ManageleagueDialogState();
}

class _ManageleagueDialogState extends ConsumerState<ManageleagueDialog> {
  final myController = TextEditingController();
  String leagueId = "";
  bool showSubmitButton = false;
  String newLeagueName = "";
  bool leagueIdExists = false;
  bool loading = false;
  bool success = false;

  @override
  void initState() {
    super.initState();

    myController.addListener(setLeagueId);
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void setLeagueId() {
    setState(() {
      leagueId = myController.text;
      leagueIdExists = false;
    });
    if (leagueId == "") {
      showSubmitButton = false;
    }
  }

  void checkIfLeagueAlreadyAdded(Map<String, dynamic> leagueIds) {
    if (leagueIds.containsKey(leagueId)) {
      setState(() {
        leagueIdExists = true;
      });
    } else {
      setState(() {
        leagueIdExists = false;
      });
    }
  }

  Future<Map<String, dynamic>> addNewLeague() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? leagueIds;
    Map<String, dynamic>? leagueMap;
    try {
      leagueIds = _prefs.getString('league_ids');
      leagueMap = json.decode(leagueIds!);
      leagueMap![leagueId] = {"name": newLeagueName, "season": "23/24"};
    } catch (e) {
      leagueMap = {
        leagueId: {"name": newLeagueName, "season": "23/24"}
      };
    }
    await _prefs.setString('league_ids', json.encode(leagueMap));
    ref.watch(utilsProvider.notifier).setLeagueIds(leagueMap);
    return leagueMap;
  }

  Future<Map<String, dynamic>> removeLeague(
      String key, Map<String, dynamic> leagueIds) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? leagueIds = _prefs.getString('league_ids');
    Map<String, dynamic>? leagueMap;
    leagueMap = json.decode(leagueIds!);
    leagueMap!.remove(key);
    await _prefs.setString('league_ids', json.encode(leagueMap));
    ref.watch(utilsProvider.notifier).setLeagueIds(leagueMap);
    return leagueMap;
  }

  Widget addLeagueWidget(Map<String, dynamic> leagueIds, Api _api) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        // backgroundColor: Colors.transparent,

        child: Stack(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                const Center(
                    child: Text("Current Leagues:",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ))),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: leagueIds.keys.length,
                  itemBuilder: (context, index) {
                    var key = leagueIds.keys.elementAt(index);
                    String team = leagueIds[key]['name'];
                    return ListTile(
                      title: Center(child: Text(team)),
                    );
                  },
                ),
                const Center(
                  child: Text(
                    "Enter New League ID",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextField(
                  controller: myController,
                ),
                ElevatedButton(
                    onPressed: leagueId == ""
                        ? null
                        : () {
                            setState(() {
                              success = false;
                            });
                            _api.checkLeagueExists(leagueId).then((value) => {
                                  if (value['valid'])
                                    {
                                      checkIfLeagueAlreadyAdded(leagueIds),
                                      if (!leagueIdExists)
                                        {
                                          setState(() {
                                            showSubmitButton = true;
                                            newLeagueName = value['name'];
                                          })
                                        }
                                      else
                                        {
                                          setState(() {
                                            newLeagueName = value['name'];
                                          })
                                        }
                                    }
                                });
                          },
                    child: const Center(
                      child: Text("Search for league"),
                    )),
                if (showSubmitButton) ...[
                  const Center(child: Text("League Name to be added:")),
                  Center(child: Text(newLeagueName)),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        Map<String, dynamic> updatedIds = await addNewLeague();
                        var leagueIdsList = updatedIds.entries.toList();
                        String activekey;
                        if (leagueIdsList.isEmpty) {
                          activekey = "";
                        } else {
                          activekey = leagueIdsList[0].key;
                        }
                        ref
                            .read(utilsProvider.notifier)
                            .updateActiveLeague(activekey);
                        final manager = ref.refresh(futureLiveDataProvider);
                        await ref.watch(futureLiveDataProvider.future);
                        if (ref.watch(utilsProvider).leagueIds!.isEmpty) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => OnBoardingScreen()),
                              (Route<dynamic> route) => false);
                        } else {
                          setState(() {
                            success = true;
                          });
                        }
                        setState(() {
                          loading = false;
                        });
                        // Navigator.pop(context);
                      },
                      child: Center(
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text("Save New League"))),
                  if (success) Text("${newLeagueName} succesfully added")
                ],
                if (leagueIdExists)
                  ElevatedButton(
                      onPressed: null,
                      child: Center(
                        child: Text(
                            "League (" + newLeagueName + ") already added"),
                      ))
              ],
            ),
          )
        ]));
  }

  Widget removeLeagueWidget(Map<String, dynamic> leagueIds, Api _api) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        // backgroundColor: Colors.transparent,
        child: Stack(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                const Center(child: Text("Select League to remove:")),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: leagueIds.keys.length,
                  itemBuilder: (context, index) {
                    var key = leagueIds.keys.elementAt(index);
                    String team = leagueIds[key]['name'];
                    return Dismissible(
                      key: Key(key),
                      direction: DismissDirection.startToEnd,
                      child: ListTile(
                        title: Text(team),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () async {
                            Map<String, dynamic> updatedIds =
                                await removeLeague(key, leagueIds);
                            var leagueIdsList = updatedIds.entries.toList();
                            String activekey;
                            if (leagueIdsList.isEmpty) {
                              activekey = "";
                            } else {
                              activekey = leagueIdsList[0].key;
                            }
                            ref
                                .read(utilsProvider.notifier)
                                .updateActiveLeague(activekey);
                            final manager = ref.refresh(futureLiveDataProvider);
                            await ref.watch(futureLiveDataProvider.future);
                            if (ref.watch(utilsProvider).leagueIds!.isEmpty) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => OnBoardingScreen()),
                                  (Route<dynamic> route) => false);
                            }
                            setState(() {
                              // items.removeAt(index);
                            });
                          },
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          // items.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          )
        ]));
  }

  void _showAddedToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Added League'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Api _api = Api();
    Map<String, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    if (widget.type == "add") {
      return addLeagueWidget(leagueIds, _api);
    } else if (widget.type == "remove") {
      return removeLeagueWidget(leagueIds, _api);
    }
    return Container();
  }
}

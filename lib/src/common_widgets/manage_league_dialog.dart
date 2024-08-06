import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/application/live_service.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/initialise_home_screen.dart';
import 'package:draft_futbol/src/features/onboarding/presentation/on_boarding_screen.dart';
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
  String? leagueId;
  bool showSubmitButton = false;
  String newLeagueName = "";
  LocalLeagueMetadata? league;
  bool leagueIdExists = false;
  bool loading = false;
  bool success = false;

  Widget addLeagueWidget(List<LocalLeagueMetadata> leagueIds, Api _api) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        // backgroundColor: Colors.transparent,

        child: Stack(children: <Widget>[
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ),
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
                  itemCount: leagueIds.length,
                  itemBuilder: (context, index) {
                    LocalLeagueMetadata league = leagueIds[index];
                    String team = league.name;
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
                            _api.checkLeagueExists(leagueId!).then((value) => {
                                  if (value['valid'])
                                    {
                                      checkIfLeagueAlreadyAdded(leagueIds),
                                      if (!leagueIdExists)
                                        {
                                          league = LocalLeagueMetadata.create({
                                            "id": int.parse(leagueId!),
                                            "name": value['name'],
                                            "scoring": value['type'],
                                            "admin_entry": 0
                                          }),
                                          setState(() {
                                            showSubmitButton = true;
                                            league = league;
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
                        await addNewLeague();
                        // var leagueIdsList = updatedIds.entries.toList();
                        // int activekey;
                        // if (leagueIdsList.isEmpty) {
                        //   activekey = 0;
                        // } else {
                        //   activekey = leagueIdsList[0].key;
                        // }
                        // ref
                        //     .read(utilsProvider.notifier)
                        //     .updateActiveLeague(activekey);
                        final List<int> leagueIds = ref.read(dataStoreProvider).getLeagues().map((league) => league.id).toList();
                        await ref.read(liveServiceProvider).getDraftData(leagueIds);

                        if (ref.watch(dataStoreProvider).getLeagues().isEmpty) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const OnBoardingScreen()),
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
                  if (success) Text("$newLeagueName succesfully added")
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

  Future<void> addNewLeague() async {
    await ref.read(dataStoreProvider).saveLeague(league!);
  }

  @override
  Widget build(BuildContext context) {
    Api _api = Api();
    List<LocalLeagueMetadata> leaguesMetadata =
        ref.watch(dataStoreProvider).getLeagues();

        
    if (widget.type == "add") {
      return SingleChildScrollView(child: addLeagueWidget(leaguesMetadata, _api));
    } else if (widget.type == "remove") {
      return SingleChildScrollView(child: removeLeagueWidget(leaguesMetadata, _api));
    }
    return Container();
  }

  void checkIfLeagueAlreadyAdded(List<LocalLeagueMetadata> leagueIds) {
    if(leagueIds.any((league) => league.id.toString() == leagueId)) {
      setState(() {
        leagueIdExists = true;
      });
    } else {
      setState(() {
        leagueIdExists = false;
      });
    }
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    myController.addListener(setLeagueId);
  }

  Future<List<LocalLeagueMetadata>> removeLeague(LocalLeagueMetadata league) async {
    ref.read(dataStoreProvider).deleteLeague(league);
    return ref.read(dataStoreProvider).getLeagues();
  }

  Widget removeLeagueWidget(List<LocalLeagueMetadata> leagueIds, Api _api) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        // backgroundColor: Colors.transparent,
        child: Stack(children: <Widget>[
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                const Center(child: Text("Select League to remove:")),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: leagueIds.length,
                  itemBuilder: (context, index) {
                    LocalLeagueMetadata league = leagueIds[index];
                    String team = league.name;
                    return Dismissible(
                      key: Key(league.id.toString()),
                      direction: DismissDirection.startToEnd,
                      child: ListTile(
                        title: Text(team),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () async {
                            print("HERE");
                            List<LocalLeagueMetadata> updatedLeagues =
                                await removeLeague(league);
                            int activekey;
                            if (updatedLeagues.isEmpty) {
                              activekey = 0;
                            } else {
                              activekey = updatedLeagues[0].id;
                            }
                            // ref
                            //     .read(utilsProvider.notifier)
                            //     .updateActiveLeague(activekey);
                            if (updatedLeagues.isEmpty) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const InitialiseHomeScreen()),
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

  void setLeagueId() {
    setState(() {
      leagueId = myController.text;
      leagueIdExists = false;
    });
    if (leagueId == "") {
      showSubmitButton = false;
    }
  }

  void _showAddedToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Added League'),
      ),
    );
  }
}

import 'package:draft_futbol/baguley-features/widgets/reset_subs.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:draft_futbol/models/players/stat.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/subs_service.dart';
import 'package:draft_futbol/ui/screens/pitch/player.dart';
import 'package:draft_futbol/ui/screens/pitch/player_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../models/Gameweek.dart';
import '../../../models/draft_subs.dart';
import '../../../models/fixture.dart';
import '../featureDiscovery/subs_info_discovery.dart';

class Squad extends ConsumerStatefulWidget {
  DraftTeam team;
  Squad({Key? key, required this.team}) : super(key: key);

  @override
  _SquadState createState() => _SquadState();
}

class _SquadState extends ConsumerState<Squad> {
  Map<String, dynamic> validSubPositions = {
    "GK": {"valid": true, "ruleMin": 1},
    "DEF": {"valid": true, "ruleMin": 3},
    "MID": {"valid": true, "ruleMin": 2},
    "FWD": {"valid": true, "ruleMin": 1},
  };
  bool _isLoading = false;
  String? currentGameweek;
  bool subModeEnabled = false;
  bool saveSubs = false;
  bool subsToSave = false;
  Map<String, PlMatch>? plMatches;
  Map<int, DraftPlayer>? players;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    if (subModeEnabled) {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Discard any unsaved subs?'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("NO"),
                ),
                const SizedBox(height: 16),
                new GestureDetector(
                  onTap: () {
                    ref.read(utilsProvider.notifier).setSubModeEnabled(false);
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("YES"),
                ),
              ],
            ),
          )) ??
          false;
    } else {
      return true;
    }
  }

  void _showPlayerPopup(DraftPlayer player) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return PlayerPopup(player: player);
      },
    );
  }

  void _checkValidSubsForPositions(
      DraftPlayer player, Map<String, List<DraftPlayer>> _squad) async {
    if (player.position == "GK") {
      setState(() {
        validSubPositions["GK"]['valid'] = true;
        validSubPositions["DEF"]['valid'] = false;
        validSubPositions["MID"]['valid'] = false;
        validSubPositions["FWD"]['valid'] = false;
      });
    } else {
      for (var position in validSubPositions.entries) {
        if (position.key == "GK") {
          setState(() {
            validSubPositions[position.key]['valid'] = false;
          });
        } else {
          if (position.key != player.position &&
              _squad[position.key]!.length == position.value['ruleMin']) {
            try {
              setState(() {
                validSubPositions[position.key]['valid'] = false;
              });
            } catch (error) {
              print(error);
            }
          }
        }
      }
    }
  }

  Future<void> _saveSubs() async {
    if (subsToSave) {
      setState(() {
        _isLoading = true;
      });
      ref.read(draftTeamsProvider.notifier).updateLiveTeamScores(players!);
      ref.refresh(refreshFutureLiveDataProvider);
      await ref.read(refreshFutureLiveDataProvider.future);
      // ref
      // .read(draftTeamsProvider.notifier)
      // .updateTeamSquad(widget.team.squad, widget.team.id!);
      // ref.read(draftTeamsProvider.notifier).updateLiveTeamScores(players!);
      // String gameweek = ref.read(gameweekProvider)!.currentGameweek;
      // Map<String, Map<String, List<Fixture>>> allFixtures = ref.read(fixturesProvider).fixtures;
      // List<Fixture> gwLeagueFixtures = allFixtures[widget.team.leagueId.toString()]![gameweek]!;
      // for(Fixture fixture in gwLeagueFixtures){
      //   if(fixture.homeTeamId == widget.team.id || fixture.awayTeamId == widget.team.id){
      //     ref.read(h2hStandingsProvider.notifier).refreshStandingsAfterSubs(fixture, widget.team);
      //   }
      // }
      setState(() {
        widget.team.userSubsActive = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetSubs() async {
    setState(() {
      _isLoading = true;
    });
    Map<dynamic, dynamic> subs = Hive.box("subs").toMap();
    List<int> subsToRemove = [];
    subs.forEach((key, value) {
      if (value.teamId == widget.team.id) {
        subsToRemove.add(key);
      }
    });
    for (int key in subsToRemove) {
      Hive.box('subs').delete(key);
    }
    Map<int, DraftPlayer> players = ref.read(draftPlayersProvider).players;
    ref
        .read(draftTeamsProvider.notifier)
        .updateTeamSquad(widget.team.squad, widget.team.id!);
    ref.read(draftTeamsProvider.notifier).updateLiveTeamScores(players);
    ref.refresh(refreshFutureLiveDataProvider);
    await ref.read(refreshFutureLiveDataProvider.future);
    Navigator.of(context).pop(true);
  }

  GestureDetector generatePlayer(DraftPlayer player) {
    bool subAllowed = true;
    bool validSubForPosition = true;
    bool subHighlighted = false;
    // Check if Squad has min positions for subs
    String position = player.position!;
    if (validSubPositions[player.position!]!['valid']) {
      subAllowed = true;
    } else {
      subAllowed = false;
    }
    // Check if player played a match already
    for (Match match in player.matches!) {
      PlMatch _match = plMatches![match.matchId.toString()]!;
      for (Stat stat in match.stats!) {
        if (stat.statName == "Minutes played" && stat.fantasyPoints != 0) {
          subAllowed = false;
          break;
        }
      }
    }

    return GestureDetector(
        onTap: () => _showPlayerPopup(player),
        child: DragTarget<DraftPlayer>(
          onWillAccept: (data) => subHighlighted = true,
          onLeave: (data) => subHighlighted = false,
          onAcceptWithDetails: (details) {
            if (subAllowed) {
              DraftPlayer incomingSub = details.data;
              int playerPosition =
                  widget.team.squad![int.parse(player.playerId!)]!;
              int subPosition =
                  widget.team.squad![int.parse(incomingSub.playerId!)]!;
              setState(() {
                widget.team.squad![int.parse(player.playerId!)] = subPosition;
                widget.team.squad![int.parse(incomingSub.playerId!)] =
                    playerPosition;
                subsToSave = true;
              });
              DraftSub _sub = DraftSub(
                  currentGameweek!,
                  int.parse(player.playerId!),
                  int.parse(incomingSub.playerId!),
                  playerPosition,
                  subPosition,
                  widget.team.id!);
              Hive.box('subs').add(_sub);
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Invalid Sub")));
            }
          },
          builder: (context, candidateItems, rejectedItems) {
            bool valid = false;
            if (candidateItems.isNotEmpty) {}
            return Player(
              player: player,
              subModeEnabled: subModeEnabled,
              subValid: subAllowed,
              subHighlighted: subHighlighted,
            );
          },
          onAccept: (item) {
            if (!subAllowed) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Invalid Sub")));
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool gameweek = ref.watch(gameweekProvider)!.gameweekFinished;
    players = ref.read(draftPlayersProvider).players;
    currentGameweek = ref.read(gameweekProvider)!.currentGameweek;
    plMatches = ref.watch(plMatchesProvider).plMatches!;
    Map<int, DraftPlayer>? _players = ref.watch(draftPlayersProvider).players;
    Map<String, List<DraftPlayer>> _squad = {
      "GK": [],
      "DEF": [],
      "MID": [],
      "FWD": [],
      "SUBS": []
    };
    try {
      Map<int, int>? test = widget.team.squad;
      widget.team.squad?.forEach((key, value) {
        DraftPlayer? _player = _players[key];
        if (value < 12) {
          _squad[_player!.position]!.add(_player);
        } else {
          _squad['SUBS']!.add(_player!);
        }
      });
      if (_squad['SUBS']![0].position != "GK") {
        int gkIndex = 0;
        _squad['SUBS']!.asMap().forEach((index, value) {
          if (_squad['SUBS']![index].position == "GK") {
            gkIndex = index;
          }
        });

        final DraftPlayer subGk = _squad['SUBS']!.removeAt(gkIndex);
        _squad['SUBS']!.insert(0, subGk);
      }
      // _squad['SUBS']!.sort((a, b) => a.positionId!.compareTo(b.positionId!));
    } catch (e) {
      print(e);
    }

    return Stack(children: [
      WillPopScope(
        onWillPop: _onWillPop,
        child: Container(
          // width: MediaQuery.of(context).size.width
          // constraints: BoxConstraints(minWidth: 11, maxWidth: 110, minHeight: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['GK']!)
                    generatePlayer(player)
                ],
              ),
              // DEF
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['DEF']!)
                    generatePlayer(player)
                ],
              ),
              // MID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['MID']!)
                    generatePlayer(player)
                ],
              ),
              // FWD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['FWD']!)
                    generatePlayer(player)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.start,
                crossAxisAlignment: widget.team.userSubsActive!
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (!gameweek)
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 5),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).canvasColor),
                              onPressed: () async => {
                                    if (!subModeEnabled &&
                                        !(Hive.box('discovery')
                                            .get('subDiscoveryInfo')))
                                      {
                                        await SubsInfoDiscoveryPopUp
                                            .showAlertDialog(context),
                                      }
                                    else
                                      {
                                        if (subModeEnabled)
                                          {await _saveSubs(), saveSubs = false},
                                        setState(() {
                                          subModeEnabled = !subModeEnabled;
                                        }),
                                        if (subModeEnabled)
                                          {
                                            ref
                                                .read(utilsProvider.notifier)
                                                .setSubModeEnabled(true)
                                          }
                                        else
                                          {
                                            ref
                                                .read(utilsProvider.notifier)
                                                .setSubModeEnabled(false)
                                          }
                                      }
                                  },
                              child: Text(
                                subModeEnabled ? "Save Subs" : "Make Subs",
                                textAlign: TextAlign.center,
                              )),
                          if (widget.team.userSubsActive!)
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).canvasColor),
                                onPressed: () async {
                                  Map<int, DraftSub> _subs = SubsService()
                                      .getSubsForTeam(widget.team.id!);
                                  await ResetSubsPopUp.showAlertDialog(
                                      context, _subs, players!, widget.team);
                                  _subs = SubsService()
                                      .getSubsForTeam(widget.team.id!);
                                  if (_subs.isEmpty) {
                                    setState(() {
                                      widget.team.userSubsActive = false;
                                    });
                                  }
                                },
                                child: Text(
                                  "Reset Subs",
                                  textAlign: TextAlign.center,
                                )),
                        ],
                      ),
                    ),
                  for (DraftPlayer player in _squad['SUBS']!)
                    subModeEnabled
                        ? LongPressDraggable<DraftPlayer>(
                            data: player,
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            onDragStarted: () =>
                                {_checkValidSubsForPositions(player, _squad)},
                            onDragEnd: (details) => setState(() {
                                  validSubPositions["GK"]["valid"] = true;
                                  validSubPositions["DEF"]["valid"] = true;
                                  validSubPositions["MID"]["valid"] = true;
                                  validSubPositions["FWD"]["valid"] = true;
                                }),
                            feedback: DefaultTextStyle(
                              style: Theme.of(context).textTheme.bodyMedium!,
                              child: Player(
                                  player: player,
                                  subModeEnabled: false,
                                  subValid: true),
                            ),
                            child: GestureDetector(
                                onTap: () => _showPlayerPopup(player),
                                child: Player(
                                    player: player,
                                    subModeEnabled: subModeEnabled,
                                    subValid: true)))
                        : GestureDetector(
                            onTap: () => _showPlayerPopup(player),
                            child: Player(
                                player: player,
                                subModeEnabled: subModeEnabled,
                                subValid: true))
                ],
              ),
            ],
          ),
        ),
      ),
      if (_isLoading)
        Container(
          height: MediaQuery.of(context).size.height,
          child: const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        ),
      if (_isLoading)
        Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Text("Saving Changes"),
                  CircularProgressIndicator(),
                ],
              )),
        ),
    ]);
  }
}

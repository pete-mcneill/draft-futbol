import 'package:draft_futbol/baguley-features/widgets/reset_subs.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/player.dart';
import 'package:draft_futbol/src/features/pitch/presentation/player_popup.dart';
import 'package:draft_futbol/src/features/substitutes/application/subs_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../live_data/domain/draft_domains/draft_team.dart';
import '../../substitutes/domain/sub.dart';

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
  int? currentGameweek;
  bool subModeEnabled = false;
  bool saveSubs = false;
  bool subsToSave = false;
  List<Sub> subs = [];
  Map<int, PlMatch>? plMatches;
  Map<int, DraftPlayer>? players;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    if (subModeEnabled) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Discard any unsaved subs?'),
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("NO"),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    cancelSubs();
                    ref
                        .read(subsControllerProvider.notifier)
                        .removeSub(widget.team);
                    ref
                        .read(subsControllerProvider.notifier)
                        .disableSubsMode(widget.team.id!);
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

  void cancelSubs() {
    for (Sub sub in subs) {
      widget.team.squad![sub.subInId] = sub.subInPosition;
      widget.team.squad![sub.subOutId] = sub.subOutPosition;
    }
    subs = [];
    final sorted = widget.team.squad!.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final sortedSquad = {for (var entry in sorted) entry.key: entry.value};
    setState(() {
      widget.team.squad = sortedSquad;
    });
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
      for (Sub _sub in subs) {
        ref.read(subsControllerProvider.notifier).addSub(_sub, widget.team);
      }
      ref.read(subsControllerProvider.notifier).enableSubsToSave();
      setState(() {
        widget.team.userSubsActive = true;
        _isLoading = false;
      });
    }
  }

  GestureDetector generatePlayer(DraftPlayer player, int gameweek) {
    bool subAllowed = true;
    // bool validSubForPosition = true;
    bool subHighlighted = false;
    // Check if Squad has min positions for subs
    // String position = player.position!;
    if (validSubPositions[player.position!]!['valid']) {
      subAllowed = true;
    } else {
      subAllowed = false;
    }
    // Check if player played a match already
    for (PlMatchStats match in player.matches![gameweek]!) {
      for (Stat stat in match.stats!) {
        if (stat.statName == "Minutes played") {
          if (stat.value != 0) {
            subAllowed = false;
          }
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
              int playerPosition = widget.team.squad![player.playerId!]!;
              int subPosition = widget.team.squad![incomingSub.playerId!]!;
              widget.team.squad![player.playerId!] = subPosition;
              widget.team.squad![incomingSub.playerId!] = playerPosition;
              final sorted = widget.team.squad!.entries.toList()
                ..sort((a, b) => a.value.compareTo(b.value));
              final sortedSquad = {
                for (var entry in sorted) entry.key: entry.value
              };
              setState(() {
                widget.team.squad = sortedSquad;
                subsToSave = true;
              });
              Sub _sub = Sub(
                  currentGameweek!,
                  player.playerId!,
                  incomingSub.playerId!,
                  playerPosition,
                  subPosition,
                  widget.team.id!);
              subs.add(_sub);
              _saveSubs();
              // ref.read(fplGwDataProvider.notifier).subScorePreview(
              //     widget.team.squad, widget.team.leagueId, widget.team.id!);
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Invalid Sub")));
            }
          },
          builder: (context, candidateItems, rejectedItems) {
            bool substitue = checkForSubstituteIcon(player);
            return Player(
              player: player,
              subModeEnabled: subModeEnabled,
              subValid: subAllowed,
              subHighlighted: subHighlighted,
              subIcon: substitue,
            );
          },
          onAccept: (item) {
            print(item);
            if (!subAllowed) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Invalid Sub")));
            }
          },
        ));
  }

  bool checkForSubstituteIcon(DraftPlayer player) {
    bool substitue = false;
    for (var element in subs) {
      if (element.subInId == player.playerId) {
        substitue = true;
      }
      if (element.subOutId == player.playerId) {
        substitue = true;
      }
    }
    final storedSubs = Hive.box('subs').toMap();
    int currentGameweek =
        ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
    final teamSubs = storedSubs;
    if (teamSubs[currentGameweek] != null) {
      if (teamSubs[currentGameweek]![widget.team.id] != null) {
        for (var value in teamSubs[currentGameweek]![widget.team.id]) {
          if (value.subInId == player.playerId) {
            substitue = true;
          }
          if (value.subOutId == player.playerId) {
            substitue = true;
          }
        }
      }
    }
    return substitue;
  }

  Widget generateSub(
      DraftPlayer player, Map<String, List<DraftPlayer>> _squad) {
    bool substitue = checkForSubstituteIcon(player);
    if (subModeEnabled) {
      return LongPressDraggable<DraftPlayer>(
          data: player,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: () => {_checkValidSubsForPositions(player, _squad)},
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
              subValid: true,
              subIcon: substitue,
            ),
          ),
          child: GestureDetector(
              onTap: () => _showPlayerPopup(player),
              child: Player(
                  player: player,
                  subModeEnabled: subModeEnabled,
                  subValid: true,
                  subIcon: substitue)));
    } else {
      return GestureDetector(
          onTap: () => _showPlayerPopup(player),
          child: Player(
              player: player,
              subModeEnabled: subModeEnabled,
              subValid: true,
              subIcon: substitue));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(subsControllerProvider).cancelSubs) {
      cancelSubs();
    }
    _isLoading = ref.watch(subsControllerProvider).subsInProgress;
    subModeEnabled = ref.watch(subsControllerProvider).subsModeActive;
    players = ref.read(premierLeagueControllerProvider).players;
    currentGameweek =
        ref.watch(liveDataControllerProvider).gameweek!.currentGameweek;
    plMatches = ref.watch(premierLeagueControllerProvider).matches;

    Map<String, List<DraftPlayer>> _squad = {
      "GK": [],
      "DEF": [],
      "MID": [],
      "FWD": [],
      "SUBS": []
    };

    try {
      widget.team.squad?.forEach((key, value) {
        DraftPlayer? _player = players![key];
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
    double pitchWidth = kIsWeb ? 1000 : MediaQuery.of(context).size.width;
    return Stack(children: [
      WillPopScope(
        onWillPop: _onWillPop,
        child: Container(
          width: pitchWidth,
          // constraints: BoxConstraints(minWidth: 11, maxWidth: 110, minHeight: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Text("Row weird")
                  for (DraftPlayer player in _squad['GK']!)
                    generatePlayer(player, currentGameweek!),
                ],
              ),
              // DEF
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['DEF']!)
                    generatePlayer(player, currentGameweek!),
                ],
              ),
              // MID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['MID']!)
                    generatePlayer(player, currentGameweek!),
                ],
              ),
              // FWD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DraftPlayer player in _squad['FWD']!)
                    generatePlayer(player, currentGameweek!),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.start,
                crossAxisAlignment: widget.team.userSubsActive!
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  for (DraftPlayer player in _squad['SUBS']!)
                    generateSub(player, _squad)
                ],
              ),
            ],
          ),
        ),
      ),
      if (_isLoading) ...[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Opacity(
            opacity: 1,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        ),
        Center(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Column(
                children: [
                  Text("Saving Changes"),
                  CircularProgressIndicator(),
                ],
              )),
        ),
      ]
    ]);
  }
}

// TODO: Fetcher for Transactions doesn't Work yet

import 'dart:ffi';

import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/cup/presentation/manage_cup/save_cup_dialog.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class ManageCup extends ConsumerStatefulWidget {
  Cup? cup;
  ManageCup({Key? key, this.cup}) : super(key: key);

  @override
  _ManageCupState createState() => _ManageCupState();
}

class _ManageCupState extends ConsumerState<ManageCup>
    with TickerProviderStateMixin {
  final introKey = GlobalKey<IntroductionScreenState>();
  bool skipEnabled = false;
  String? roundName;
  String? selectedValue;
  String? selectedGameweek2;
  String? selectedHomeFixture;
  String? selectedAwayFixture;
  List<int> _selectedTeams = [];
  List<dynamic> rounds = [];
  bool multipleLegs = false;
  bool addRound = false;
  bool addFixture = false;
  int roundCounter = 1;
  Map<String, List<CupFixture>> fixtures = {};
  Cup? cup;

  final cupNameController = TextEditingController();
  final roundNameController = TextEditingController();

  void _onIntroEnd(context) async {
    saveCup();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SaveCupDialog(cup: cup!);
      },
    ).then((value) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.black,
      imagePadding: EdgeInsets.zero,
    );
    return IntroductionScreen(
        onChange: (value) {
          if (value != 0) {
            setState(() {
              skipEnabled = true;
            });
          } else {
            setState(() {
              skipEnabled = false;
            });
          }
        },
        key: introKey,
        // globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        pages: [
          PageViewModel(
              decoration: pageDecoration.copyWith(
                bodyFlex: 20,
                imageFlex: 6,
                safeArea: 20,
              ),
              title: "Create/Edit a Cup",
              bodyWidget: Card(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 18.0,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  'Work In progress, please report any issues or suggestions to improve the feature',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                    TextFormField(
                        controller: cupNameController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Name',
                        )),
                    MultiSelectDialogField(
                      title: Text("Select Teams"),
                      buttonText: Text("Select Teams"),
                      itemsTextStyle: const TextStyle(color: Colors.white),
                      selectedItemsTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      items: ref
                          .read(draftDataControllerProvider)
                          .teams
                          .entries
                          .map((entry) =>
                              MultiSelectItem(entry.key, entry.value.teamName!))
                          .toList(),
                      listType: MultiSelectListType.LIST,
                      initialValue: _selectedTeams,
                      onConfirm: (values) {
                        _selectedTeams = values;
                      },
                    ),
                    if (rounds.isNotEmpty) ...[
                      Text("Rounds"),
                      Card(
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Text(
                                      'Name',
                                    )),
                                Expanded(flex: 5, child: Text("Gameweek(s)")),
                                Expanded(flex: 2, child: Text("Delete"))
                              ],
                            ),
                            for (var round in rounds) ...[
                              Row(
                                children: [
                                  Expanded(flex: 5, child: Text(round['id'])),
                                  Expanded(
                                      flex: 5,
                                      child: Text(round['gameweek'].toString() +
                                          ' ' +
                                          (round['gameweek'] !=
                                                  round['secondGameweek']
                                              ? round['secondGameweek']
                                                  .toString()
                                              : ''))),
                                  Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            rounds.remove(round);
                                          });
                                        },
                                        child: Icon(Icons.delete),
                                      ))
                                ],
                              ),
                              SizedBox(height: 10)
                            ]
                          ],
                        ),
                      )
                    ],
                    ElevatedButton(
                        onPressed: () => {
                              setState(() {
                                addRound = !addRound;
                                multipleLegs = false;
                                selectedGameweek2 = null;
                                selectedValue = null;
                              })
                            },
                        child: const Text("Add Round")),
                    if (addRound) createAddRoundWidget()
                  ],
                ),
              ),
              image: const Center(
                child: Icon(Icons.emoji_events, size: 50.0),
              ),
              footer: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ))),
          for (var round in rounds)
            PageViewModel(
                decoration: pageDecoration.copyWith(
                  bodyFlex: 20,
                  imageFlex: 6,
                  safeArea: 20,
                ),
                titleWidget: SafeArea(
                  child: Text(round['id']),
                ),
                // title: round['id'],
                bodyWidget: Column(children: [
                  SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        Text("Add Fixture"),
                        Text("Fixtures can be added at a later stage"),
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: DropdownButton<String>(
                                value: selectedHomeFixture,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.white),
                                // dropdownColor: Colors.white,
                                underline: Container(
                                  height: 2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    selectedHomeFixture = value!;
                                  });
                                },
                                items: _selectedTeams
                                    .map<DropdownMenuItem<String>>((int value) {
                                  DraftTeam _team = ref
                                      .read(draftDataControllerProvider)
                                      .teams[value]!;
                                  return DropdownMenuItem<String>(
                                      value: _team.id.toString(),
                                      child: Text(
                                        _team.teamName!,
                                        style: TextStyle(
                                            color: int.parse(
                                                        selectedAwayFixture ??
                                                            "0") ==
                                                    value
                                                ? Colors.grey
                                                : Colors.white),
                                      ));
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "v",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: DropdownButton<String>(
                                value: selectedAwayFixture,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.white),
                                // dropdownColor: Colors.white,
                                underline: Container(
                                  height: 2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    selectedAwayFixture = value!;
                                  });
                                },
                                items: _selectedTeams
                                    .map<DropdownMenuItem<String>>((int value) {
                                  DraftTeam _team = ref
                                      .read(draftDataControllerProvider)
                                      .teams[value]!;
                                  return DropdownMenuItem<String>(
                                      value: _team.id.toString(),
                                      child: Text(_team.teamName!,
                                          style: TextStyle(
                                              color: int.parse(
                                                          selectedHomeFixture ??
                                                              "0") ==
                                                      value
                                                  ? Colors.grey
                                                  : Colors.white)));
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              {saveFixture(round['id']), setState(() {})},
                          child: const Text("Save Fixture"),
                        ),
                      ],
                    ),
                  ),
                  Text("Fixtures"),
                  for (var _fixture in fixtures[round['id']] ?? [])
                    Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(ref
                                    .read(draftDataControllerProvider)
                                    .teams[_fixture.homeTeamId]!
                                    .teamName!),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text("v"),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(ref
                                    .read(draftDataControllerProvider)
                                    .teams[_fixture.awayTeamId]!
                                    .teamName!),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        fixtures[round['id']]!.remove(_fixture);
                                      });
                                    },
                                    child: Icon(Icons.delete),
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                ]))
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: skipEnabled,
        nextFlex: 0,
        back: const Icon(Icons.arrow_back),
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: DotsDecorator(
          activeColor: Theme.of(context).colorScheme.secondary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: ShapeDecoration(
            color: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)))));
  }

  Widget createAddRoundWidget() {
    var gameweeks = [for (var i = 1; i <= 38; i++) i];
    return Card(
      child: Column(
        children: [
          TextFormField(
              controller: roundNameController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Round ${roundCounter.toString()}',
              )),
          DropdownButton<String>(
            value: selectedValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.white),
            // dropdownColor: Colors.white,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                selectedValue = value!;
              });
            },
            items: gameweeks.map<DropdownMenuItem<String>>((int value) {
              return DropdownMenuItem<String>(
                  value: value.toString(),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(color: Colors.white),
                  ));
            }).toList(),
          ),
          Row(
            children: [
              Text("Aggregrate score from 2 GWs"),
              Checkbox(
                checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: multipleLegs,
                onChanged: (bool? value) {
                  setState(() {
                    multipleLegs = value!;
                  });
                },
              ),
            ],
          ),
          if (multipleLegs)
            Row(
              children: [
                Text("Add 2nd Leg"),
                DropdownButton<String>(
                  value: selectedGameweek2,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  // dropdownColor: Colors.white,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      selectedGameweek2 = value!;
                    });
                  },
                  items: gameweeks.map<DropdownMenuItem<String>>((int value) {
                    return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(
                          value.toString(),
                          style: const TextStyle(color: Colors.white),
                        ));
                  }).toList(),
                )
              ],
            ),
          ElevatedButton(
            onPressed: () => {
              saveRound(),
              setState(() {
                addRound = !addRound;
              })
            },
            child: const Text("Save Round"),
          ),
        ],
      ),
    );
  }

  void saveFixture(String round) {
    final _fixture = CupFixture(
        homeTeamId: int.parse(selectedHomeFixture!),
        awayTeamId: int.parse(selectedAwayFixture!));

    if (fixtures[round] == null) {
      fixtures[round] = [_fixture];
    } else {
      fixtures[round]!.add(_fixture);
    }
  }

  void saveRound() {
    final _round = {
      "id": roundNameController.text.isEmpty
          ? 'Round ${roundCounter.toString()}'
          : roundNameController.text,
      "gameweek": int.parse(selectedValue!),
      "multipleLegs": multipleLegs,
      "secondGameweek": int.parse(selectedGameweek2 ?? selectedValue!)
    };
    rounds.add(_round);
    roundNameController.clear();
    roundCounter++;
  }

  void saveCup() async {
    final cupName = cupNameController.text;
    final cup = Cup(cupName, rounds, fixtures, _selectedTeams);
    this.cup = cup;
    await Hive.box('cups').put(cup.name, cup);
  }

  @override
  void dispose() {
    roundNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.cup != null) {
      cupNameController.text = widget.cup!.name;
      rounds = widget.cup!.rounds;
      for (var round in rounds) {
        final roundFixtures = widget.cup!.fixtures[round['id']];
        if (roundFixtures != null) {
          for (CupFixture fixture in roundFixtures!) {
            if (fixtures[round['id']] == null) {
              fixtures[round['id']] = [fixture];
            } else {
              fixtures[round['id']]!.add(fixture);
            }
          }
        }
      }
      roundCounter = rounds.length + 1;
      if (widget.cup!.teamIds.isNotEmpty) {
        _selectedTeams = widget.cup!.teamIds;
      }
    }
  }
}

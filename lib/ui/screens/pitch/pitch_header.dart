import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/draft_team.dart';

class PitchHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  Fixture fixture;
  DraftTeam homeTeam;
  DraftTeam awayTeam;
  bool subModeEnabled;
  PitchHeader(
      {Key? key,
      required this.homeTeam,
      required this.awayTeam,
      required this.fixture,
      required this.subModeEnabled})
      : super(key: key);

  @override
  _PitchHeaderState createState() => _PitchHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PitchHeaderState extends ConsumerState<PitchHeader> {
  @override
  Widget build(BuildContext context) {
    bool liveBonus = ref.watch(utilsProvider).liveBps!;
    DraftTeam homeTeam = ref
        .watch(fplGwDataProvider)
        .teams![widget.homeTeam.leagueId]![widget.homeTeam.id]!;
    DraftTeam awayTeam = ref
        .watch(fplGwDataProvider)
        .teams![widget.awayTeam.leagueId]![widget.awayTeam.id]!;
    return AppBar(
      automaticallyImplyLeading: false,
      bottom: widget.subModeEnabled
          ? PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(color: Colors.red),
            )
          : TabBar(
              indicatorColor:
                  Theme.of(context).buttonTheme.colorScheme!.secondary,
              tabs: [
                  Tab(
                      child: Column(
                    children: [
                      AutoSizeText(
                        homeTeam.teamName!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                      liveBonus
                          ? Text(homeTeam.bonusPoints.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ))
                          : Text(homeTeam.points.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ))
                    ],
                  )),
                  Tab(
                      child: Column(
                    children: [
                      AutoSizeText(
                        awayTeam.teamName!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                      liveBonus
                          ? Text(awayTeam.bonusPoints.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ))
                          : Text(awayTeam.points.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ))
                    ],
                  )),
                ]),
    );
  }
}

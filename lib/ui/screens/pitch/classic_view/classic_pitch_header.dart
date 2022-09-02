import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassicPitchHeader extends ConsumerStatefulWidget
    with PreferredSizeWidget {
  DraftTeam team;
  ClassicPitchHeader({Key? key, required this.team}) : super(key: key);

  @override
  _ClassicPitchHeaderState createState() => _ClassicPitchHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ClassicPitchHeaderState extends ConsumerState<ClassicPitchHeader> {
  @override
  Widget build(BuildContext context) {
    bool liveBonus = ref.watch(utilsProvider).liveBps!;

    return AppBar(
      bottom: TabBar(
          indicatorColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
          tabs: [
            Tab(
                child: Column(
              children: [
                AutoSizeText(
                  widget.team.teamName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                liveBonus
                    ? Text(widget.team.bonusPoints.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                        ))
                    : Text(widget.team.points.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                        ))
              ],
            )),
          ]),
    );
  }
}

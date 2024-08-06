import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../live_data/domain/draft_domains/draft_team.dart';

class ClassicPitchHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
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
    bool liveBonus = ref.watch(appSettingsRepositoryProvider.select((value) => value.bonusPointsEnabled));
    DraftTeam _team = ref.watch(draftDataControllerProvider).teams[widget.team.id]!;
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
                    ? Text(_team.bonusPoints.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                        ))
                    : Text(_team.points.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                        ))
              ],
            )),
          ]),
    );
  }
}

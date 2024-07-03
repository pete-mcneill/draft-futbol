import 'package:auto_size_text/auto_size_text.dart';
import 'package:draft_futbol/baguley-features/models/baguley_draft_team.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaguleyPitchHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  BaguleyDraftTeam homeTeam;
  BaguleyDraftTeam awayTeam;
  BaguleyPitchHeader({
    Key? key,
    required this.homeTeam,
    required this.awayTeam,
  }) : super(key: key);

  @override
  _BaguleyPitchHeaderState createState() => _BaguleyPitchHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BaguleyPitchHeaderState extends ConsumerState<BaguleyPitchHeader> {
  @override
  Widget build(BuildContext context) {
    bool liveBonus = ref.watch(appSettingsRepositoryProvider.select((value) => value.bonusPointsEnabled));

    return AppBar(
      bottom: TabBar(
          indicatorColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
          tabs: [
            Tab(
                child: Column(
              children: [
                AutoSizeText(
                  widget.homeTeam.teamName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                Text(widget.homeTeam.points.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ))
              ],
            )),
            Tab(
                child: Column(
              children: [
                AutoSizeText(
                  widget.awayTeam.teamName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                ),
                Text(widget.awayTeam.points.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ))
              ],
            )),
          ]),
    );
  }
}


import 'dart:math';

import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/live_data/application/live_service.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:draft_futbol/src/features/substitutes/application/subs_controller.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a shopping cart item (or loading/error UI if needed)
class SubBar extends ConsumerWidget {
  final DraftTeam team;
  const SubBar({
    super.key,
   required this.team
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Color(0xFF05AE56),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(ref.watch(subsControllerProvider).subsModeActive && ref.watch(subsControllerProvider).subsToSave)
                  ...[ElevatedButton(
                    onPressed: () async {
                    ref.read(subsControllerProvider.notifier).enableSubsInprogress();
                    ref.read(subsControllerProvider.notifier).saveSubs(team);
                    List<int> leagueIds = [];
                    ref.read(draftDataControllerProvider).leagues.values.forEach((element) {
                      leagueIds.add(element.leagueId);
                    });
                    await ref.read(liveServiceProvider).getDraftData(leagueIds);
                    final test = ref.read(draftDataControllerProvider);
                    ref.read(subsControllerProvider.notifier).disableSubsInprogress();
                    ref.read(subsControllerProvider.notifier).disableSubsMode(team.id!);  
                  },
                  child: Text("Save Subs"),
                  ),

                  ]
                else
                  ElevatedButton(
                    onPressed: () {
                    ref.read(subsControllerProvider.notifier).enableSubsMode();
                  },
                  child: Text("Make a sub"),
                  ),
                if(ref.watch(subsControllerProvider).subsModeActive)
                  ElevatedButton(
                      onPressed: () async {
                      ref.read(subsControllerProvider.notifier).enableCancelSubs();
                      ref.read(subsControllerProvider.notifier).disableSubsMode(team.id!);
                      await Future.delayed(const Duration(seconds: 2), (){});
                      ref.read(subsControllerProvider.notifier).disableCancelSubs();
                    },
                    child: Text("Cancel"),
                    ),
                if(ref.watch(subsControllerProvider.notifier).checkForSubsForTeam(team))
                  ElevatedButton(onPressed: () async {
                    ref.read(subsControllerProvider.notifier).enableSubsInprogress();
                    ref.read(subsControllerProvider.notifier).resetTeamSubs(team);
                    List<int> leagueIds = [];
                    ref.read(draftDataControllerProvider).leagues.values.forEach((element) {
                      leagueIds.add(element.leagueId);
                    });
                    await ref.read(liveServiceProvider).getDraftData(leagueIds);
                    final test = ref.read(draftDataControllerProvider);
                    ref.read(subsControllerProvider.notifier).disableSubsInprogress();
                    ref.read(subsControllerProvider.notifier).disableSubsMode(team.id!);  
                  },
                  child: Text("Reset Subs"),
                  ),
            ],),
            if(ref.watch(subsControllerProvider).subsModeActive)
              Row(
                children: [
                Flexible(child: Text("To make a sub, drag a player from the bench to a valid starting position", textAlign: TextAlign.center,))
              ],)
          ],
        ),
      ),
    );
  }
}
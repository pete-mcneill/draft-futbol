
import 'dart:math';

import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a shopping cart item (or loading/error UI if needed)
class TempButton extends ConsumerWidget {
  const TempButton({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool enabled = ref.watch(appSettingsRepositoryProvider).bonusPointsEnabled;
    return ElevatedButton(
                    onPressed: () {
                      // ref.read(bonusPointsControllerProvider.notifier).updateActiveLeague("687");
                      // ref.read(settingsControllerProvider.notifier).addString(Random().nextInt(100).toString());
                      // ref.read(appSettingsRepositoryProvider).updateActiveLeagueId(Random().nextInt(100));
                      ref.read(appSettingsRepositoryProvider.notifier).setActiveLeagueId(Random().nextInt(100));
                    },
                    child: Text("BPS:" + enabled.toString()),
                  );
  }
}
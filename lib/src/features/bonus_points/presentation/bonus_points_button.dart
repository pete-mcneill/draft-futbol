
import 'dart:math';

import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/settings/domain/app_settings.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a shopping cart item (or loading/error UI if needed)
class BonusPointsButton extends ConsumerWidget {
  const BonusPointsButton({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsRepositoryProvider);
    int leagueId = settings.activeLeagueId;
    // final settings = ref.watch(settingsControllerProvider);
    // String leagueId = settings.activeLeagueId.toString();
    return  Text(leagueId.toString());
  }
}
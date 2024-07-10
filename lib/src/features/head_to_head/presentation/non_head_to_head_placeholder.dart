import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_screen_controller.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/head_to_head_summary/head_to_head_summary.dart';
import 'package:draft_futbol/src/features/head_to_head/presentation/tab_bar_test.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/pitch/presentation/pitch_screen.dart';
import 'package:draft_futbol/src/common_widgets/coffee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadToHeadPlaceholderScreen extends ConsumerWidget {
  const HeadToHeadPlaceholderScreen(
      {Key? key}) 
  : super(key: key);

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  
    // bool bps = ref.watch(appSettingsRepositoryProvider).liveBonusPoints;
    return Center(child: Text("No Fixtures for Classic League"));
  }
  
}
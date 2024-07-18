import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/live_data/data/live_repository.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PitchAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const PitchAppBar({Key? key}) : super(key: key);

  @override
  _PitchAppBarState createState() => _PitchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PitchAppBarState extends ConsumerState<PitchAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool gameweekFinished = ref.watch(liveDataControllerProvider).gameweek!.gameweekFinished;
    return AppBar(
      centerTitle: true,
      // leadingWidth: 0,
      // titleSpacing: 0,
      automaticallyImplyLeading: true,
      elevation: 0,
      actions: [
        if (!gameweekFinished)
          const BonusPointsToggle()
      ],
      title: Container(
        child: Image.asset("assets/images/1024_1024-icon.png",
            height: 30, width: 30),
      ),
    );
  }
}

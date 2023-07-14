import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_ui.dart';

class PitchAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  PitchAppBar({Key? key}) : super(key: key);

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
    bool liveBonus = ref.watch(utilsProvider).liveBps!;
    bool gameweekFinished = ref.watch(gameweekProvider)!.gameweekFinished;
    return AppBar(
      centerTitle: true,
      // leadingWidth: 0,
      // titleSpacing: 0,
      automaticallyImplyLeading: true,
      elevation: 0,
      actions: [
        if (!gameweekFinished)
          ChoiceChip(
            label: Text("Live Bonus Points"),
            selected: liveBonus,
            onSelected: (selected) {
              ref.read(utilsProvider.notifier).updateLiveBps(selected);
            },
          )
      ],
      title: Container(
        child: Image.asset("assets/images/1024_1024-icon.png",
            height: 30, width: 30),
      ),
    );
  }
}

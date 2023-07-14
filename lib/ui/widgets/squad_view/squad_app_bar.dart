import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SquadAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  SquadAppBar({Key? key}) : super(key: key);

  @override
  _SquadAppBarState createState() => _SquadAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SquadAppBarState extends ConsumerState<SquadAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        // centerTitle: true,
        // leadingWidth: ,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        elevation: 0,
        title: Image.asset("assets/images/1024_1024-icon.png",
            height: 30, width: 30)

        // Container(
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     // mainAxisAlignment: MainAxisAlignment,
        //     children: [
        //       Expanded(
        //           flex: 3,
        //           child: Image.asset("assets/images/1024_1024-icon.png",
        //               height: 30, width: 30)),
        //     ],
        //   ),
        // ),
        );
  }
}

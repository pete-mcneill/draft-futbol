import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SquadAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const SquadAppBar({Key? key}) : super(key: key);

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

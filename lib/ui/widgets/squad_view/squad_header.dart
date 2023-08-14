import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SquadHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  String teamName;
  SquadHeader({Key? key, required this.teamName}) : super(key: key);

  @override
  _SquadHeaderState createState() => _SquadHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SquadHeaderState extends ConsumerState<SquadHeader> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: TabBar(
          indicatorColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
          tabs: [
            Tab(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  widget.teamName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                )
              ],
            )),
          ]),
    );
  }
}

import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/settings_screen.dart';

class DraftAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final bool settings;
  final bool leading;
  String? title;
  DraftAppBar(
      {Key? key, this.settings = false, this.title, this.leading = false})
      : super(key: key);

  @override
  _DraftAppBarState createState() => _DraftAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DraftAppBarState extends ConsumerState<DraftAppBar> {
  List<DropdownMenuItem<String>> menuOptions = [];
  late String dropdownValue;
  bool showBpsButton = true;
  final _controller03 = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    menuOptions = [];
    setupBpsButtonListener();
    setLeagueNamesForDropdown();
    return AppBar(
      centerTitle: true,
      // leadingWidth: 0,
      // titleSpacing: 0,
      // leading:
      //     Image.asset("assets/images/1024_1024-icon.png", height: 5, width: 5),
      automaticallyImplyLeading: widget.leading,
      elevation: 3,
      title: Container(
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Image.asset("assets/images/1024_1024-icon.png",
                    height: 30, width: 30)),
            Expanded(
              flex: 10,
              child: getDropdownTitle(),
            )
          ],
        ),
      ),

      // getDropdownTitle(),
      actions: [
        if (widget.settings)
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          )
      ],
    );
  }

  Widget getDropdownTitle() {
    if (widget.title != null) {
      return (Text(widget.title!));
    } else {
      return DropdownButtonHideUnderline(
        child: DropdownButton2(
          iconEnabledColor: Theme.of(context).colorScheme.secondaryContainer,
          isExpanded: true,
          items: menuOptions,
          onChanged: (value) {
            ref
                .read(utilsProvider.notifier)
                .updateActiveLeague(value.toString());
          },
          value: dropdownValue,
          // dropdownDecoration:
          //     BoxDecoration(color: Theme.of(context).primaryColorDark),
        ),
      );
    }
  }

  Widget showUISettingsButton() {
    if (widget.settings) {
      return IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Customise UI Settings',
        onPressed: () {
          showDialog<void>(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return const UiSettingsDialog();
            },
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }

  void setLeagueNamesForDropdown() {
    Map<String, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds.forEach((key, value) {
      menuOptions.add(DropdownMenuItem(
          value: key,
          child: Center(
            child: Text(
              value['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    });
    dropdownValue = ref.watch(
        utilsProvider.select((connection) => connection.activeLeagueId!));
  }

  void setupBpsButtonListener() {
    _controller03.addListener(() {
      if (_controller03.value) {
        ref.watch(utilsProvider.notifier).updateLiveBps(true);
      } else {
        ref.watch(utilsProvider.notifier).updateLiveBps(false);
      }
    });
    _controller03.value =
        ref.watch(utilsProvider.select((connection) => connection.liveBps!));
  }
}

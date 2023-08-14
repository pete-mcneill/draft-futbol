import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/app_store_links.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/settings_screen.dart';

class WebAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final bool settings;
  final bool leading;
  final String leagueType;
  final bool? hideTabs;
  String? title;
  WebAppBar(
      {Key? key,
      this.settings = false,
      this.title,
      this.leading = false,
      this.leagueType = 'h',
      this.hideTabs = false})
      : super(key: key);

  @override
  _WebAppBarState createState() => _WebAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WebAppBarState extends ConsumerState<WebAppBar> {
  List<DropdownMenuItem<String>> menuOptions = [];
  late String dropdownValue;
  bool showBpsButton = true;
  final _controller03 = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  TabBar getTabBar() {
    if (widget.leagueType == 'h') {
      return const TabBar(
        tabs: [
          Tab(icon: Text("Fixtures")),
          Tab(icon: Text("Standings")),
          Tab(icon: Text("Premier League Matches")),
          Tab(icon: Text("More")),
        ],
      );
    } else {
      return const TabBar(
        tabs: [
          Tab(icon: Text("Standings")),
          Tab(icon: Text("Premier League Matches")),
          Tab(icon: Text("More")),
        ],
      );
    }
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
      bottom: widget.hideTabs! ? null : getTabBar(),
      title: Container(
        width: 1000,
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Image.asset("assets/images/1024_1024-icon.png",
                    height: 30, width: 30)),
            ...appStoreLinks(),
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
            icon: const Icon(
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
                .updateActiveLeague(int.parse(value.toString()));
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
    Map<int, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds.forEach((key, value) {
      menuOptions.add(DropdownMenuItem(
          value: key.toString(),
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
    dropdownValue = ref.watch(utilsProvider
        .select((connection) => connection.activeLeagueId!.toString()));
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

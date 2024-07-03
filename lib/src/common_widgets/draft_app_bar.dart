import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/settings_screen.dart';

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
      return Consumer(
        builder: (context, ref, child) {
          dropdownValue = ref.watch(appSettingsRepositoryProvider).activeLeagueId.toString();
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              // iconEnabledColor: Theme.of(context).colorScheme.secondaryContainer,
              isExpanded: true,
              items: menuOptions,
              onChanged: (value) {
                // ref.read(appSettingsRepositoryProvider).setActiveLeagueId(int.parse(value!));
              },
              value: dropdownValue,
              // dropdownDecoration:
              //     BoxDecoration(color: Theme.of(context).primaryColorDark),
            ),
          );
        }
      );
    }
  }

  // Widget showUISettingsButton() {
  //   if (widget.settings) {
  //     return IconButton(
  //       icon: const Icon(Icons.settings),
  //       tooltip: 'Customise UI Settings',
  //       onPressed: () {
  //         showDialog<void>(
  //           context: context,
  //           barrierDismissible: true, // user must tap button!
  //           builder: (BuildContext context) {
  //             return const UiSettingsDialog();
  //           },
  //         );
  //       },
  //     );
  //   } else {
  //     return const SizedBox();
  //   }
  // }

  void setLeagueNamesForDropdown() {
    List<LocalLeagueMetadata> leaguesMetadata = ref.read(dataStoreProvider).getLeagues();
    leaguesMetadata.forEach((value) {
      menuOptions.add(DropdownMenuItem(
          value: value.id.toString(),
          child: Center(
            child: Text(
              value.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    });
    // dropdownValue = ref.watch(activeLeagueIdProvider).toString();
  }

  void setupBpsButtonListener() {
    _controller03.addListener(() {
      ref.read(appSettingsRepositoryProvider.notifier).toggleLiveBonusPoints();
    });
    _controller03.value =
        ref.watch(appSettingsRepositoryProvider.select((connection) => connection.bonusPointsEnabled));
  }
}

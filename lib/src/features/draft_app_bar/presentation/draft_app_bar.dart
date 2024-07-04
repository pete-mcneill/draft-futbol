import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class DraftAppBarV1 extends ConsumerWidget
    implements PreferredSizeWidget {
  final bool settings;
  final bool leading;
  String? title;
  DraftAppBarV1(
      {Key? key, this.settings = false, this.title, this.leading = false})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  List<DropdownMenuItem<String>> menuOptions = [];
  late String dropdownValue;
  bool showBpsButton = true;
  final _controller03 = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      void setupBpsButtonListener() {
    _controller03.addListener(() {
      ref.read(appSettingsRepositoryProvider.notifier).toggleLiveBonusPoints();
    });
    _controller03.value = ref.watch(appSettingsRepositoryProvider.select((value) => value.bonusPointsEnabled));
  }

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
    menuOptions = [];
    setupBpsButtonListener();
    setLeagueNamesForDropdown();
    
  ref.listen<AsyncValue<void>>(
      draftAppBarControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
  final state = ref.watch(draftAppBarControllerProvider);
  Widget getDropdownTitle() {
    if (title != null) {
      return (Text(title!));
    } else {
      return Consumer(
        builder: (context, ref, child) {
          final appSettings = ref.watch(appSettingsRepositoryProvider);
          dropdownValue = appSettings.activeLeagueId.toString();
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              // iconEnabledColor: Theme.of(context).colorScheme.secondaryContainer,
              isExpanded: true,
              items: menuOptions,
              onChanged: (value) {
                // ref.read(draftAppBarControllerProvider.notifier).updateActiveLeague(value!);
                // ref.read(settingsControllerProvider.notifier).addString(value!);
                ref.read(appSettingsRepositoryProvider.notifier).setActiveLeagueId(int.parse(value!));
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
  //   if (settings) {
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

return AppBar(
      centerTitle: true,
      // leadingWidth: 0,
      // titleSpacing: 0,
      // leading:
      //     Image.asset("assets/images/1024_1024-icon.png", height: 5, width: 5),
      automaticallyImplyLeading: leading,
      elevation: 3,
      title: Container(
        child: Row(
          children: [
             BonusPointsButton(),
            //  Consumer(
            //     builder: (context, ref, child) {
            //       final appSettings = ref.watch(appSettingsRepositoryProvider);
            //       return Text(appSettings.activeLeagueId.toString());
            //     },
            //   ),
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
        if (settings)
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          )
      ],
    );

    }
    }
